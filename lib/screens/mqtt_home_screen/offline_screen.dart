import 'package:festomps/main.dart';
import 'package:flutter/material.dart';

class OfflineScreen extends StatelessWidget {
  const OfflineScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color:MyApp.appSecondaryColor2.withOpacity(0.5),
      child: const Center(
          child: Text(
        'OFFLINE',
        style:
            TextStyle(letterSpacing: 20.0, color: Colors.white, fontSize: 30.0),
      )),
    );
  }
}
