import 'package:festomps/main.dart';
import 'package:flutter/material.dart';

import '../screens/login_screen.dart';
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

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(
                backgroundColor: MyApp.appSecondaryColor,
              ),
              accountName: Text("Vincent Mworia"),
              accountEmail: Text("mworiavin@gmail.com"),
            ),
            _buildDrawer(
              icon:Custom.icon(Icons.home, MyApp.appPrimaryColor),
              title: 'HOME',
              onTap: () => Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const LoginScreen())),
            ),
            _buildDrawer(
              icon:Custom.icon(Icons.logout, MyApp.appPrimaryColor),
              title: 'Logout',
              onTap: () {
                //todo
              },
            ),
          ],
        ),
      ),
    );
  }
}
