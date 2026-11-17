// Firebase configuration for the game (project "spaceshooter-7781b").
//
// Configured for Android and the web. On other platforms the game runs
// offline (no account creation, no online scoreboard).
//
// These keys are meant to ship inside the app; they are not secrets. Access
// to the data is controlled by the Firestore security rules, and each key is
// restricted in Google Cloud to its own app (Android package / website).
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    if (defaultTargetPlatform == TargetPlatform.android) return android;
    throw UnsupportedError(
      'Firebase is only configured for Android and the web.',
    );
  }

  // Firebase web app "Space Shooter 2400 Web".
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBjsqpeU_jg78PEv4NTl-9Q5KUYGmveQO4',
    appId: '1:167184316607:web:4b99ff6a06dc3575c3ee0a',
    messagingSenderId: '167184316607',
    projectId: 'spaceshooter-7781b',
    authDomain: 'spaceshooter-7781b.firebaseapp.com',
    storageBucket: 'spaceshooter-7781b.firebasestorage.app',
    measurementId: 'G-P0703NSDYD',
  );

  // Values from android/app/google-services.json (Firebase Android app
  // com.example.space_shooter_2400).
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCa2u-819bi9YlGqgpSenuqTHM3CJQ6J9A',
    appId: '1:167184316607:android:d76483b69d1ec4cfc3ee0a',
    messagingSenderId: '167184316607',
    projectId: 'spaceshooter-7781b',
    storageBucket: 'spaceshooter-7781b.firebasestorage.app',
  );
}
