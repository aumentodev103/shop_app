import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shop_app/providers/orders.dart' as ord;

class OrderItemWidget extends StatefulWidget {
  final ord.OrderItem order;

  const OrderItemWidget({Key? key, required this.order}) : super(key: key);

  @override
  State<OrderItemWidget> createState() => _OrderItemWidgetState();
}

class _OrderItemWidgetState extends State<OrderItemWidget> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height:
          _expanded ? min(widget.order.cartItems.length * 20 + 110, 200) : 95,
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.all(10),
        child: Column(
          children: [
            ListTile(
              title: const Text("Total amount"),
              subtitle:
                  Text(DateFormat("dd-MM-yyyy").format(widget.order.dateTime)),
              trailing: IconButton(
                icon: _expanded
                    ? const Icon(Icons.expand_less)
                    : const Icon(Icons.expand_more),
                onPressed: () {
                  setState(() {
                    _expanded = !_expanded;
                  });
                },
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 14),
              height: _expanded
                  ? min(widget.order.cartItems.length * 20 + 10, 180)
                  : 0,
              // child: ListView.builder(itemCount:widget.order.cartItems.length , itemBuilder: (context, index) => ,),
              child: ListView(
                children: widget.order.cartItems
                    .map(
                      (item) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "${item.quantity} x ${item.price}",
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
