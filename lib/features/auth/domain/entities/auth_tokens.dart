/// `/auth/register`, `/auth/login` va `/auth/refresh` javobidagi token
/// juftligi. `token_type` doim `"bearer"` bo'lgani uchun bu yerda saqlanmaydi
/// — [AuthInterceptor] `Authorization` header'ni o'zi shakllantiradi.
class AuthTokens {
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
  });

  final String accessToken;
  final String refreshToken;
}
