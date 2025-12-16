class AccessTokenExpiredException implements Exception {
  final String cause;
  const AccessTokenExpiredException(this.cause);
}
