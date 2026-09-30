import 'package:firebase_auth/firebase_auth.dart';
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
  /// tanlagichini hech kimni tanlamasdan yopsa `null` (xato emas, bekor
  /// qilish).
  ///
  /// `idToken == null` (bekor qilishdan farqli, haqiqiy sozlash xatosi)
  /// endi xato tashlaydi — avvalgidek sukut bilan `null` qaytarilsa,
  /// ikkalasi UI'da bir xil "hech narsa bo'lmadi" ko'rinishga ega bo'lib,
  /// haqiqiy nosozlikni bekor qilishdan ajratib bo'lmasdi.
  Future<String?> signIn() async {
    await _ensureInitialized();
    final String? googleIdToken;
    try {
      final GoogleSignInAccount account = await GoogleSignIn.instance.authenticate();
      googleIdToken = account.authentication.idToken;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    }
    if (googleIdToken == null) {
      throw StateError('Google ID token null — serverClientId sozlamasini tekshiring');
    }

    final UserCredential credential = await FirebaseAuth.instance.signInWithCredential(
      GoogleAuthProvider.credential(idToken: googleIdToken),
    );
    return credential.user?.getIdToken();
  }
}

final Provider<GoogleAuthDataSource> googleAuthDataSourceProvider =
    Provider<GoogleAuthDataSource>((ref) => GoogleAuthDataSource());
