import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shop_app/providers/product.dart';
import 'package:http/http.dart' as http;

class Products with ChangeNotifier {
  // var _showLikedOnly = false;

  late List<Product> productList = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  List<Product> get items {
    // if (_showLikedOnly) {
    //   return productList.where((element) => element.isLiked).toList();
    // }
    return [...productList];
  }

  Product findById(String id) {
    final itemHasId = productList.firstWhere((element) => element.id == id);
    print("${id} == ${itemHasId.id}");
    return itemHasId;
  }

  List<Product> get likedItems {
    return productList.where((element) => element.isLiked).toList();
  }

  // void showLikedOnly() {
  //   _showLikedOnly = true;
  //   notifyListeners();
  // }

  // void showALL() {
  //   _showLikedOnly = false;
  //   notifyListeners();
  // }

  // Add Product to firebase
  Future<void> addProduct(Product product) async {
    const url = 'flutter-sasta-shopify-default-rtdb.firebaseio.com';
    const dir = "/products.json";
    final urlDir = Uri.https(url, dir);
    final bodyParams = json.encode({
      "id": DateTime.now().toString(),
      "title": product.title,
      "description": product.description,
      "price": product.price,
      "imageUrl": product.imageUrl,
      "isLiked": product.isLiked,
    });
    try {
      final response = await http.post(urlDir, body: bodyParams);
      final newProduct = Product(
        id: json.decode(response.body)["name"],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );
      productList.add(newProduct);

      notifyListeners();
      //  productList.insert(0,newProduct); this will add it on the top of the list.
      // return Future.value();
    } catch (error) {
      rethrow;
    }
  }

  // Update Product to firebase
  Future<void> updateProduct(String id, Product updatedProduct) async {
    final productIndex = productList.indexWhere((element) => element.id == id);
    if (productIndex >= 0) {
      const url = 'flutter-sasta-shopify-default-rtdb.firebaseio.com';
      final dir = "/products/$id.json";
      final urlDir = Uri.https(url, dir);
      final bodyParams = json.encode({
        "title": updatedProduct.title,
        "description": updatedProduct.description,
        "price": updatedProduct.price,
        "imageUrl": updatedProduct.imageUrl,
      });

      final response = await http.patch(urlDir, body: bodyParams);

      productList[productIndex] = updatedProduct;
      notifyListeners();
    } else {
      print(".. product not present");
    }
  }

  // Delete Product to firebase
  Future<void> deleteProduct(String id) async {
    const url = 'flutter-sasta-shopify-default-rtdb.firebaseio.com';
    final dir = "/products/$id.json";
    final urlDir = Uri.https(url, dir);
    final existingProductIndex =
        productList.indexWhere((element) => element.id == id);
    var existingProduct = productList[existingProductIndex];
    print(existingProduct.id);

    final response = await http.delete(urlDir);
    if (response.statusCode < 400) {
      productList.removeAt(existingProductIndex);
      notifyListeners();
    } else {
      productList.insert(existingProductIndex, existingProduct);
      notifyListeners();
    }
    // http.delete(urlDir).then((value) {
    //   existingProduct = null as Product;
    //   productList.removeAt(existingProductIndex);
    //   notifyListeners();
    // }).catchError((error) {
    //   print(error.toString());
    //   productList.insert(existingProductIndex, existingProduct);
    //   notifyListeners();
    // });
  }

  // Fetch Products from firebase
  Future<void> fetchAndLoadProducts() async {
    debugPrint("Fetchiing.......");
    productList = [];
    const url = 'flutter-sasta-shopify-default-rtdb.firebaseio.com';
    const dir = "/products.json";
    final urlDir = Uri.https(url, dir);

    try {
      final reponse = await http.get(urlDir);
      final productJson = json.decode(reponse.body) as Map<String, dynamic>;
      if (json.decode(reponse.body) != null) {
        productJson.forEach((productId, productData) {
          final object = Product(
            id: productId,
            title: productData["title"],
            description: productData["description"],
            price: productData["price"],
            imageUrl: productData["imageUrl"],
            isLiked: productData["isLiked"],
          );
          productList.add(object);
          notifyListeners();
        });
      }
    } catch (error) {
      rethrow;
    }
  }
}
