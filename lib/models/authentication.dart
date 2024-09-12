// ignore_for_file: unnecessary_this

class AuthResponse {
  final String accessToken;

  AuthResponse({required this.accessToken});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('access_token') || json['access_token'] == null) {
      throw const FormatException('Invalid JSON: missing "access_token"');
    }
    String accessTokenValue = json['access_token'];
    if (accessTokenValue.isEmpty) {
      throw const FormatException('Invalid JSON: "access_token" is empty');
    }
    return AuthResponse(
      accessToken: accessTokenValue,
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['access_token'] = this.accessToken;
    return json;
  }
}

class User {
  final String username;
  final String password;

  User({required this.username, required this.password}) {
    ValidationHelper.validateUsername(username);
    ValidationHelper.validatePassword(password);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {};
    map['username'] = this.username;
    map['password'] = this.password;
    return map;
  }

  factory User.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('username') || !json.containsKey('password')) {
      throw const FormatException('Invalid JSON: missing "username" or "password"');
    }
    String username = json['username'];
    String password = json['password'];
    return User(username: username, password: password);
  }
}

class ValidationHelper {
  static void validateUsername(String username) {
    if (username.length < 3 || username.contains(' ')) {
      throw ArgumentError(
          'Username must be at least 3 characters long and cannot contain spaces.');
    }
  }

  static void validatePassword(String password) {
    if (password.length < 3 || password.contains(' ')) {
      throw ArgumentError(
          'Password must be at least 3 characters long and cannot contain spaces.');
    }
  }
}
