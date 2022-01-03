import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/helpers/custom_route.dart';
import 'package:shop_app/providers/auth.dart';
import 'package:shop_app/providers/cart.dart';
import 'package:shop_app/providers/orders.dart';
import 'package:shop_app/screens/auth_screen.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/screens/edit_product_screen.dart';
import 'package:shop_app/screens/orders_screen.dart';

import 'package:shop_app/screens/product_detail_screen.dart';
import 'package:shop_app/screens/products_overview_screen.dart';
import 'package:shop_app/screens/user_product.dart';
import 'package:shop_app/widgets/splash_screen.dart';
import './providers/products.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Auth(),
        ),
        // ChangeNotifierProxyProvider<Auth, Products>(
        //   update: (ctx, auth, previousProduct) {
        //     print(auth.token.toString());
        //     return Products(auth.token,
        //         previousProduct == null ? [] : previousProduct.items);
        //   },
        //   create: (ctx) => Products("", []),
        // ),
        ChangeNotifierProxyProvider<Auth, Products>(
          create: (ctx) {
            return Products("", "", []);
          },

          update: (ctx, auth, previousProducts) {
            return Products(auth.token, auth.getUid,
                previousProducts == null ? [] : previousProducts.items);
          },
          // value: Products(),
        ),
        // ChangeNotifierProvider(
        //   // value: Products(),
        //   create: (ctx) => Products(),
        // ),
        ChangeNotifierProvider(
          // value: Products(),
          create: (ctx) => Cart(),
        ),
        // ChangeNotifierProvider(
        //   // value: Products(),
        //   create: (ctx) => Orders(),
        // ),

        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (ctx) {
            return Orders("", "", []);
          },
          update: (ctx, auth, previousProducts) {
            return Orders(auth.token, auth.getUid,
                previousProducts == null ? [] : previousProducts.getOrderItems);
          },
        ),
      ],
      child: Consumer<Auth>(builder: (ctx, auth, _) {
        print(auth.token);
        return MaterialApp(
          title: 'Sasta Shopify',
          theme: ThemeData(
            primarySwatch: Colors.green,
            primaryColorDark: Colors.deepPurple,
            pageTransitionsTheme: PageTransitionsTheme(
              builders: {
                TargetPlatform.android: CustomPageTransitionBuilder(),
                TargetPlatform.iOS: CustomPageTransitionBuilder(),
              },
            ),
            colorScheme: const ColorScheme.light(
              primary: Colors.deepPurple,
              secondary: Colors.deepOrange,
            ),
            // accentColor: Colors.greenAccent,
            fontFamily: "Lato",
          ),
          home: auth.isAuth
              ? ProductsOverviewScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (context, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen(),
                ),
          debugShowCheckedModeBanner: false,
          initialRoute: "/",
          routes: {
            ProductDetailsScreen.routeName: (_) => ProductDetailsScreen(),
            CartPage.routeName: (_) => const CartPage(),
            OrdersScreen.routeName: (_) => const OrdersScreen(),
            UserProductsScreen.routeName: (_) => const UserProductsScreen(),
            EditProductScreen.routeName: (_) => const EditProductScreen()
          },
        );
      }),
    );
  }
}
