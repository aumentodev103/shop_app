import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';

class Auth with ChangeNotifier {
  late String _token;
  late DateTime _expiryDate;
  late String _uid;

  bool get isUserLoggedIn {
    return authToken != null;
  }

  String get authToken {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return "";
  }

  final apiKey = "AIzaSyC7Yw17KxbqxrAOinwsxZVx-6mUkEXXChQ";
  Future<void> _authenticateUser(
      String email, String password, String authType) async {
    var url = Uri.parse(
        "https://identitytoolkit.googleapis.com/v1/accounts:$authType?key=$apiKey");
    final bodyParams = json.encode({
      "email": email,
      "password": password,
      "returnSecureToken": true,
    });
    try {
      final response = await http.post(url, body: bodyParams);
      final responseData = json.decode(response.body);
      if (responseData["error"]) {
        throw HttpException(responseData["error"]["message"]);
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> signUp(String email, String password) async {
    return _authenticateUser(email, password, "signUp");
  }

  Future<void> signIn(String email, String password) async {
    return _authenticateUser(email, password, "signInWithPassword");
  }
}
