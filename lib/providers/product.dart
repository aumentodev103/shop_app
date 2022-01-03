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

  Future<void> toggleLikedStatus() async {
    final oldStatus = isLiked;
    isLiked = !isLiked;
    notifyListeners();
    const url = 'flutter-sasta-shopify-default-rtdb.firebaseio.com';
    final dir = "/products/$id.json";
    final urlDir = Uri.https(url, dir);
    final bodyParams = json.encode({"isLiked": isLiked});
    try {
      final response = await http.patch(urlDir, body: bodyParams);
    } catch (error) {
      isLiked = oldStatus;
    }
    notifyListeners();
  }
}
