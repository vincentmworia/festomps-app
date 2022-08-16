import 'package:festomps/models/admin.dart';
import 'package:festomps/widgets/admin_data_carousel.dart';
import 'package:festomps/widgets/custom_drawer.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import 'custom_widgets.dart';

class AdminAllowUsers extends StatefulWidget {
  const AdminAllowUsers(this.allowUsers,  this.allowUser,{Key? key}) : super(key: key);

  final List<Admin> allowUsers;
  final Function(bool,Admin) allowUser;

  @override
  State<AdminAllowUsers> createState() => _AdminAllowUsersState();
}

class _AdminAllowUsersState extends State<AdminAllowUsers> {
  late PageController _pageController;


  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0, viewportFraction: 0.8);
  }

  @override
  Widget build(BuildContext context) =>
      AdminDataCarousel(_pageController, widget.allowUsers,widget.allowUser);
}
