import 'package:flutter/material.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> cartItems;
  final DateTime dateTime;

  OrderItem({
    required this.id,
    required this.amount,
    required this.cartItems,
    required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  late List<OrderItem> _orderItems = [];

  List<OrderItem> get getOrderItems {
    return [..._orderItems];
  }

  // void placeNewOrder(List<CartItem> cartItems, double total) {
  //   _orderItems.insert(
  //     0,
  //     OrderItem(
  //       id: DateTime.now().toString(),
  //       amount: total,
  //       cartItems: cartItems,
  //       dateTime: DateTime.now(),
  //     ),
  //   );
  //   notifyListeners();
  // }

  //Place New Order
  Future<void> placeNewOrder(List<CartItem> cartItems, double total) async {
    const url = 'flutter-sasta-shopify-default-rtdb.firebaseio.com';
    final dateTime = DateTime.now();
    const dir = "/orders.json";
    final urlDir = Uri.https(url, dir);
    final bodyParams = json.encode({
      "amount": total,
      "cartItems": cartItems
          .map((cartItem) => {
                "id": cartItem.id,
                "title": cartItem.title,
                "quantity": cartItem.quantity,
                "price": cartItem.price,
              })
          .toList(),
      "dateTime": dateTime.toIso8601String(),
    });
    try {
      final response = await http.post(urlDir, body: bodyParams);
      _orderItems.insert(
        0,
        OrderItem(
          id: json.decode(response.body)["name"],
          amount: total,
          cartItems: cartItems,
          dateTime: dateTime,
        ),
      );
      notifyListeners();
      //  productList.insert(0,newProduct); this will add it on the top of the list.
      // return Future.value();
    } catch (error) {
      rethrow;
    }
  }

// Fetch Orders from firebase
  Future<void> fetchAndLoadOrders() async {
    debugPrint("Fetchiing Orders...");
    _orderItems = [];
    const url = 'flutter-sasta-shopify-default-rtdb.firebaseio.com';
    const dir = "/orders.json";
    final urlDir = Uri.https(url, dir);

    try {
      final reponse = await http.get(urlDir);
      final List<OrderItem> loadedOrders = [];
      var ordersJson = json.decode(reponse.body) as Map<String, dynamic>;
      if (ordersJson == null) {
        return;
      }
      if (json.decode(reponse.body) != null) {
        ordersJson.forEach((orderId, orderData) {
          print(orderData["cartItems"]);
          loadedOrders.add(OrderItem(
            id: orderId,
            amount: orderData["amount"],
            dateTime: DateTime.parse(orderData["dateTime"]),
            cartItems: (orderData["cartItems"] as List<dynamic>)
                .map((item) => CartItem(
                      id: item["id"],
                      price: item["price"],
                      quantity: item["quantity"],
                      title: item["title"],
                    ))
                .toList(),
          ));
          _orderItems = loadedOrders;
          notifyListeners();
        });
      }
    } catch (error) {
      rethrow;
    }
  }
}
