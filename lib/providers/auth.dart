import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:shop_app/models/http_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  String? _uid;
  Timer? _authTimer;

  bool get isAuth {
    return token != "";
  }

  String get getUid {
    return _uid as String;
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate!.isAfter(DateTime.now()) &&
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
      _autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'uid': _uid,
        'expiryDate': _expiryDate!.toIso8601String(),
      });
      prefs.setString("userData", userData);
    } catch (error) {
      rethrow;
    }
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString("userData");
    if (!prefs.containsKey("userData")) {
      return false;
    }

    final extractedUserData = jsonDecode(data!) as Map<String, Object>;
    final expiryDate =
        DateTime.parse(extractedUserData["expiryDate"] as String);
    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    _token = extractedUserData["token"] as String;
    _uid = extractedUserData["uid"] as String;
    _expiryDate = extractedUserData["expiryDate"] as DateTime;
    notifyListeners();
    _autoLogout();
    return true;
  }

  Future<void> signUp(String email, String password) async {
    return _authenticateUser(email, password, "signUp");
  }

  Future<void> signIn(String email, String password) async {
    return _authenticateUser(email, password, "signInWithPassword");
  }

  Future<void> logOut() async {
    print("Auto logging out...");
    _token = "";
    _uid = "";
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer!.cancel();
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.remove("userData");
    prefs.clear();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer!.cancel();
    }
    final timeLeftForTokenExpiration =
        _expiryDate!.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeLeftForTokenExpiration), logOut);
  }
}
