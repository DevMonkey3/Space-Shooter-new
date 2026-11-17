// Firebase configuration for the game (project "spaceshooter-7781b").
//
// Only Android is configured. On other platforms the game runs offline
// (no account creation, no online scoreboard). If you ever recreate the
// Firebase app, copy the new values from android/app/google-services.json
// into [DefaultFirebaseOptions.android].
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      throw UnsupportedError(
        'Firebase is only configured for Android in this project.',
      );
    }
    if (android.apiKey.isEmpty) {
      throw UnsupportedError(
        'Firebase is not configured yet. See lib/firebase_options.dart.',
      );
    }
    return android;
  }

  // Values from android/app/google-services.json (Firebase project
  // "SpaceShooter", Android app com.example.space_shooter_2400).
  static const FirebaseOptions android = FirebaseOptions(
    // client[0].api_key[0].current_key
    apiKey: 'AIzaSyCa2u-819bi9YlGqgpSenuqTHM3CJQ6J9A',
    // client[0].client_info.mobilesdk_app_id
    appId: '1:167184316607:android:d76483b69d1ec4cfc3ee0a',
    // project_info.project_number
    messagingSenderId: '167184316607',
    // project_info.project_id
    projectId: 'spaceshooter-7781b',
    // project_info.storage_bucket
    storageBucket: 'spaceshooter-7781b.firebasestorage.app',
  );
}
