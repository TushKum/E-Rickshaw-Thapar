# Firestore rules tests

Exercises [`firestore.rules`](../../firestore.rules) against the Firestore
emulator — no live project, no real credentials.

```bash
cd test/rules
npm install
npm test
```

Requires **Java 21+** on `PATH` (the emulator refuses anything older). Note the
Android build needs **Java 17**, so the two use different JDKs:

```bash
JAVA_HOME=$(/usr/libexec/java_home -v 21) npm test
```

## What it covers

Twenty-one cases in five groups:

- **Legitimate flows** — a passenger opening, polling, and cancelling their own
  request; a driver listing open requests and accepting one; both sides reading
  the other's profile after a match.
- **Role enforcement** — a signed-in account with no `drivers/{uid}` document
  cannot accept a ride, and neither can another passenger. This is the hole the
  role check closes: before it, any signed-in user could claim or cancel a
  stranger's ride.
- **Driver cannot cheat while accepting** — cannot stamp another driver's uid,
  cannot rewrite `from`/`to`, cannot re-accept an already-claimed request.
- **Request shape** — no pre-accepted requests, no requests under someone
  else's uid, no identical pickup and drop, no extra fields.
- **Profiles are owner-only** — no forging another user's driver profile, and
  unauthenticated reads are refused outright.

## Known diagnostic noise

Four of the denial cases log `evaluation error at L80:24` (the `isDriver()`
lookup on the driver-accept rule). It appears only on paths that are denied
anyway, and never on a legitimate operation — the driver-accept test covers
that exact path and passes. The root cause has not been confirmed.
