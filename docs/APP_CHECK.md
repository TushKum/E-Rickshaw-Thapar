# App Check

App Check attests that requests reaching Firebase come from *this app*, not from
a script replaying the API key. The key is public — it ships inside every APK
and is committed to this repo — so App Check, not key secrecy, is what stops
someone scripting against the backend.

**Status: wired up, enforcement OFF.** Do not turn enforcement on yet. Read the
constraint below first.

## Why enforcement is off

`android/app/build.gradle` signs release builds with `signingConfigs.debug`, and
the app is distributed by sideloading an APK. Play Integrity — the only real
attestation provider on Android — only vouches for apps **installed from Play
and signed with the Play app-signing key**. A sideloaded, debug-signed build
fails attestation every time.

Turning enforcement on today would reject 100% of installs, including yours.

## What the code does

`lib/main.dart` picks the provider by build type:

| Build | Provider | Works? |
|---|---|---|
| `flutter run` (debug) | `AndroidProvider.debug` | Yes, once the device token is registered |
| `flutter build apk --release`, sideloaded | `AndroidProvider.playIntegrity` | **No** — not Play-installed |
| Release via Play (internal testing or higher) | `AndroidProvider.playIntegrity` | Yes |

## Using it during the pilot (debug builds)

The debug provider mints a token per install that must be registered manually.

1. Run the app with `flutter run` and watch the logs for a line like:
   `Enter this debug secret into the allow list in the Firebase Console:
   <uuid>`
2. Register it: **Firebase Console → App Check → Apps →
   `edu.thapar.erickshaw` → ⋮ → Manage debug tokens → Add**.
3. Repeat per device. This does not scale — it is for your own test handsets,
   not for 50 beta students.

Console: https://console.firebase.google.com/project/erickshaw-thapar-7030/appcheck

## Turning enforcement on properly

Enforcement only makes sense once the app ships through Play. In order:

1. Publish to Play (internal testing is enough) and let Play sign the app.
2. In **Play Console → Setup → App integrity**, confirm the Play Integrity API
   is on, and copy the **app-signing** SHA-256 into the Firebase Android app.
   Note this is Play's signing key, not the debug SHA-256 currently in use
   (`FA:78:0F:EE:…`), which will no longer apply.
3. Register Play Integrity: **Firebase Console → App Check → Apps →
   `edu.thapar.erickshaw` → Play Integrity → Register**.
4. **Watch metrics for at least a week before enforcing.** App Check reports
   verified vs unverified request counts per service. If unverified traffic is
   still non-trivial, enforcing will lock out real users.
5. Only then enforce, one service at a time — Firestore first:

   ```bash
   TOKEN=$(python3 -c "import json,os;print(json.load(open(os.path.expanduser('~/.config/configstore/firebase-tools.json')))['tokens']['access_token'])")
   curl -X PATCH \
     -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
     -d '{"enforcementMode":"ENFORCED"}' \
     "https://firebaseappcheck.googleapis.com/v1/projects/erickshaw-thapar-7030/services/firestore.googleapis.com?updateMask=enforcementMode"
   ```

   Roll back by sending `"UNENFORCED"` the same way.

## Current state

- `firebaseappcheck.googleapis.com` — enabled
- `services/firestore.googleapis.com` — no `enforcementMode` set, i.e.
  **UNENFORCED** (the default)
- No provider registered for the Android app yet

## What App Check does not fix

It stops scripted abuse of the backend. It does **not** stop a real person
installing the app, signing up, and registering as a driver — at which point the
Firestore rules let them read every open ride request. That is a signup-gating
problem: restrict registration to `@thapar.edu` addresses, and verify drivers
out of band before granting the driver role. See the role check in
[`firestore.rules`](../firestore.rules).
