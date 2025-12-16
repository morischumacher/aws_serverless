import 'package:jwt_decoder/jwt_decoder.dart';

class JwtToken {
  final String _token;

  JwtToken(this._token);

  String getValue() {
    return _token;
  }

  bool isExpired() {
    return JwtDecoder.isExpired(_token);
  }

  DateTime? getExpiryDate() {
    return JwtDecoder.getExpirationDate(_token);
  }

  Map<String, dynamic> getInfo() {
    return JwtDecoder.decode(_token);
  }

  Map<String, String> getBearerHeader() {
    return {'Authorization': 'Bearer $_token'};
  }

  String getEmail() {
    return getInfo()['username'];
  }

  String getUserId() {
    return getInfo()['sub'];
  }

  String getUserName() {
    return getInfo()['name'] ?? '';
  }
}
