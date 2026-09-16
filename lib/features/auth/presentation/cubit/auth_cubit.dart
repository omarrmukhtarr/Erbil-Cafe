import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../app/di/injector.dart';
import '../../../../core/error/failure.dart';
import '../../../notifications/data/push_service.dart';
import '../../data/models/user.dart';
import '../../data/repositories/auth_repository.dart';

enum AuthStatus { unknown, authenticated, guest }

class AuthState extends Equatable {
  const AuthState({this.status = AuthStatus.unknown, this.user, this.failure});

  final AuthStatus status;
  final AppUser? user;
  final Failure? failure;

  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;

  AuthState copyWith({AuthStatus? status, AppUser? user, Failure? failure}) =>
      AuthState(
        status: status ?? this.status,
        user: user ?? this.user,
        failure: failure,
      );

  @override
  List<Object?> get props => [status, user, failure];
}

/// Owns the session. Everything that needs "is someone signed in" reads it here
/// rather than each screen checking storage.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(const AuthState());

  final AuthRepository _repository;

  /// Restores the session at startup.
  ///
  /// This used to hold the splash screen on `/users/me` for every signed-in
  /// launch — as long as the network took, up to the 15-second connect
  /// timeout — and then sign the user *out* if that request failed for any
  /// reason, including simply being offline. Opening the app on the metro
  /// cost you your session.
  ///
  /// Now a saved profile opens the app signed in at once, and the profile is
  /// confirmed in the background. Only the server saying the session is over
  /// signs anyone out; a network error leaves them as they were.
  Future<void> restore() async {
    if (!await _repository.hasSession) {
      emit(const AuthState(status: AuthStatus.guest));
      return;
    }

    final cached = await _repository.cachedUser();
    if (cached != null) {
      emit(AuthState(status: AuthStatus.authenticated, user: cached));
      unawaited(_confirmSession());
      return;
    }

    // Signed in before profiles were saved on the device: nothing to show
    // yet, so this one launch still waits.
    await _confirmSession();
  }

  Future<void> _confirmSession() async {
    try {
      final user = await _repository.me();
      if (isClosed) return;
      emit(AuthState(status: AuthStatus.authenticated, user: user));
    } on UnauthorizedFailure {
      // The auth interceptor has already tried a refresh; the session is over.
      await _repository.logout();
      if (isClosed) return;
      emit(const AuthState(status: AuthStatus.guest));
    } on Failure {
      if (isClosed || state.isAuthenticated) return;
      // No saved profile and no network. Browse as a guest for now, but keep
      // the tokens: the next launch with a connection signs straight back in.
      emit(const AuthState(status: AuthStatus.guest));
    }
  }

  Future<bool> login(String email, String password) async {
    emit(state.copyWith(status: AuthStatus.unknown));
    try {
      final user = await _repository.login(email: email, password: password);
      emit(AuthState(status: AuthStatus.authenticated, user: user));
      // This device now belongs to this account. Fire-and-forget: a device
      // that fails to register still works, it is just quiet.
      unawaited(sl<PushService>().registerDevice(locale: user.locale));
      return true;
    } on Failure catch (f) {
      emit(AuthState(status: AuthStatus.guest, failure: f));
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String locale = 'ku',
  }) async {
    emit(state.copyWith(status: AuthStatus.unknown));
    try {
      final user = await _repository.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
        locale: locale,
      );
      emit(AuthState(status: AuthStatus.authenticated, user: user));
      return true;
    } on Failure catch (f) {
      emit(AuthState(status: AuthStatus.guest, failure: f));
      return false;
    }
  }

  Future<void> logout() async {
    // Detach the device first: after the tokens are gone the unregister call
    // has nothing to authenticate with, and a shared phone would keep
    // receiving the previous account's bookings.
    await sl<PushService>().unregisterDevice();
    await _repository.logout();
    emit(const AuthState(status: AuthStatus.guest));
  }

  /// Closes the account and drops back to browsing as a guest.
  ///
  /// Throws on failure rather than swallowing it: a delete that did not happen
  /// must not look like one that did, so the screen shows the error and the
  /// session stays.
  Future<void> deleteAccount() async {
    await sl<PushService>().unregisterDevice();
    await _repository.deleteAccount();
    emit(const AuthState(status: AuthStatus.guest));
  }

  /// Called by the network layer when a refresh fails and the session is over.
  void onSessionExpired() {
    emit(const AuthState(status: AuthStatus.guest));
  }

  Future<void> refreshProfile() async {
    if (!state.isAuthenticated) return;
    try {
      emit(state.copyWith(user: await _repository.me()));
    } on Failure {
      // Keep the cached profile; a failed refresh is not a sign-out.
    }
  }

  Future<bool> updateProfile({String? name, String? phone, String? locale}) async {
    // Guests reach this through the language picker on the profile tab, which
    // is open to them on purpose. There is no account to write the choice to,
    // and the request would only 401 — the device-level setting is enough.
    if (!state.isAuthenticated) return false;

    try {
      final user = await _repository.updateProfile(
        name: name,
        phone: phone,
        locale: locale,
      );
      emit(AuthState(status: AuthStatus.authenticated, user: user));
      return true;
    } on Failure catch (f) {
      emit(state.copyWith(failure: f));
      return false;
    }
  }
}
