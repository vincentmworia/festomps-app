import 'package:festomps/providers/activate_button.dart';
import 'package:festomps/providers/firebase_auth.dart';
import 'package:festomps/providers/mqtt_provider.dart';
import 'package:festomps/screens/mqtt_home_screen/mqtt_root_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './providers/firebase_user_data.dart';
import './screens/login_screen.dart';
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
        ChangeNotifierProvider(create: (_) => ActivateBn()),
        ChangeNotifierProvider(create: (_) => MqttProvider()),
        ChangeNotifierProvider(create: (_) => FirebaseUserData()),
        ChangeNotifierProvider(create: (_) => FirebaseAuthenticationHandler()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: MyApp.appName,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.green)
              .copyWith(
                secondary: Colors.orange,
              )
              .copyWith(
                primary: MyApp.appPrimaryColor,
                secondary: MyApp.appSecondaryColor,
              ),

          primaryColor: MyApp.appPrimaryColor,
          appBarTheme: const AppBarTheme(
            toolbarHeight: 80.0,
            backgroundColor: MyApp.appPrimaryColor,
            centerTitle: true,

            titleTextStyle: TextStyle(
              fontSize: 22.0,
              color: MyApp.appSecondaryColor,
              fontWeight: FontWeight.bold,
              letterSpacing: 5.0,
            ),
          ).copyWith(iconTheme: const IconThemeData(color: appSecondaryColor)),
          errorColor: Colors.red,
        ),
        // todo after 1hr check whether app is active
        home: defaultScreen,
        routes: {
          MainHome.routeName: (_) => const MainHome(),
          ProfileScreen.routeName: (_) => const ProfileScreen(),
          AboutScreen.routeName: (_) => const AboutScreen(),
          AdminScreen.routeName: (_) => const AdminScreen(),
        },
        onGenerateRoute: (settings) => MaterialPageRoute(
          builder: (_) => MyApp.defaultScreen,
        ),
        onUnknownRoute: (settings) => MaterialPageRoute(
          builder: (_) => MyApp.defaultScreen,
        ),
      ),
    );
  }
}
