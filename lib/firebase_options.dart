import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web is not supported in this app.');
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'This platform is not supported. Only Android is configured.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCt1B6Pw6JSbVxDx88aVAx3yiuznXCk4Xw',
    appId: '1:582203744639:android:8dbf613c3b7d775168ba4a',
    messagingSenderId: '582203744639',
    projectId: 'kigali-app-b9562',
    storageBucket: 'kigali-app-b9562.firebasestorage.app',
  );
}