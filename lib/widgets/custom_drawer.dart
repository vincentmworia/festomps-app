import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../private_data.dart';
import '../providers/firebase_auth.dart';
import '../screens/admin_screen.dart';
import '../models/user.dart';
import '../screens/about_screen.dart';
import '../screens/home_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/login_screen.dart';
import '../providers/firebase_user_data.dart';
import './custom_widgets.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  static CircleAvatar circleAvatar(User user) => CircleAvatar(
        backgroundColor: MyApp.appSecondaryColor,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '${user.firstName[0]}\t${user.lastName[0]}',
              style: const TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                  color: MyApp.appPrimaryColor),
            ),
          ),
        ),
      );

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  var _isLoading = false;

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

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<FirebaseUserData>(context).loggedInUser!;
    final deviceHeight =
        MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;
    return Stack(
      children: [
        Drawer(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                UserAccountsDrawerHeader(
                  currentAccountPicture: CustomDrawer.circleAvatar(user),
                  accountName: Text("${user.firstName} ${user.lastName}"),
                  accountEmail: Text(user.email),
                ),
                _buildDrawer(
                  icon: Custom.icon(Icons.home, MyApp.appPrimaryColor),
                  title: 'HOME',
                  onTap: () => Navigator.pushReplacementNamed(
                      context, HomeScreen.routeName),
                ),
                _buildDrawer(
                  icon:
                      Custom.icon(Icons.account_circle, MyApp.appPrimaryColor),
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
                if (Provider.of<FirebaseUserData>(context)
                        .loggedInUser!
                        .admin ==
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
                  onTap: () async {
                    setState(() => _isLoading = true);
                    try {
                      await FirebaseAuthenticationHandler.logout(context);
                    } catch (error) {
                      const errorMessage =
                          'Failed, check the internet connection later';
                      return await Custom.showCustomDialog(
                          context, errorMessage);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        if (_isLoading) Custom.containerLoading(deviceHeight)
      ],
    );
  }
}
