import 'dart:async';

import 'package:erbilcafe/app/di/injector.dart';
import 'package:erbilcafe/core/error/failure.dart';
import 'package:erbilcafe/features/auth/data/repositories/auth_repository.dart';
import 'package:erbilcafe/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:erbilcafe/features/cafes/data/models/cafe.dart';
import 'package:erbilcafe/features/cafes/data/repositories/cafe_repository.dart';
import 'package:erbilcafe/features/cafes/presentation/cubit/cafe_list_cubit.dart';
import 'package:erbilcafe/features/cafes/presentation/screens/cafe_detail_screen.dart';
import 'package:erbilcafe/features/favorites/data/favorite_sync.dart';
import 'package:erbilcafe/features/favorites/data/favorites_repository.dart';
import 'package:erbilcafe/features/reviews/data/repositories/review_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/pump_app.dart';

class _MockCafes extends Mock implements CafeRepository {}

class _MockFavorites extends Mock implements FavoritesRepository {}

class _MockReviews extends Mock implements ReviewRepository {}

class _MockAuth extends Mock implements AuthRepository {}

Cafe _cafe(String id, {bool favorited = false}) => Cafe(
      id: id,
      slug: 'cafe-$id',
      name: 'Café $id',
      description: '',
      address: '',
      lat: 36.19,
      lng: 44.01,
      priceRange: PriceRange.moderate,
      ratingAvg: 4.5,
      reviewCount: 3,
      isFeatured: false,
      isOpenNow: true,
      amenities: const [],
      isFavorited: favorited,
    );

/// Things that used to wait on the network before anything moved.
void main() {
  setUpAll(() => registerFallbackValue(const CafeQuery()));

  group('saving a café', () {
    test('the heart fills before the request returns', () async {
      final favorites = _MockFavorites();
      final response = Completer<bool>();
      when(() => favorites.toggle('a')).thenAnswer((_) => response.future);

      final cafes = _MockCafes();
      when(() => cafes.list(any())).thenAnswer(
        (_) async => Paginated(items: [_cafe('a')]),
      );
      final cubit = CafeListCubit(cafes);
      await cubit.load();

      final done = FavoriteSync.instance.toggle(_cafe('a'), favorites);
      await pumpEventQueue();

      expect(cubit.state.cafes.single.isFavorited, isTrue,
          reason: 'shown as saved while the request is still in the air');

      response.complete(true);
      expect(await done, isTrue);
      await cubit.close();
    });

    test('a failed save puts the heart back', () async {
      final favorites = _MockFavorites();
      when(() => favorites.toggle('b'))
          .thenAnswer((_) async => throw const NetworkFailure());

      final cafes = _MockCafes();
      when(() => cafes.list(any())).thenAnswer(
        (_) async => Paginated(items: [_cafe('b')]),
      );
      final cubit = CafeListCubit(cafes);
      await cubit.load();

      await expectLater(
        FavoriteSync.instance.toggle(_cafe('b'), favorites),
        throwsA(isA<NetworkFailure>()),
      );
      await pumpEventQueue();

      expect(cubit.state.cafes.single.isFavorited, isFalse);
      await cubit.close();
    });
  });

  test('a page that lands after the filter changed is not appended', () async {
    final cafes = _MockCafes();
    final slowPage = Completer<Paginated<Cafe>>();

    when(() => cafes.list(any())).thenAnswer((invocation) {
      final query = invocation.positionalArguments.first as CafeQuery;
      if (query.cursor != null) return slowPage.future;
      if (query.area == 'Ainkawa') {
        return Future.value(Paginated(items: [_cafe('ainkawa')]));
      }
      return Future.value(
        Paginated(items: [_cafe('1')], nextCursor: 'next', hasMore: true),
      );
    });

    final cubit = CafeListCubit(cafes);
    await cubit.load();

    final more = cubit.loadMore();
    cubit.setArea('Ainkawa');
    await pumpEventQueue();

    slowPage.complete(Paginated(items: [_cafe('2')]));
    await more;

    expect(cubit.state.cafes.map((c) => c.id), ['ainkawa']);
    await cubit.close();
  });

  testWidgets('a café opened from a card draws its name on the first frame',
      (tester) async {
    await sl.reset();
    final cafes = _MockCafes();
    final reviews = _MockReviews();
    final auth = _MockAuth();

    // Neither request ever answers: anything on screen came from the card.
    when(() => cafes.detail(any()))
        .thenAnswer((_) => Completer<CafeDetail>().future);
    when(() => reviews.forCafe(any()))
        .thenAnswer((_) => Completer<ReviewPage>().future);

    sl
      ..registerSingleton<CafeRepository>(cafes)
      ..registerSingleton<ReviewRepository>(reviews);
    addTearDown(sl.reset);

    await tester.pumpApp(
      BlocProvider(
        create: (_) => AuthCubit(auth),
        child: CafeDetailScreen(slug: 'cafe-a', preview: _cafe('a')),
      ),
    );
    await tester.pump();

    expect(find.text('Café a'), findsWidgets);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    tester.expectNoOverflow();
  });
}
