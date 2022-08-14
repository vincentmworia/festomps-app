// import 'package:festomps/backup.dart';
import 'package:festomps/providers/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './providers/firebase_user_data.dart';
import './screens/login_screen.dart';
import './screens/home_screen.dart';
import './screens/profile_screen.dart';
import './screens/about_screen.dart';
import './screens/admin_screen.dart';

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

  static const Widget defaultScreen = LoginScreen();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FirebaseUserData()),
        ChangeNotifierProvider(create: (_) => FirebaseAuthenticationHandler()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
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
        home: defaultScreen,
        routes: {
          HomeScreen.routeName: (_) => const HomeScreen(),
          ProfileScreen.routeName: (_) => const ProfileScreen(),
          AboutScreen.routeName: (_) => const AboutScreen(),
          AdminScreen.routeName: (_) => const AdminScreen(),
        },
        onGenerateRoute: (settings) => MaterialPageRoute(
          builder: (_) => defaultScreen,
        ),
        onUnknownRoute: (settings) => MaterialPageRoute(
          builder: (_) => defaultScreen,
        ),
      ),
    );
  }
}
