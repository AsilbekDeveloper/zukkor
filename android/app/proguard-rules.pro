# R8/ProGuard qo'shimcha qoidalari (2026-09-13, isMinifyEnabled=true bilan
# birga qo'shildi). Bo'sh boshlanadi - loyihadagi barcha pluginlar
# (Firebase, google_sign_in, flutter_local_notifications va h.k.) o'z
# saqlanishi kerak bo'lgan sinflarini AAR ichidagi consumer-rules.pro
# fayllari orqali o'zi e'lon qiladi, AGP buni avtomatik birlashtiradi -
# qo'lda qoida yozish odatda shart emas.
#
# Agar release build'da (debug'da yo'q, faqat release'da) kutilmagan
# ClassNotFoundException/NoSuchMethodError chiqsa - sababi shu yerda
# tasodifan siqib tashlangan bir sinf bo'lishi mumkin. O'sha aniq sinf
# uchun `-keep class <to'liq.nomi> { *; }` qatorini shu yerga qo'shish
# kifoya, butun minifikatsiyani o'chirish shart emas.

# Google Sign-In / Credential Manager (2026-10-01): Play Store'dan
# o'rnatilgan release build'da Google bilan kirish "[16] Account reauth
# failed" (GoogleSignInExceptionCode.canceled) bilan sukut saqlab
# muvaffaqiyatsiz bo'lardi - barcha SHA-1/serverClientId sozlamalari
# to'g'ri bo'lsa ham. `androidx.credentials`ning Play Services provayderi
# reflection orqali topiladi, AAR'dagi consumer-rules yetarli bo'lmasa R8
# uni "ishlatilmayapti" deb olib tashlaydi - shu holatda xato aynan shu
# generik "canceled" ko'rinishida chiqadi (google_sign_in_android'ning
# o'z hujjatida tasdiqlangan tanish ko'rinish).
-keep class androidx.credentials.playservices.** { *; }
-keep class com.google.android.gms.auth.api.identity.** { *; }
-keep class com.google.android.gms.auth.api.signin.** { *; }
-keep class com.google.android.libraries.identity.googleid.** { *; }
