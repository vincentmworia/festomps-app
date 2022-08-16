import 'package:festomps/main.dart';
import 'package:flutter/material.dart';

import '../models/admin.dart';
import '../widgets/custom_widgets.dart';
import 'custom_drawer.dart';

class AdminDataCarousel extends StatelessWidget {
  const AdminDataCarousel(this.pageController, this.allowUsers, this.allowUser,
      {Key? key})
      : super(key: key);
  final PageController pageController;
  final List<Admin> allowUsers;
  final Function(bool, Admin) allowUser;

  Widget _buildRow(String title, String data) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Custom.normalTextOrange('$title:'),
          Text(
            data,
            style: const TextStyle(
              color: Colors.white,
              // letterSpacing: 1.5,
              fontSize: 18.0,
            ),
          ),
        ],
      );

  Widget _buildWidgets(BuildContext context, int index, double deviceHeight) {
    Admin user = allowUsers[index];
    return AnimatedBuilder(
      animation: pageController,
      builder: (BuildContext ctx, Widget? widget) {
        var value = 1.0;
        if (pageController.position.haveDimensions) {
          value = pageController.page! - index;
          // print('Index:\t${index.toString()}');
          // print('Page Controller:\t${pageController.page.toString()}');

          value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
          // print(value);
        }
        return Center(
            child: SizedBox(
          height: Curves.easeInOut.transform(value) * deviceHeight / 3.5,
          child: widget,
        ));
      },
      child: Stack(
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
                        Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: MyApp.appSecondaryColor,
                          ),
                          child: IconButton(
                            onPressed: () =>
                                _allowUsersFunction(context, index, false),
                            icon: Custom.icon(Icons.remove, Colors.white),
                          ),
                        ),
                        Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green,
                          ),
                          child: IconButton(
                            onPressed: () =>
                                _allowUsersFunction(context, index, true),
                            icon: Custom.icon(Icons.add, Colors.white),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Future<void> _allowUsersFunction(
      BuildContext context, int index, bool operation) async {
    Admin user = allowUsers[index];
    await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              content: Custom.normalText(
                  'Do you want to ${operation ? 'add' : 'remove'} ${user.email} ${operation ? 'to' : 'from'} the application'),
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
                          allowUser(operation, user);
                        },
                        child: const Text('Yes')),
                  ],
                )
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    final deviceHeight =
        MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 10.0),
          child: Custom.titleText('Grant access'),
        ),
        SizedBox(
          height: deviceHeight / 3.5,
          child: PageView.builder(
              controller: pageController,
              itemCount: allowUsers.length,
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              itemBuilder: ((BuildContext ctx, i) =>
                  _buildWidgets(ctx, i, deviceHeight))),
        )
      ],
    );
  }
}
