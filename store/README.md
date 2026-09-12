# Store submission

Everything App Store Connect and the Play Console ask for, except the parts
that need your accounts.

```
metadata/{en,ar,ku}/listing.md   name, description, keywords, captions
screenshots/ios-6.9/             1320×2868, the size Apple requires
capture-screenshots.sh           regenerates them
```

## Re-capture the screenshots before you submit

The current set is real and correctly sized, but it shows the catalogue as it
is today: most cards read **"No photo yet"** and **"Closed"**, because only 3
of 253 cafés have a photo and only 78 have opening hours. A reviewer sees that
before a user does.

Fill in the top 40–60 cafés from the dashboard, then:

```bash
./store/capture-screenshots.sh
```

## What is left, and why only you can do it

| | |
|---|---|
| Apple Developer Program | $99/year, and enrolment as an organisation can take days |
| Google Play Console | $25 once |
| App icon | 1024×1024, no alpha, no rounded corners — Apple rounds it |
| Bundle id | `com.erbil.erbilcafe` is already set on both platforms |
| Signing | An App Store distribution certificate; an upload keystore for Play |
| Data safety form | Play asks item by item; `metadata/en/listing.md` and the privacy policy have the answers |

## Kurdish

Verify in App Store Connect and the Play Console whether Sorani is offered as
a storefront language before planning around it — it is not on every platform's
list, and neither console lets you invent one.

If it is not available, publish the listing in **Arabic and English**, which
covers the storefronts Erbil actually browses, and keep the Kurdish text for
the app itself and the website. The app is fully localised in Kurdish either
way; this is only about the store page.

## The checks that fail a first submission

- [ ] **Account deletion is reachable in the app.** Profile → Delete my
      account. Apple rejects for this more than for anything else on this list.
- [ ] **The privacy URL loads while signed out.** Reviewers check it in a
      private window; a page behind the dashboard's login is a rejection.
- [ ] **Every permission prompt explains itself.** Notifications are asked for
      after a booking, where the reason is on screen — not at launch.
- [ ] **The app works signed out.** A reviewer will not make an account.
      Browsing, the map and menus all work as a guest; make sure they still do.
- [ ] **Give them a test account anyway,** in App Review Information, for the
      parts that need one — booking, favourites, reviews.
- [ ] **No placeholder text or lorem anywhere,** including empty states.
- [ ] **The build is a release build** against the production API, not
      `localhost`.
