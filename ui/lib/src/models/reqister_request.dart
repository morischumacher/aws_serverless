class RegisterRequest {
  String? _email;
  String? _name;
  String? _password;
  RegisterRequest(String? email, String? name, String? password) {
    if (email != null) {
      _email = email;
    }
    if (password != null) {
      _password = password;
    }
    if (name != null) {
      _name = name;
    }
  }

  RegisterRequest.fromJson(Map<String, dynamic> json) {
    _email = json['email'];
    _name = json['name'];
    _password = json['password'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['email'] = '$_email';
    data['name'] = '$_name';
    data['password'] = '$_password';
    return data;
  }
}
