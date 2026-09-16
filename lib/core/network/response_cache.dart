import 'dart:async';

/// A small in-memory cache for GET responses that are the same for everyone.
///
/// Nothing was cached before this, so every tab and every screen re-downloaded
/// the lists it was built from: Home fetched amenities and areas, Explore
/// fetched them again a second later, and every visit to a café refetched a
/// menu that had not changed. `AppConfig.cacheTtl` existed and nothing read it.
///
/// Two things make it safe:
///
/// * **Only catalogue data goes through it** — amenities, areas, map pins, the
///   popular feed and menus. Anything carrying the signed-in user's own state
///   (`isFavorited`, bookings, reviews) is always fetched fresh, so a cache can
///   never show one account's hearts to another.
/// * **Concurrent requests for the same key share one flight.** Home and
///   Explore opening together ask for `/cafes/areas` once, not twice.
///
/// The API resolves text in the request language, so [clear] is called when
/// the language changes.
class ResponseCache {
  ResponseCache({this.now = DateTime.now});

  /// The cache every repository shares.
  static final shared = ResponseCache();

  /// Injectable clock, for tests.
  final DateTime Function() now;

  final _entries = <String, _Entry>{};
  final _inFlight = <String, Future<Object?>>{};

  /// Returns the cached value for [key] if it is younger than [ttl], otherwise
  /// runs [fetch] — once, however many callers are waiting — and stores it.
  ///
  /// A failed fetch is not cached, so the next caller retries.
  Future<T> get<T>(
    String key, {
    required Duration ttl,
    required Future<T> Function() fetch,
  }) {
    final entry = _entries[key];
    if (entry != null && now().difference(entry.storedAt) < ttl) {
      return Future.value(entry.value as T);
    }

    final pending = _inFlight[key];
    if (pending != null) return pending.then((value) => value as T);

    final future = fetch();
    _inFlight[key] = future;

    // The epoch stops a response that was already in the air when [clear] ran
    // — in the old language — from repopulating the cache afterwards.
    final epoch = _epoch;
    return future.then((value) {
      if (epoch == _epoch) {
        _entries[key] = _Entry(value, now());
      }
      return value;
    }).whenComplete(() {
      if (identical(_inFlight[key], future)) _inFlight.remove(key);
    });
  }

  /// The cached value for [key] regardless of age, or null.
  ///
  /// Lets a screen paint what it had last time while a fresh copy loads.
  T? peek<T>(String key) => _entries[key]?.value as T?;

  void invalidate(String key) => _entries.remove(key);

  int _epoch = 0;

  void clear() {
    _epoch++;
    _entries.clear();
    _inFlight.clear();
  }
}

class _Entry {
  const _Entry(this.value, this.storedAt);

  final Object? value;
  final DateTime storedAt;
}
