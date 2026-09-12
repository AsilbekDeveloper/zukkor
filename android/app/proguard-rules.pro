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
