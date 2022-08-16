import 'package:festomps/providers/firebase_auth.dart';
import 'package:festomps/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../private_data.dart';
import './home_screen.dart';
import '../main.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/custom_widgets.dart';
import '../models/user.dart';
import './edit_profile_screen.dart';
import '../widgets/fingerprint_enable_switch.dart';
import '../providers/firebase_user_data.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);
  static const routeName = '/profile_screen';

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var _isLoading = false;

  Card _container(
          {required double width,
          required double height,
          required Widget child,
          required BorderRadius borderRadius}) =>
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
    required BorderRadius borderRadius,
  }) =>
      Padding(
        padding: EdgeInsets.only(top: height * 0.17),
        child: _container(
            width: width,
            height: height,
            child: child,
            borderRadius: borderRadius),
      );

  void _editProfileView(BuildContext context, User user) {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => EditProfileScreen(user)));
  }

  Future<void> _deleteAccount(User user) async {
    await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              content: Custom.normalText('Are you sure you want to delete '
                  '${user.firstName} ${user.lastName}\'s account?'),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('No')),
                    ElevatedButton(
                        onPressed: () async {
                          Future.delayed(Duration.zero)
                              .then((_) => Navigator.pop(context));
                          setState(() => _isLoading = true);
                          try{
                            final message = await FirebaseAuthenticationHandler
                                .deleteAccount();

                            if (message == "DELETE SUCCESSFUL") {
                              Future.delayed(Duration.zero).then((_) async {
                                await http.delete(Uri.parse(
                                    '$firebaseUrl/users/${user.localId}.json'));
                                final prefs =
                                    await SharedPreferences.getInstance();
                                prefs.remove(FirebaseUserData.prefName);
                              }).then((_) =>
                                  FirebaseAuthenticationHandler.logout(
                                      context));
                            } else {
                              Future.delayed(Duration.zero)
                                  .then((_) async =>
                                      await Custom.showCustomDialog(
                                          context, message))
                                  .then((_) =>
                                      setState(() => _isLoading = false));
                            }
                          }catch (error) {
                            const errorMessage =
                                'Failed, check the internet connection later';
                            return await Custom.showCustomDialog(
                                context, errorMessage);
                          }
                        },
                        child: const Text('Yes')),
                  ],
                )
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    final borderRadius = BorderRadius.circular(35.0);
    final Size bnSize = Size(MediaQuery.of(context).size.width / 1.8, 55);
    final User user = Provider.of<FirebaseUserData>(context).loggedInUser!;
    final deviceHeight =
        MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;
    return SafeArea(
        child: Stack(
      children: [
        Scaffold(
          key: scaffoldKey,
          backgroundColor: Colors.white,
          appBar: HomeScreen.appBar(scaffoldKey, 'MY PROFILE'),
          drawer: const CustomDrawer(),
          body: Container(
            margin: const EdgeInsets.all(15.0),
            height: deviceHeight,
            width: double.infinity,
            child: LayoutBuilder(builder: (context, constraints) {
              return Column(
                children: <Widget>[
                  _container(
                      borderRadius: borderRadius,
                      width: constraints.maxWidth,
                      height: constraints.maxHeight * 0.55,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          SizedBox(
                              width: constraints.maxWidth,
                              height: constraints.maxHeight * 0.15,
                              child: CustomDrawer.circleAvatar(user)),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                '${user.firstName} ${user.lastName}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25.0),
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
                                      borderRadius:
                                          BorderRadius.circular(20.0))),
                              label: const Text('Edit Profile',
                                  style: TextStyle(
                                      color: MyApp.appSecondaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25.0)),
                              onPressed: () => _editProfileView(context, user),
                              icon: Custom.icon(
                                  Icons.edit, MyApp.appSecondaryColor)),
                          ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                  minimumSize: bnSize,
                                  maximumSize: bnSize,
                                  padding: const EdgeInsets.all(10),
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(20.0))),
                              label: const Text('Delete User',
                                  style: TextStyle(
                                      color: MyApp.appSecondaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25.0)),
                              onPressed: () => _deleteAccount(user),
                              icon: Custom.icon(
                                  Icons.delete, MyApp.appSecondaryColor)),
                        ],
                      )),
                  _miniContainer(
                      borderRadius: borderRadius,
                      width: constraints.maxWidth,
                      height: constraints.maxHeight * 0.12,
                      child: Center(
                          child: FittedBox(
                        child: Custom.titleText(user.admin == isAdmin
                            ? 'ADMINISTRATOR'
                            : 'NOT ADMIN'),
                      ))),
                  _miniContainer(
                      borderRadius: borderRadius,
                      width: constraints.maxWidth,
                      height: constraints.maxHeight * 0.12,
                      child: const FingerprintEnableSwitch()),
                ],
              );
            }),
          ),
        ),
        if (_isLoading)
       Custom.containerLoading(deviceHeight),
      ],
    ));
  }
}
