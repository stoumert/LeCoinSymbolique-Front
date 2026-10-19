import 'package:flutter/material.dart';
import 'package:le_coin_symbolique_front/screens/home_page.dart';
import 'package:le_coin_symbolique_front/screens/login_page.dart';
import 'package:le_coin_symbolique_front/screens/main_layout.dart';
import 'package:le_coin_symbolique_front/service/navigation_service.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MainLayout(),
      debugShowCheckedModeBanner: false,
      navigatorKey: NavigationService.navigatorKey,
      routes: {
        '/login': (_) => LoginPage(),
      },
    );
  }
}