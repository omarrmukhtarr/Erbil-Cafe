# Rotating the Google Maps keys

Four distinct Maps/Firebase API keys are readable in this repository's public
history. They are still live. Anyone who finds them can bill map loads to the
project until they are revoked — and the history cannot be un-published, so
revoking is the only fix.

| Key (first 10 · last 4) | Where it leaked |
|---|---|
| `AIzaSyAPNf…Utao` | `master` — the 2022 prototype |
| `AIzaSyCEbI…0ef0` | `GoogleService-Info.plist`, on **both** branches |
| `AIzaSyCfXn…1MLU` | `master` |
| `AIzaSyDk4C…Iags` | `master` |

`master` is the repository's **default branch**, so these are the first files a
visitor sees. In v2 the key itself is no longer committed — iOS reads
`MAPS_API_KEY` from the untracked `ios/Flutter/Secrets.xcconfig`, Android from
the untracked `android/local.properties` — but the *old* commits still carry it.

## Do this in order

Creating keys requires the Google Cloud console, so these steps are yours.
Nothing here can be done from this repository.

### 1. Create the replacements — restricted from the start

In **console.cloud.google.com → APIs & Services → Credentials**, create two
keys. Two, not one: a key restricted to an iOS bundle id cannot also be
restricted to an Android signing certificate, and an unrestricted key is how
this happened the first time.

**iOS key**
- Application restriction: **iOS apps** → bundle id `com.erbil.erbilcafe`
- API restriction: **Maps SDK for iOS** only

**Android key**
- Application restriction: **Android apps** → package `com.erbil.erbilcafe`
  plus the SHA-1 of *both* your debug and upload signing certificates
  (`keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey
  -storepass android`)
- API restriction: **Maps SDK for Android** only

A key restricted to an app and one API is worth almost nothing to a stranger,
which is the entire point.

### 2. Cap the spend

**Billing → Budgets & alerts**: set a monthly budget with alerts at 50/90/100%.
A budget does not stop charges on its own, so also set a daily quota under
**APIs & Services → Maps SDK → Quotas**. Erbil's whole catalogue is 253 cafés;
a few thousand map loads a day is generous. Anything past that is someone
else's traffic.

### 3. Put the new keys in, locally

```bash
# app/ios/Flutter/Secrets.xcconfig   (git-ignored)
MAPS_API_KEY=<the new iOS key>

# app/android/local.properties       (git-ignored)
MAPS_API_KEY=<the new Android key>
```

Then check the map actually draws on both platforms before going further —
a revoked key and a mistyped replacement look identical from the app, which
shows the café-list fallback rather than crashing.

```bash
flutter run                       # iOS simulator
flutter run -d <android-device>
```

### 4. Only now, delete the old keys

Back in **Credentials**, delete all four. Not "restrict" — delete. A restricted
key that is public is one console misconfiguration away from being open again.

### 5. Check nothing is watching them die

Give it 24 hours and look at **APIs & Services → Metrics**. Traffic against the
deleted keys after the apps are updated is somebody else's, and tells you the
leak was being used.

## Keeping it from happening again

`tool/check_secrets.sh` scans the working tree and the full history for key
patterns. Run it before a release, or wire it into CI:

```bash
./tool/check_secrets.sh
```

It exits non-zero when it finds something, so it fails a build rather than
printing a warning nobody reads.

## What about the old commits?

Rewriting the history with `git filter-repo` would remove the keys from the
repository, but not from GitHub's caches, anyone's fork, or any clone already
made. **Revoking is what actually fixes this; rewriting is tidying.** Do the
revocation first and treat a rewrite as optional — and if you do rewrite, every
collaborator has to re-clone.

The same applies to `GoogleService-Info.plist`: it is git-ignored now, and it
is in both branches' history. The key inside it is one of the four above, so
revoking that key covers it.
