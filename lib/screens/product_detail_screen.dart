import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products.dart';

class ProductDetailsScreen extends StatelessWidget {
  static const routeName = "/product-details/";
  // final String title;

  // // ignore: use_key_in_widget_constructors
  // const ProductDetailsScreen(this.title);

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context)?.settings.arguments as String;
    final loadedProducts =
        Provider.of<Products>(context, listen: false).findById(productId);

    return Scaffold(
      // appBar: AppBar(
      //   title: Text(loadedProducts.title),
      // ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(loadedProducts.title),
              background: Hero(
                tag: productId,
                child: Image.network(
                  loadedProducts.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverList(
              delegate: SliverChildListDelegate([
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  height: 300,
                  width: double.infinity,
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  's ${loadedProducts.price}',
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  width: double.infinity,
                  child: Text(
                    loadedProducts.description,
                    softWrap: true,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(
                  height: 500,
                ),
              ],
            )
          ]))
        ],
      ),
    );
  }
}
