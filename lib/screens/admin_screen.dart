import 'package:festomps/providers/firebase_auth.dart';
import 'package:festomps/screens/home_screen.dart';
import 'package:flutter/material.dart';

import '../models/user.dart';
import '../widgets/custom_drawer.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({Key? key}) : super(key: key);
  static const routeName = '/admin_screen';

  // todo, Timer.periodic, in case there is change only, re-render the widget
  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    return SafeArea(
      child: Scaffold(
          key: scaffoldKey,
        appBar: HomeScreen.appBar(scaffoldKey, 'About'),
        drawer:const  CustomDrawer(),
        body: Column(
          children: [
          ...FirebaseAuthenticationHandler.otherUsers!.map((User user) => Text(user.firstName)).toList()
          ],
        ),
      ),
    );
  }
}
