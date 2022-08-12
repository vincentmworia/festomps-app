import 'package:flutter/material.dart';

import '../screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  static const appBackgroundImgUrl = 'assets/images/background.png';

  static const String appName = 'FESTOMPS APP';
  static const Color appPrimaryColor = Color(0xFF1e3d59);
  static const Color appSecondaryColor = Color(0xFFff6e40);
  static const Color appSecondaryColor2 = Color(0xFF000000);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.green)
            .copyWith(
              secondary: Colors.teal,
            )
            .copyWith(
              primary: appPrimaryColor,
              secondary: appSecondaryColor,
            ),

        primaryColor: MyApp.appPrimaryColor,
        appBarTheme: AppBarTheme(
          toolbarHeight: 80.0,
          backgroundColor: appPrimaryColor,
          centerTitle: true,
          iconTheme: IconThemeData(color: Theme.of(context).primaryColor),
          titleTextStyle: const TextStyle(
            fontSize: 22.0,
            color: appSecondaryColor,
            fontWeight: FontWeight.bold,
            letterSpacing: 5.0,
          ),
        ),
        errorColor: Colors.red,
      ),
      home: const LoginScreen(),
    );
  }
}
