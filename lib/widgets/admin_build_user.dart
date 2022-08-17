import 'package:festomps/main.dart';
import 'package:flutter/material.dart';

import '../models/admin.dart';
import 'custom_widgets.dart';

class BuildUser extends StatefulWidget {
  const BuildUser({Key? key, required this.user, required this.allowUser})
      : super(key: key);
  final Admin user;
  final Function(int, Admin) allowUser;

  @override
  State<BuildUser> createState() => _BuildUserState();
}

class _BuildUserState extends State<BuildUser> {
  var _heightCollapse = true;

  Widget _buildRow(String title, String data) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Custom.normalTextOrange('$title:'),
          Text(
            data,
            style: const TextStyle(
              color: Colors.white,
              overflow: TextOverflow.ellipsis,
              fontSize: 18.0,
            ),
          ),
        ],
      );

  Future<void> _allowUsersFunction(
      BuildContext context, int operation, Admin user) async {
    Admin user = widget.user;
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
                          widget.allowUser(operation, widget.user);
                        },
                        child: const Text('Yes')),
                  ],
                )
              ],
            ));
  }

  Widget _buildWidgets(BuildContext context, Admin user) {
    return Stack(
      children: <Widget>[
        Container(
          width: double.infinity,
          margin: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
              color: MyApp.appPrimaryColor,
              borderRadius: BorderRadius.circular(15.0),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0, 2),
                  blurRadius: 6.0,
                )
              ]),
          child: LayoutBuilder(builder: (context, constraints) {
            List<Map<String, String>> allowUserData = [
              {'title': 'Email', 'data': user.email},
              {'title': 'Firstname', 'data': user.firstName},
              {'title': 'Lastname', 'data': user.lastName},
            ];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const SizedBox(height: 10),
                  Column(
                    children: allowUserData
                        .map((Map<String, String> usrData) => _buildRow(
                            usrData['title'] as String,
                            usrData['data'] as String))
                        .toList(),
                  ),
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
                                  context, user.admin ? 4 : 3, widget.user);
                            },
                            icon: Custom.icon(
                                user.admin ? Icons.remove : Icons.add,
                                Colors.white),
                          ),
                        ),
                    ],
                  ),
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
                              await _allowUsersFunction(
                                  context, 2, widget.user);
                            },
                            icon: Custom.icon(Icons.remove, Colors.white),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.all(10.0),
          height: _heightCollapse ? 80 : 300,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: MyApp.appPrimaryColor,
          ),
          child: _heightCollapse
              ? Center(
                  child: ListTile(
                      leading: SizedBox(
                        height: 60,
                        child: CircleAvatar(
                          backgroundColor: widget.user.online
                              ? Colors.green
                              : MyApp.appSecondaryColor,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: FittedBox(
                                child: Text(
                                  widget.user.firstName[0],
                                  style: const TextStyle(
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold,
                                      color: MyApp.appPrimaryColor),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        '${widget.user.firstName} ${widget.user.lastName}',
                        style: const TextStyle(
                          color: Colors.white,
                          // letterSpacing: 1.5,
                          fontSize: 20.0,
                        ),
                      )))
              : _buildWidgets(context, widget.user),
        ),
        Positioned(
          top: _heightCollapse ? 25 : 10,
          right: 10,
          child: IconButton(
            onPressed: () {
              setState(() => _heightCollapse = !_heightCollapse);
            },
            icon: Icon(
              _heightCollapse ? Icons.expand_more : Icons.expand_less,
            ),
            color: MyApp.appSecondaryColor,
            iconSize: 35,
          ),
        )
      ],
    );
  }
}
