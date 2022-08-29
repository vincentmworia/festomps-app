import 'package:festomps/main.dart';
import 'package:flutter/material.dart';

import '../../widgets/custom_drawer.dart';
import '../../widgets/custom_widgets.dart';

class OfflineScreen extends StatelessWidget {
  const OfflineScreen({Key? key, required this.title, required this.color}) : super(key: key);
final String title;
final Color color;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: MyApp.appSecondaryColor2.withOpacity(0.75),
        title: Custom.titleText('FESTO MPS'),
      ),
      drawer: const CustomDrawer(),
      body: Container(
        color:color.withOpacity(0.5),
        child:  Center(
            child: Text(
          title,
          style: const TextStyle(
              letterSpacing: 20.0, color: Colors.white, fontSize: 30.0),
        )),
      ),
    );
  }
}
