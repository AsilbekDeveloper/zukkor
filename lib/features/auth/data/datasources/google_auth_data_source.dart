import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/config/app_config.dart';

/// Google hisob tanlagichini ochib, natijasini Firebase Auth orqali
/// almashtiradi — backendga xom Google ID token emas, Firebase ID token
/// yuboriladi (backend uni Firebase Admin SDK bilan tekshiradi).
class GoogleAuthDataSource {
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await GoogleSignIn.instance.initialize(
      serverClientId: AppConfig.googleServerClientId.isEmpty ? null : AppConfig.googleServerClientId,
    );
    _initialized = true;
  }

  /// Backendga yuboriladigan Firebase ID token — foydalanuvchi hisob
  /// tanlagichini hech kimni tanlamasdan yopsa `null` (xato emas).
  ///
  /// TEMP DIAGNOSTIC (2026-09-30): `idToken == null` avval sukut bilan
  /// bekor qilish (`null`) deb hisoblanardi — bu bekor qilish bilan
  /// haqiqiy sozlash xatosini (masalan noto'g'ri `serverClientId`) bir-
  /// biridan ajratmasdi, shuning uchun foydalanuvchiga hech qanday xato
  /// ko'rinmasdi. Endi aniq log chiqaradi va xato tashlaydi — muammo
  /// topilgach, bu diagnostika olib tashlanadi.
  Future<String?> signIn() async {
    await _ensureInitialized();
    final String? googleIdToken;
    try {
      final GoogleSignInAccount account = await GoogleSignIn.instance.authenticate();
      googleIdToken = account.authentication.idToken;
      debugPrint('[ZUKKOR-DIAG] Google account: ${account.email}, idToken null? ${googleIdToken == null}');
    } on GoogleSignInException catch (e) {
      debugPrint('[ZUKKOR-DIAG] GoogleSignInException code=${e.code} description=${e.description}');
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    }
    if (googleIdToken == null) {
      throw StateError('Google ID token null — serverClientId sozlamasini tekshiring');
    }

    final UserCredential credential = await FirebaseAuth.instance.signInWithCredential(
      GoogleAuthProvider.credential(idToken: googleIdToken),
    );
    debugPrint('[ZUKKOR-DIAG] Firebase sign-in ok, uid=${credential.user?.uid}');
    return credential.user?.getIdToken();
  }
}

final Provider<GoogleAuthDataSource> googleAuthDataSourceProvider =
    Provider<GoogleAuthDataSource>((ref) => GoogleAuthDataSource());
