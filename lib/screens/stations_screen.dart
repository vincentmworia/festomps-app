import 'package:festomps/screens/mqtt_home_screen/home_screen.dart';
import 'package:festomps/widgets/station.dart';
import 'package:flutter/material.dart';

import '../enum.dart';
import '../main.dart';

class StationsScreen extends StatelessWidget {
  const StationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            // borderRadius: BorderRadius.only(
            //   bottomRight: Radius.circular(20),
            //   bottomLeft: Radius.circular(20),
            // ),
            borderRadius: BorderRadius.circular(20),
            color: MyApp.appPrimaryColor,
          ),
          height: 60,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: 700,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    'ALL STATIONS',
                    style: TextStyle(color: MyApp.appSecondaryColor),
                  ),
                  Text(
                    'DISTRIBUTION STATION',
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    'SORTING STATION',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
        const HomeScreen()
      ],
    );
  }
}
