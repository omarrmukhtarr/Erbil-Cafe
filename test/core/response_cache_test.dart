import 'package:erbilcafe/core/network/response_cache.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late DateTime now;
  late ResponseCache cache;

  setUp(() {
    now = DateTime(2026, 9, 16, 12);
    cache = ResponseCache(now: () => now);
  });

  test('serves a fresh entry without fetching again', () async {
    var fetches = 0;
    Future<int> fetch() async => ++fetches;

    expect(await cache.get('k', ttl: const Duration(minutes: 5), fetch: fetch), 1);
    expect(await cache.get('k', ttl: const Duration(minutes: 5), fetch: fetch), 1);
    expect(fetches, 1);
  });

  test('refetches once the entry is older than its ttl', () async {
    var fetches = 0;
    Future<int> fetch() async => ++fetches;

    await cache.get('k', ttl: const Duration(minutes: 5), fetch: fetch);
    now = now.add(const Duration(minutes: 6));

    expect(await cache.get('k', ttl: const Duration(minutes: 5), fetch: fetch), 2);
  });

  test('callers asking at the same time share one request', () async {
    var fetches = 0;
    Future<int> fetch() async {
      fetches++;
      await Future<void>.delayed(const Duration(milliseconds: 10));
      return 7;
    }

    final results = await Future.wait([
      cache.get('k', ttl: const Duration(minutes: 5), fetch: fetch),
      cache.get('k', ttl: const Duration(minutes: 5), fetch: fetch),
    ]);

    expect(results, [7, 7]);
    expect(fetches, 1);
  });

  test('a failed fetch is not cached', () async {
    var fail = true;
    Future<int> fetch() async {
      if (fail) throw StateError('offline');
      return 1;
    }

    await expectLater(
      cache.get('k', ttl: const Duration(minutes: 5), fetch: fetch),
      throwsStateError,
    );
    fail = false;
    expect(await cache.get('k', ttl: const Duration(minutes: 5), fetch: fetch), 1);
  });

  test('a response in the air when the language changed is not kept',
      () async {
    Future<String> fetch() async {
      await Future<void>.delayed(const Duration(milliseconds: 10));
      return 'Kurdish text';
    }

    final pending =
        cache.get('k', ttl: const Duration(minutes: 5), fetch: fetch);
    cache.clear();
    await pending;

    expect(cache.peek<String>('k'), isNull);
  });
}
