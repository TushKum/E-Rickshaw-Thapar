# Running the app

## Before anything works: enable sign-in

The app builds and launches today, but **login and signup fail** until the
Email/Password provider is switched on. It is a console-only toggle on the
Spark plan — no CLI or API can do it.

**Console → Authentication → Get started → Email/Password → Enable → Save**
https://console.firebase.google.com/project/erickshaw-thapar-7030/authentication/providers

Until then you will reach the Log In / Sign Up screens and go no further.

---

## Android — the real target

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk` (~52 MB).

No `JAVA_HOME` needed — `flutter config --jdk-dir` is already pointed at
JDK 17, which is what AGP 8.6 requires. (The Firestore emulator needs JDK 21+
instead; see the rules tests below. The two are separate on purpose.)

### Onto a phone

With a device attached over USB and debugging enabled:

```bash
flutter run --release
```

Or sideload the APK. Serve it on the LAN:

```bash
cd build/app/outputs/flutter-apk
python3 -m http.server 8000 --bind 0.0.0.0
```

Then open `http://<your-mac-ip>:8000/app-release.apk` on the phone — find the
IP with `ipconfig getifaddr en0`. The phone must be on the same Wi-Fi, and
Android will ask permission to install from an unknown source.

Two things that bite here: the IP is DHCP and **changes** (it moved three times
while this was being set up), and the server dies when the Mac sleeps. Re-check
the IP before sharing a link or QR.

---

## Web — dev preview only

```bash
flutter build web --release
cd build/web && python3 -m http.server 8899 --bind 127.0.0.1
```

Open http://127.0.0.1:8899. Or with Chrome installed, just `flutter run -d chrome`.

This is for looking at the UI without a phone. It is a phone-shaped layout in a
browser, and App Check is skipped on web (its provider is reCAPTCHA and no site
key is configured).

---

## iOS and macOS — not currently possible

Both need **full Xcode**; this machine has only the Command Line Tools, so
there is no `xcodebuild` and `xcrun simctl` lists no simulators. macOS appears
in `flutter devices`, but Flutter builds desktop through `xcodebuild` too, so it
fails for the same reason.

Install Xcode from the App Store (~15 GB), then:

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

iOS additionally needs Firebase set up — it is deliberately unconfigured, and
`firebase_options.dart` throws for it rather than silently falling back to the
upstream project's credentials:

```bash
flutterfire configure --project=erickshaw-thapar-7030 --platforms=ios
```

Also set the bundle identifier to `edu.thapar.erickshaw` in Xcode, to match
Android.

---

## Security rules tests

```bash
cd test/rules && npm install && npm test
```

Needs **Java 21+** — the emulator refuses anything older, while the Android
build needs 17. If your default JDK is 17:

```bash
JAVA_HOME=$(/usr/libexec/java_home -v 21) npm test
```

21 tests, no live project or credentials involved. See
[test/rules/README.md](../test/rules/README.md).

---

## Deploying rules changes

```bash
firebase deploy --only firestore:rules --project=erickshaw-thapar-7030
```

Run the tests first.
