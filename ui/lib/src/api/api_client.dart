import 'dart:convert';
import 'package:http/http.dart';
import 'package:aic_ui/src/service/secure_storage.dart';
import 'package:aic_ui/src/api/api.dart';
import 'package:aic_ui/src/service/jwt_token.dart';
import 'package:aic_ui/src/exceptions/access_token_expired_exception.dart';
import 'package:aic_ui/src/exceptions/unauthenticated_user_exception.dart';

class ApiClient {
  // reference to BaseClient object
  final Client _client = Client();
  // reference to SecureStorage object
  final SecureStorage _secureStorage = SecureStorage();

  final String _baseUrl = Api().baseUrl;

  final Map<String, String> _headers = {};

  String getBaseUrl() {
    return _baseUrl;
  }

  //GET
  Future<Response> get(String api, {Map<String, String>? headers}) async {
    final url = Uri.parse(_baseUrl + api);
    await checkAccessToken(_secureStorage);
    final headersCombined = {
      ..._headers,
      ...?headers,
    };

    final response = await _client.get(url, headers: headersCombined);
    return response;
  }

  //POST
  Future<Response> post(String api, dynamic object,
      {Map<String, String>? headers}) async {
    final url = Uri.parse(_baseUrl + api);
    final payload = json.encode(object);

    await checkAccessToken(_secureStorage);
    final headersCombined = {
      'content-type': 'application/json',
      ..._headers,
      ...?headers,
    };

    //final response = await client.post(url, 4body: object);
    final response =
        await _client.post(url, body: payload, headers: headersCombined);
    return response;
  }

  //POST Login
  Future<Response> unauthenticatedPost(String api, dynamic object,
      {Map<String, String>? headers}) async {
    final url = Uri.parse(_baseUrl + api);

    final payload = json.encode(object);

    final headersCombined = {
      'content-type': 'application/json',
      ..._headers,
      ...?headers,
    };

    final response =
        await _client.post(url, body: payload, headers: headersCombined);
    return response;
  }

  Future<bool> checkAccessToken(SecureStorage secureStorage) async {
    if (await secureStorage.containsAccessToken()) {
      final JwtToken? accessToken = await secureStorage.getAccessToken();
      if (!accessToken!.isExpired()) {
        _headers.addAll(accessToken.getBearerHeader());
        return true;
      } else {
        secureStorage.deleteAccessToken();
        _headers.remove('Authorization');
        throw AccessTokenExpiredException(
            'Access Token Expired on $accessToken.getExpiryDate()');
      }
    } else {
      throw const UnauthenticatedUserException(
          'User is not Authenticated. No JWT Token were found in SecureStorage.');
    }
  }
}
