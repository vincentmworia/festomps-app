import 'package:flutter/material.dart';

import '../widgets/custom_drawer.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({Key? key}) : super(key: key);
  static const routeName = '/admin_screen';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: const Scaffold(
        drawer: CustomDrawer(),
        body: Center(
          child: Text('Admin Page'),
        ),
      ),
    );
  }
}
