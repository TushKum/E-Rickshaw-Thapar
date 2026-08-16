import 'package:erickshaw/screens/landingpage.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // App Check attests that traffic reaching Firestore comes from this app and
  // not from a script holding the (publicly readable) API key.
  //
  // Provider choice is forced by how the build is signed. Play Integrity only
  // attests apps installed from Play and signed with the Play signing key —
  // the release build here uses signingConfigs.debug and is sideloaded, so
  // Play Integrity would fail every request. Debug provider issues a local
  // token that must be registered per-device in the console instead.
  //
  // Enforcement is deliberately OFF in the console: turning it on now would
  // reject every sideloaded install. See docs/APP_CHECK.md before enabling.
  await FirebaseAppCheck.instance.activate(
    androidProvider:
        kDebugMode ? AndroidProvider.debug : AndroidProvider.playIntegrity,
  );

  runApp(const MaterialApp(
    home: Landing(),
  ));
}
