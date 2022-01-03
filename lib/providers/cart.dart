import 'package:flutter/material.dart';

class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;
  CartItem({
    required this.id,
    required this.title,
    required this.price,
    required this.quantity,
  });
}

class Cart with ChangeNotifier {
  Map<String, CartItem> _cartItemsList = {};

  Map<String, CartItem> get getCartItemsList {
    return {..._cartItemsList};
  }

  int get itemCount {
    // return _cartItemsList == null ? 0 : _cartItemsList.length;
    return _cartItemsList.length;
  }

  void addItem(String productId, double productPrice, String productTitle) {
    if (_cartItemsList.containsKey(productId)) {
      //Change qty..
      _cartItemsList.update(
        productId,
        (existingItem) => CartItem(
          id: existingItem.id,
          title: existingItem.title,
          price: existingItem.price,
          quantity: existingItem.quantity + 1,
        ),
      );
    } else {
      // Add product..
      _cartItemsList.putIfAbsent(
        productId,
        () => CartItem(
          id: DateTime.now().toString(),
          title: productTitle,
          price: productPrice,
          quantity: 1,
        ),
      );
    }
    notifyListeners();
  }

  double get totalAmount {
    double total = 0;
    _cartItemsList.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  removeItemFromCart(String id) {
    _cartItemsList.remove(id);
    notifyListeners();
  }

  void clearCart() {
    _cartItemsList = {};
    notifyListeners();
  }

  void removeSingleItem(String key) {
    if (!_cartItemsList.containsKey(key)) {
      return;
    } else {
      if (_cartItemsList[key]!.quantity > 1) {
        _cartItemsList.update(
          key,
          (item) => CartItem(
            id: item.id,
            title: item.title,
            price: item.price,
            quantity: item.quantity - 1,
          ),
        );
      } else {
        _cartItemsList.remove(key);
      }
    }
    notifyListeners();
  }
}
