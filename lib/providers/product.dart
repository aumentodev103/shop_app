import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isLiked;

  Product({
    this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isLiked = false,
  });

  // void toggleLikedStatus() {
  //   final oldStatus = isLiked;
  //   isLiked = !isLiked;
  //   notifyListeners();

  //   const url = 'flutter-sasta-shopify-default-rtdb.firebaseio.com';
  //   final dir = "/products/$id.json";
  //   final urlDir = Uri.https(url, dir);
  //   http.patch(url)
  // }

  Future<void> toggleLikedStatus(String token, String userId) async {
    final oldStatus = isLiked;
    isLiked = !isLiked;
    notifyListeners();
    const url = 'flutter-sasta-shopify-default-rtdb.firebaseio.com';
    final dir = "userFavs/$userId/$id.json";
    final params = {
      'auth': token,
    };
    final urlDir = Uri.https(url, dir, params);
    final bodyParams = json.encode(isLiked);
    try {
      await http.put(urlDir, body: bodyParams);
    } catch (error) {
      isLiked = oldStatus;
    }
    notifyListeners();
  }
}
