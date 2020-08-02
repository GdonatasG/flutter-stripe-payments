import 'package:flutter/material.dart';
import 'file:///C:/Users/Donatas/AndroidStudioProjects/flutter_forum/flutter_payments_stripe_fireba/lib/pages/unauth/auth_page.dart';
import 'file:///C:/Users/Donatas/AndroidStudioProjects/flutter_forum/flutter_payments_stripe_fireba/lib/pages/auth/home_page.dart';
import 'file:///C:/Users/Donatas/AndroidStudioProjects/flutter_forum/flutter_payments_stripe_fireba/lib/pages/wrapper_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Payments',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(8.0)),
          filled: true,
          fillColor: Colors.blue,
        ),
      ),
      home: WrapperPage(),
    );
  }
}
