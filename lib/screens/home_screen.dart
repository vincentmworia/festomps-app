import 'package:festomps/main.dart';
import 'package:flutter/material.dart';

import '../widgets/custom_widgets.dart';
import '../widgets/custom_drawer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: Custom.titleText('FESTO MPS'),
          leading: IconButton(
            icon: Custom.icon(Icons.menu, MyApp.appSecondaryColor),
            onPressed: () => scaffoldKey.currentState?.openDrawer(),
          ),
        ),
        drawer: const CustomDrawer(),
        body: const Center(
          child: Text('HOME SCREEN'),
        ),
      ),
    );
  }
}
