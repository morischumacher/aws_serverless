import 'package:aic_ui/src/api/api_client.dart';
import 'package:aic_ui/src/models/login_request.dart';
import 'package:aic_ui/src/models/reqister_request.dart';
import 'package:aic_ui/src/service/jwt_token.dart';
import 'package:aic_ui/src/service/secure_storage.dart';
import 'dart:convert';

class AuthApi {
  // reference to BaseClient object
  final ApiClient _client = ApiClient();
  // reference to SecureStorage object
  final SecureStorage _secureStorage = SecureStorage();

  final String signinUrl = '/signin';
  final String signupUrl = '/signup';

  Future<bool> login(String email, String password) async {
    final loginRequest = LoginRequest(email, password);
    try {
      final response =
          await _client.unauthenticatedPost(signinUrl, loginRequest.toJson());
      if (response.statusCode == 200) {
        //Login Successfull
        final Map<String, dynamic> responseBody = json.decode(response.body);
        if (responseBody.containsKey('AuthenticationResult')) {
          final accessToken =
              JwtToken(responseBody['AuthenticationResult']['AccessToken']);

          await _secureStorage.setAccessToken(accessToken);

          final idToken =
              JwtToken(responseBody['AuthenticationResult']['IdToken']);

          await _secureStorage.setIdToken(idToken);
        }
        return true;
      } else if (response.statusCode == 422) {
        //Login Unsucessfull
        return false;
      }
    } catch (e) {}
    return false;
  }

  Future<bool> register(String email, String name, String password) async {
    final registerRequest = RegisterRequest(email, name, password);

    final response =
        await _client.unauthenticatedPost(signupUrl, registerRequest.toJson());
    if (response.statusCode == 200) {
      //Register Successfull
      final Map<String, dynamic> responseBody = json.decode(response.body);
      // Todo: add additional checks
      //if (responseBody.containsKey('something')) {
      //}
      return true;
    } else {
      //Register Unsucessfull
      return false;
    }
  }
}
