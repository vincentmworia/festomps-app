import 'package:flutter/material.dart';

import './control_panel.dart';

class ControlWidget{

  static Widget streamPower({
    required double width,
    required double height,
    required Stream stream,
  }) =>
      StreamBuilder(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center();
          }
          bool stationPower = snapshot.data as bool;
          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
                color: stationPower ? Colors.green : ControlPanel.offColor,
                border: Border.all(
                  color: ControlPanel.offColor,
                ),
                shape: BoxShape.circle),
          );
        },
      );

  static SizedBox autoManualDisplay(
      {required double width,
        required double height,
        required String text,
        required Color dividerColor,
        required String step,
        required bool isActive}) =>
      SizedBox(
        width: width * 0.25,
        height: height * 0.5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(text),
            SizedBox(
              width: width * 0.2,
              child: Divider(
                color: dividerColor,
              ),
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: width * 0.2,
                  height: height * 0.3,
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.deepOrange[400]
                        : ControlPanel.offColor,
                  ),
                ),
                Text(
                  text == 'Manual' && isActive ? step : '',
                  style: const TextStyle(color: Colors.black, fontSize: 25.0),
                  textAlign: TextAlign.center,
                )
              ],
            ),
          ],
        ),
      );


}