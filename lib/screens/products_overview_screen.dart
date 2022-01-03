import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/providers/products.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/badge.dart';
import '../widgets/products_grid.dart';

enum FilterOptions { Liked, All }

class ProductsOverviewScreen extends StatefulWidget {
  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  bool _showLikedOnly = false;
  bool _isInit = true;
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    // Provider.of<Products>(context).fetchAndLoadProducts(); //Wont work because we can't get context in initState();
    // Future.delayed(Duration.zero)
    //     .then((_) => Provider.of<Products>(context).fetchAndLoadProducts());
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    if (_isInit) {
      setState(() => _isLoading = true);

      Provider.of<Products>(context).fetchAndLoadProducts().then((_) {
        setState(() => _isLoading = false);
      });
    }
    _isInit = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sasta Shopify"),
        actions: [
          PopupMenuButton(
            onSelected: (FilterOptions value) {
              setState(() {
                if (value == FilterOptions.Liked) {
                  // productsContainer.showLikedOnly();

                  _showLikedOnly = true;
                } else {
                  // productsContainer.showALL();
                  _showLikedOnly = false;
                }
              });
            },
            icon: const Icon(Icons.more_vert),
            itemBuilder: (_) => [
              const PopupMenuItem(
                child: Text("Show Liked"),
                value: FilterOptions.Liked,
              ),
              const PopupMenuItem(
                child: Text("Show All"),
                value: FilterOptions.All,
              ),
            ],
          ),
          Consumer<Cart>(
            child: IconButton(
              icon: const Icon(Icons.shopping_bag),
              onPressed: () {
                Navigator.of(context).pushNamed(CartPage.routeName);
              },
            ),
            builder: (_context, cart, _child) => Badge(
              child: _child as Widget,
              value: cart.itemCount.toString(),
            ),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _isInit
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ProductsGrid(_showLikedOnly),
    );
  }
}
