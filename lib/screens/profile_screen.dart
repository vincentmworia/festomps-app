import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './home_screen.dart';
import '../main.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/custom_widgets.dart';
import '../models/user.dart';
import '../widgets/edit_profile_view.dart';
import '../widgets/fingerprint_enable_switch.dart';
import '../providers/firebase_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);
  static const routeName = '/profile_screen';

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    final borderRadius = BorderRadius.circular(35.0);
    final Size bnSize = Size(MediaQuery.of(context).size.width / 1.8, 55);
    final User user = Provider.of<FirebaseUserData>(context).loggedInUser;

    Card _container(
            {required double width,
            required double height,
            required Widget child}) =>
        Card(
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          child: Container(
            width: width,
            height: height,
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
                borderRadius: borderRadius,
                color: MyApp.appSecondaryColor.withOpacity(0.05)),
            child: child,
          ),
        );
    Padding _miniContainer({
      required double width,
      required double height,
      required Widget child,
    }) =>
        Padding(
          padding: EdgeInsets.only(top: height * 0.17),
          child: _container(width: width, height: height, child: child),
        );

    void _editProfileView(BuildContext context) {
      Navigator.push(context, MaterialPageRoute(builder: (_)=>EditProfileView(user)));
    }

    return SafeArea(
        child: Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      appBar: HomeScreen.appBar(scaffoldKey, 'MY PROFILE'),
      drawer: const CustomDrawer(),
      body: Container(
        margin: const EdgeInsets.all(15.0),
        height: MediaQuery.of(context).size.height -
            MediaQuery.of(context).padding.top,
        width: double.infinity,
        child: LayoutBuilder(builder: (context, constraints) {
          return Column(
            children: <Widget>[
              _container(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight * 0.5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      SizedBox(
                          width: constraints.maxWidth,
                          height: constraints.maxHeight * 0.15,
                          child: CustomDrawer.circleAvatar()),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            '${user.firstName} ${user.lastName}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 25.0),
                          ),
                          Custom.normalText(user.email),
                        ],
                      ),
                      ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                              minimumSize: bnSize,
                              maximumSize: bnSize,
                              padding: const EdgeInsets.all(10),
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0))),
                          label: const Text('Edit Profile',
                              style: TextStyle(
                                  color: MyApp.appSecondaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25.0)),
                          onPressed: () => _editProfileView(context),
                          icon:
                              Custom.icon(Icons.edit, MyApp.appSecondaryColor))
                    ],
                  )),
              _miniContainer(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight * 0.12,
                  child: Center(
                      child: FittedBox(
                    child: Custom.titleText(
                        user.isAdmin == 5334 ? 'ADMINISTRATOR' : 'NOT ADMIN'),
                  ))),
              _miniContainer(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight * 0.12,
                  child: const FingerprintEnableSwitch()),
            ],
          );
        }),
      ),
    ));
  }
}
