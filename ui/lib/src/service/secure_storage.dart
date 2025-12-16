import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'jwt_token.dart';

class SecureStorage {
  // reference to FlutterSecureStorage object
  final FlutterSecureStorage _storage;

  // creating a single instance with the private named constructor
  static final SecureStorage _instance =
      SecureStorage._(const FlutterSecureStorage());

  // using private named constructor to initialize FlutterSecureStorage object
  SecureStorage._(this._storage);

  // using factory constructor to always return the same instance
  factory SecureStorage() => _instance;

  Future<JwtToken?> getAccessToken() async {
    String? value = await _storage.read(key: 'accessToken');

    return value == null ? null : JwtToken(value);
  }

  Future<bool> containsAccessToken() async {
    return await _storage.containsKey(key: 'accessToken');
  }

  Future<bool> containsIdToken() async {
    return await _storage.containsKey(key: 'idToken');
  }

  Future<void> setAccessToken(JwtToken token) async {
    await _storage.write(key: 'accessToken', value: token.getValue());
  }

  Future<void> deleteAccessToken() async {
    await _storage.delete(key: 'accessToken');
  }

  Future<void> setIdToken(JwtToken token) async {
    await _storage.write(key: 'idToken', value: token.getValue());
  }

  Future<JwtToken?> getIdToken() async {
    String? value = await _storage.read(key: 'idToken');

    return value == null ? null : JwtToken(value);
  }

  Future<void> deleteIdToken() async {
    await _storage.delete(key: 'idToken');
  }

  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
}
