// ignore_for_file: use_rethrow_when_possible, avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class NetworkUtil {
  final String baseUrl = 'http://165.227.117.48';
  void Function()? onUnauthorized;

  NetworkUtil({this.onUnauthorized});


  void _processResponse(http.Response response) {
    if (response.statusCode == 401) {
      StorageUtil.deleteToken();
      StorageUtil.deleteUsername();
      if (onUnauthorized != null) {
        onUnauthorized!();
      }
    }
  }

  /// Performs a POST request to the specified [path] with the given [body].
  /// Automatically adds authorization header if a token exists.
  Future<http.Response> post(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl/$path');
    final token = await StorageUtil.getToken();
    final response = await http.post(
      uri,
      headers: _generateHeaders(token),
      body: json.encode(body),
    );
    _processResponse(response);
    return response;
  }

  /// Deletes a game entry by its [gameId].
  Future<http.Response> deleteGame(int gameId) async {
    final uri = Uri.parse('$baseUrl/games/$gameId');
    final token = await StorageUtil.getToken();
    final response = await http.delete(
      uri,
      headers: _generateAuthorizationHeader(token),
    );
    _processResponse(response);
    return response;
  }

  /// Fetches games list from the server.
  Future<http.Response> getGames() async {
    final uri = Uri.parse('$baseUrl/games');
    final token = await StorageUtil.getToken();
    final response = await http.get(
      uri,
      headers: _generateHeaders(token),
    );
    _processResponse(response);
    return response;
  }

  /// Retrieves details of a specific game by its [gameId].
  Future<http.Response> getGame(int gameId) async {
    final uri = Uri.parse('$baseUrl/games/$gameId');
    final token = await StorageUtil.getToken();
    try {
      final response = await http.get(
        uri,
        headers: _generateAuthorizationHeader(token),
      );
      print("getGame Response: ${response.statusCode} - ${response.body}");
      _processResponse(response);
      return response;
    } catch (e) {
      print("Error in getGame: $e");
      throw e;
    }
  }

  /// Updates data on a specific path with the given [body].
  Future<http.Response> put(String path, String body) async {
    final uri = Uri.parse('$baseUrl/$path');
    final token = await StorageUtil.getToken();
    final response = await http.put(
      uri,
      headers: _generateHeaders(token),
      body: body,
    );
    _processResponse(response);
    return response;
  }

  /// Generates HTTP headers including Content-Type and Authorization.
  Map<String, String> _generateHeaders(String? token) => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  /// Generates only the Authorization header.
  Map<String, String> _generateAuthorizationHeader(String? token) => {
        if (token != null) 'Authorization': 'Bearer $token',
      };
}

/// Provides utilities for managing local storage, especially for authentication tokens and user credentials.
class StorageUtil {
  // Method descriptions and functionalities are extended for clarity and comprehensive handling.

  static Future<void> storeToken(String token) async {
    final SharedPreferences prefs = await _getPrefs();
    await prefs.setString('access_token', token);
  }

  static Future<void> storeUsername(String username) async {
    final SharedPreferences prefs = await _getPrefs();
    await prefs.setString('username', username);
  }

  static Future<String?> getUsername() async {
    final SharedPreferences prefs = await _getPrefs();
    return prefs.getString('username');
  }

  static Future<void> deleteUsername() async {
    final SharedPreferences prefs = await _getPrefs();
    await prefs.remove('username');
  }

  static Future<bool> hasValidToken() async {
    final SharedPreferences prefs = await _getPrefs();
    final String? token = prefs.getString('access_token');
    return token != null;
  }

  static Future<String?> getToken() async {
    final SharedPreferences prefs = await _getPrefs();
    return prefs.getString('access_token');
  }

  static Future<void> deleteToken() async {
    final SharedPreferences prefs = await _getPrefs();
    await prefs.remove('access_token');
  }

  /// Returns an instance of [SharedPreferences].
  static Future<SharedPreferences> _getPrefs() => SharedPreferences.getInstance();
}

/// Utility class for validating usernames and passwords.
class ValidationUtil {
  /// Validates if a [username] adheres to specified rules.
  static bool isValidUsername(String username) => username.length >= 3 && !username.contains(' ');

  /// Validates if a [password] adheres to specified rules.
  static bool isValidPassword(String password) => password.length >= 3 && !password.contains(' ');
}
