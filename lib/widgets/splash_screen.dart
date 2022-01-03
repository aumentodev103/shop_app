import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: Image.network(
                "https://1000logos.net/wp-content/uploads/2020/08/Shopify-Logo.png",
                fit: BoxFit.contain,
              ),
            ),
            const Text(
              "Sasta Shopify",
              style: TextStyle(color: Colors.deepPurple, fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }
}
