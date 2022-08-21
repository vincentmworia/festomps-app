import 'package:festomps/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../main.dart';
import '../models/admin.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/custom_widgets.dart';

class AdminUserScreen extends StatelessWidget {
  const AdminUserScreen(this.user, this.allowUser, {Key? key})
      : super(key: key);
  final Admin user;

  final Function(int, Admin) allowUser;

  Future<void> _allowUsersFunction(
      BuildContext context, int operation, Admin user) async {
    await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              content: Custom.normalText(
                  'Do you want to ${operation == 3 ? 'make' : 'remove'} ${user.email} ${operation == 2 ? 'from the application' : operation == 3 ? 'an administrator' : 'from administrator'}'),
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
                          Navigator.pop(context);
                          Navigator.pop(context);
                          allowUser(operation, user);
                        },
                        child: const Text('Yes')),
                  ],
                )
              ],
            ));
  }

  TableRow _tableRowLogin({
    required String key,
    required String login,
    required String logout,
    required String timeSpent,
  }) =>
      TableRow(children: <Widget>[
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.top,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              key,
              textAlign: TextAlign.center,
              style: key == 'No'
                  ? const TextStyle(color: MyApp.appSecondaryColor)
                  : null,
            ),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.top,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              login,
              textAlign: TextAlign.center,
              style: login == 'Login'
                  ? const TextStyle(color: MyApp.appSecondaryColor)
                  : null,
            ),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.top,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              logout,
              textAlign: TextAlign.center,
              style: logout == 'Logout'
                  ? const TextStyle(color: MyApp.appSecondaryColor)
                  : null,
            ),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.top,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              timeSpent,
              textAlign: TextAlign.center,
              style: timeSpent == 'Duration'
                  ? const TextStyle(color: MyApp.appSecondaryColor)
                  : null,
            ),
          ),
        ),
      ]);

  @override
  Widget build(BuildContext context) {
    var i = 0;
    const space = SizedBox(height: 25);
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: MyApp.appSecondaryColor2.withOpacity(0.75),
              title: Custom.titleText('USER PANEL'),
              leading: IconButton(
                icon: Custom.icon(Icons.arrow_back, MyApp.appSecondaryColor),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(20.0),
              child: LayoutBuilder(builder: (context, constraints) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                        width: constraints.maxWidth,
                        height: constraints.maxHeight * 0.15,
                        child: CircleAvatar(
                          backgroundColor: user.online
                              ? Colors.green
                              : MyApp.appSecondaryColor,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                '${user.firstName[0]}\t${user.lastName[0]}',
                                style: const TextStyle(
                                    fontSize: 30.0,
                                    fontWeight: FontWeight.bold,
                                    color: MyApp.appPrimaryColor),
                              ),
                            ),
                          ),
                        )),
                    Text(
                      '${user.firstName} ${user.lastName}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 25.0),
                    ),
                    Custom.normalText(user.email),
                    space,
                    Custom.titleText('Login Details'),
                    space,
                    Expanded(
                      child: ListView(
                          physics: const BouncingScrollPhysics(),
                          children: [
                            Table(
                              border: TableBorder.all(),
                              columnWidths: const <int, TableColumnWidth>{
                                0: FlexColumnWidth(1),
                                1: FlexColumnWidth(3),
                                2: FlexColumnWidth(3),
                                3: FlexColumnWidth(2),
                              },
                              defaultVerticalAlignment:
                                  TableCellVerticalAlignment.middle,
                              children: <TableRow>[
                                _tableRowLogin(
                                    key: 'No',
                                    login: 'Login',
                                    logout: 'Logout',
                                    timeSpent: 'Duration'),
                                ...(user.loginData.map((e) {
                                  i++;
                                  return _tableRowLogin(
                                    key: i == 0 ? '-' : i.toString(),
                                    // key:  i.toString(),
                                    login: e['login'],
                                    logout: e['logout'],
                                    timeSpent: e['duration'],
                                  );
                                }).toList())
                              ],
                            ),
                          ]),
                    ),
                    space,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Custom.normalTextOrange(
                            user.email == 'mworiavin@gmail.com'
                                ? 'SUPER ADMINISTRATOR'
                                : user.admin
                                    ? 'ADMINISTRATOR'
                                    : 'NOT ADMIN'),
                        if (!(user.email == 'mworiavin@gmail.com'))
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: user.admin
                                  ? MyApp.appSecondaryColor
                                  : Colors.green,
                            ),
                            child: IconButton(
                              onPressed: () async {
                                await _allowUsersFunction(
                                    context, user.admin ? 4 : 3, user);
                              },
                              icon: Custom.icon(
                                  user.admin ? Icons.remove : Icons.add,
                                  Colors.white),
                            ),
                          ),
                      ],
                    ),
                    space,
                    if (!(user.email == 'mworiavin@gmail.com'))
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Custom.normalTextOrange('DE-ACTIVATE USER'),
                          Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: MyApp.appSecondaryColor,
                            ),
                            child: IconButton(
                              onPressed: () async {
                                await _allowUsersFunction(context, 2, user);
                              },
                              icon: Custom.icon(Icons.remove, Colors.white),
                            ),
                          ),
                        ],
                      ),
                  ],
                );
              }),
            )));
  }
}
