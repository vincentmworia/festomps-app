import 'package:festomps/main.dart';
import 'package:festomps/screens/home_screen.dart';
import 'package:flutter/material.dart';

import '../widgets/custom_drawer.dart';
import '../widgets/custom_widgets.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);
  static const routeName = '/about_screen';

  @override
  Widget build(BuildContext context) {
    const spacing = SizedBox(
      height: 20.0,
    );
    Widget _titleText(String text) => Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20.0,
            textBaseline: TextBaseline.ideographic,
            color: MyApp.appSecondaryColor,
          ),
        );
    Widget _subtitleText(String text) => Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: MyApp.appSecondaryColor,
            fontSize: 18.0,
            textBaseline: TextBaseline.ideographic,
          ),
        );
    Column _text(String text) => Column(
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color:  MyApp.appPrimaryColor,
                fontSize: 16.0,
                textBaseline: TextBaseline.ideographic,
              ),
            ),
            spacing,
          ],
        );
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    return SafeArea(
        child: Scaffold(
      key: scaffoldKey,
      appBar: HomeScreen.appBar(scaffoldKey, 'ABOUT'),
      drawer: const CustomDrawer(),
      body: Padding(
          padding: const EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 5.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                _titleText('PROJECT INFORMATION:'),
                _subtitleText('PROJECT NAME:'),
                _text(
                    'VIRTUAL COMMISSIONING AND DIGITAL TWINNING OF FESTO MECHATRONICS SYSTEM WITH INTERNET OF THINGS'),
                _subtitleText('CREATED ON:'),
                _text('23-06-2022'),
                _subtitleText('AUTHOR:'),
                _text('Group 4'),
                _subtitleText('DESCRIPTION:'),
                _text(
                    'This project entails controlling and monitoring the Festo '
                    'distribution and sorting stations remotely. This enables '
                    'remote access of the system after designing a virtual model '
                    'of Festo mechatronics system and digital twinning '
                    '(the integration of the virtual model and the physical '
                    'Festo mechatronics system). We then monitor the data '
                    'using Internet of Things by designing a user interface.'),
                spacing,
                _titleText('SYSTEM INFORMATION:'),
                _subtitleText('PLC DEVICE TYPE:'),
                _text('Simatic S7-1500'),
                _subtitleText('HMI DEVICE TYPE:'),
                _text('HMI Basic KTP 700'),
                _subtitleText('CONNECTION TYPE:'),
                _text('Profinet'),
              ],
            ),
          )),
    ));
  }
}
