import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
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

  /// Restores the session at startup. A stored refresh token is not proof of a
  /// live session — it may have been revoked — so the profile is fetched to
  /// confirm before the user is treated as signed in.
  Future<void> restore() async {
    if (!await _repository.hasSession) {
      emit(const AuthState(status: AuthStatus.guest));
      return;
    }

    try {
      final user = await _repository.me();
      emit(AuthState(status: AuthStatus.authenticated, user: user));
    } on Failure {
      await _repository.logout();
      emit(const AuthState(status: AuthStatus.guest));
    }
  }

  Future<bool> login(String email, String password) async {
    emit(state.copyWith(status: AuthStatus.unknown));
    try {
      final user = await _repository.login(email: email, password: password);
      emit(AuthState(status: AuthStatus.authenticated, user: user));
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
    await _repository.logout();
    emit(const AuthState(status: AuthStatus.guest));
  }

  /// Closes the account and drops back to browsing as a guest.
  ///
  /// Throws on failure rather than swallowing it: a delete that did not happen
  /// must not look like one that did, so the screen shows the error and the
  /// session stays.
  Future<void> deleteAccount() async {
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
