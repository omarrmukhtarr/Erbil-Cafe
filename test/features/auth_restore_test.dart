import 'dart:async';

import 'package:erbilcafe/core/error/failure.dart';
import 'package:erbilcafe/features/auth/data/models/user.dart';
import 'package:erbilcafe/features/auth/data/repositories/auth_repository.dart';
import 'package:erbilcafe/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuth extends Mock implements AuthRepository {}

const _saved = AppUser(
  id: 'u1',
  name: 'Aram Hama',
  role: 'USER',
  locale: 'ku',
  emailVerified: true,
  phoneVerified: false,
);

/// How a signed-in person's session comes back when the app starts.
///
/// It used to wait on `/users/me` before the first frame, and to sign the
/// user out if that request failed for *any* reason — so opening the app
/// offline cost you your session.
void main() {
  late _MockAuth auth;

  setUp(() {
    auth = _MockAuth();
    when(() => auth.hasSession).thenAnswer((_) async => true);
    when(() => auth.logout()).thenAnswer((_) async {});
  });

  test('a saved profile signs in at once, without waiting for the network',
      () async {
    final never = Completer<AppUser>();
    when(() => auth.cachedUser()).thenAnswer((_) async => _saved);
    when(() => auth.me()).thenAnswer((_) => never.future);

    final cubit = AuthCubit(auth);
    await cubit.restore();

    // Restored while /users/me is still in the air.
    expect(cubit.state.isAuthenticated, isTrue);
    expect(cubit.state.user?.name, 'Aram Hama');
  });

  test('being offline at launch keeps the session', () async {
    when(() => auth.cachedUser()).thenAnswer((_) async => _saved);
    when(() => auth.me()).thenThrow(const NetworkFailure());

    final cubit = AuthCubit(auth);
    await cubit.restore();
    await pumpEventQueue();

    expect(cubit.state.isAuthenticated, isTrue);
    verifyNever(() => auth.logout());
  });

  test('a session the server has ended signs out', () async {
    when(() => auth.cachedUser()).thenAnswer((_) async => _saved);
    when(() => auth.me()).thenThrow(const UnauthorizedFailure());

    final cubit = AuthCubit(auth);
    await cubit.restore();
    await pumpEventQueue();

    expect(cubit.state.status, AuthStatus.guest);
    verify(() => auth.logout()).called(1);
  });

  test('the fresh profile replaces the saved one once it arrives', () async {
    when(() => auth.cachedUser()).thenAnswer((_) async => _saved);
    when(() => auth.me()).thenAnswer(
      (_) async => const AppUser(
        id: 'u1',
        name: 'Aram H.',
        role: 'USER',
        locale: 'ku',
        emailVerified: true,
        phoneVerified: false,
      ),
    );

    final cubit = AuthCubit(auth);
    await cubit.restore();
    await pumpEventQueue();

    expect(cubit.state.user?.name, 'Aram H.');
  });
}
