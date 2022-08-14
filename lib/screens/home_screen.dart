import 'package:flutter/material.dart';

import '../main.dart';
import '../widgets/custom_widgets.dart';
import '../widgets/custom_drawer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);
  static const routeName = '/home_screen';

  static AppBar appBar(GlobalKey<ScaffoldState> scaffoldKey, String title) =>
      AppBar(
        title: Custom.titleText(title),
        leading: IconButton(
          icon: Custom.icon(Icons.menu, MyApp.appSecondaryColor),
          onPressed: () => scaffoldKey.currentState?.openDrawer(),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        appBar:appBar(scaffoldKey,'FESTO MPS'),
        drawer: const CustomDrawer(),
        body: const Center(
          child: Text('TODO control and monitor'),
        ),
      ),
    );
  }
}
