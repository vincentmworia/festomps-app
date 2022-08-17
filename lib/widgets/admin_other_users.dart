import 'package:festomps/widgets/admin_build_user.dart';
import 'package:flutter/material.dart';

import '../models/admin.dart';
import 'custom_widgets.dart';

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
              itemBuilder: (ctx, index) => BuildUser(user: otherUsers[index],allowUser: allowUser,),
              itemCount: otherUsers.length,
            ),
          ),
        ],
      ),
    );
  }
}
