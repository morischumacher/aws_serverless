class UnauthenticatedUserException implements Exception {
  final String cause;
  const UnauthenticatedUserException(this.cause);
}
