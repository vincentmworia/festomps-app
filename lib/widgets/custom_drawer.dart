import 'package:festomps/private_data.dart';
import 'package:festomps/screens/admin_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../screens/about_screen.dart';
import '../screens/home_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/login_screen.dart';
import '../providers/firebase_user_data.dart';
import './custom_widgets.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  Widget _buildDrawer({
    required Widget icon,
    required String title,
    required void Function() onTap,
  }) {
    return Column(
      children: [
        ListTile(
          leading: icon,
          title: Text(
            title,
            style: const TextStyle(fontSize: 20.0),
          ),
          onTap: onTap,
        ),
        const Divider(),
      ],
    );
  }

  static CircleAvatar circleAvatar() => const CircleAvatar(
        backgroundColor: MyApp.appSecondaryColor,
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'V\tM',
              style: TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                  color: MyApp.appPrimaryColor),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            UserAccountsDrawerHeader(
              currentAccountPicture: circleAvatar(),
              //todo share with profile
              accountName: const Text("Vincent Mworia"),
              accountEmail: const Text("mworiavin@gmail.com"),
            ),
            _buildDrawer(
              icon: Custom.icon(Icons.home, MyApp.appPrimaryColor),
              title: 'HOME',
              onTap: () =>
                  Navigator.pushReplacementNamed(context, HomeScreen.routeName),
            ),
            _buildDrawer(
              icon: Custom.icon(Icons.account_circle, MyApp.appPrimaryColor),
              title: 'Your Profile',
              onTap: () => Navigator.pushReplacementNamed(
                  context, ProfileScreen.routeName),
            ),
            _buildDrawer(
              icon: Custom.icon(Icons.info, MyApp.appPrimaryColor),
              title: 'About',
              onTap: () => Navigator.pushReplacementNamed(
                  context, AboutScreen.routeName),
            ),
            if (Provider.of<FirebaseUserData>(context).loggedInUser!.admin ==
                isAdmin)
              _buildDrawer(
                icon: Custom.icon(
                    Icons.admin_panel_settings, MyApp.appPrimaryColor),
                title: 'Admin',
                onTap: () => Navigator.pushReplacementNamed(
                    context, AdminScreen.routeName),
              ),
            _buildDrawer(
              icon: Custom.icon(Icons.logout, MyApp.appPrimaryColor),
              title: 'Logout',
              onTap: () => Navigator.pushReplacementNamed(
                  context, LoginScreen.routeName),
            ),
          ],
        ),
      ),
    );
  }
}
