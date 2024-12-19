import 'package:flutter/material.dart';

// Import your pages here.
import 'search.dart'; // Make sure the path is correct
import 'products_stock.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // Define your routes in a static map for easy maintenance.
  static final Map<String, WidgetBuilder> routes = {
    '/': (context) => const FindSupermarketsPage(),
    '/supermarket': (context) => const FindSupermarketsPage(),
    '/products_stock': (context) => const ProductsStockPage()
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Supermarket App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: routes,
    );
  }
}
