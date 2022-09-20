
import 'package:flutter/material.dart';

import './custom_widgets.dart';
import '../main.dart';
import '../models/admin.dart';
import '../screens/admin_user_screen.dart';

class AdminOtherUsers extends StatelessWidget {
  const AdminOtherUsers(this.otherUsers, this.allowUser, {Key? key})
      : super(key: key);

  final List<Admin> otherUsers;
  final Function(int, Admin) allowUser;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 8.0,
        top: 8.0,
        right: 8.0,
        // bottom: 2.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
            child: Custom.titleText('Users'),
          ),
          Expanded(
            child: ListView.builder(
              itemBuilder: (ctx, index) {
                Admin user = otherUsers[index];
                return Container(
                    margin: const EdgeInsets.all(10.0),
                    height: 80,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: MyApp.appPrimaryColor,
                    ),
                    child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: user.online
                              ? Colors.green
                              : MyApp.appSecondaryColor,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(1.0),
                              child: FittedBox(
                                child: Text(
                                  user.firstName[0],
                                  style: const TextStyle(
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold,
                                      color: MyApp.appPrimaryColor),
                                ),
                              ),
                            ),
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => AdminUserScreen(user,allowUser)));
                        },
                        subtitle: Text(user.email,
                            style: const TextStyle(
                              color: Colors.white,
                              // letterSpacing: 1.5,
                              fontSize: 15.0,
                            )),
                        title: Text(
                          '${user.firstName} ${user.lastName}',
                          style: const TextStyle(
                            color: Colors.white,
                            // letterSpacing: 1.5,
                            fontSize: 20.0,
                          ),
                        )));
              },
              itemCount: otherUsers.length,
            ),
          ),
        ],
      ),
    );
  }
}
