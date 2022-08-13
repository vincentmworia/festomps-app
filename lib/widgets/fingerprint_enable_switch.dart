import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../providers/firebase_provider.dart';
import 'custom_widgets.dart';

class FingerprintEnableSwitch extends StatefulWidget {
  const FingerprintEnableSwitch({Key? key}) : super(key: key);

  @override
  State<FingerprintEnableSwitch> createState() =>
      _FingerprintEnableSwitchState();
}

class _FingerprintEnableSwitchState extends State<FingerprintEnableSwitch> {
  @override
  Widget build(BuildContext context) {
    final switchData = Provider.of<FirebaseUserData>(context);
    return SwitchListTile(title: FittedBox(child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Custom.normalText('Login with fingerprint'),
    )),
        activeColor: MyApp.appSecondaryColor,
        value: switchData.switchValue,
        onChanged: (value) => switchData.setSwitchValue(value));
  }
}
