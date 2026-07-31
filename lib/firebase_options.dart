import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase konsolidagi "zukkor" loyihasi konfiguratsiyasi.
///
/// Hozircha faqat Android qo'llab-quvvatlanadi (Google Sign-In + FCM shu
/// platformada ishlatiladi). `flutterfire configure` CLI o'rniga qo'lda
/// yozilgan — qiymatlar `android/app/google-services.json`dan olingan.
abstract final class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('DefaultFirebaseOptions: web hali sozlanmagan.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions: $defaultTargetPlatform hali sozlanmagan.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC_UzxNRR0KKKDCViaSUhIdEqbCW7CJKks',
    appId: '1:555852548477:android:cd5b8cfd650fc02ea12414',
    messagingSenderId: '555852548477',
    projectId: 'zukkor',
    storageBucket: 'zukkor.firebasestorage.app',
  );
}
