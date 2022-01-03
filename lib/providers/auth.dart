import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';

class Auth with ChangeNotifier {
  String? _token;
  DateTime _expiryDate = DateTime.now();
  late String _uid;

  bool get isAuth {
    print("token is ${token == ""} ---- ${token != ""}");
    if (token == "") {
      return false;
    } else {
      return true;
    }
  }

  String get token {
    if (_expiryDate != DateTime.now() &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != "") {
      return _token as String;
    }
    return "";
  }

  final apiKey = "AIzaSyC7Yw17KxbqxrAOinwsxZVx-6mUkEXXChQ";
  Future<void> _authenticateUser(
      String email, String password, String authType) async {
    print(authType);
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
      print(responseData.toString());

      if (responseData["error"] != null) {
        throw HttpException(responseData["error"]);
      }
      _token = responseData["idToken"];
      _uid = responseData["localId"];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(responseData["expiresIn"]),
        ),
      );
      // isUserLoggedIn = true;

    } catch (error) {
      rethrow;
    }
    notifyListeners();
  }

  Future<void> signUp(String email, String password) async {
    return _authenticateUser(email, password, "signUp");
  }

  Future<void> signIn(String email, String password) async {
    return _authenticateUser(email, password, "signInWithPassword");
  }
}
