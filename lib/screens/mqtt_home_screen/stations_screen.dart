import 'dart:math' as math;
import 'dart:math';

import 'package:festomps/main.dart';
import 'package:festomps/widgets/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

//
// void main() => runApp(MyApp());
//
// class MyApp extends StatelessWidget {
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Scroll To Index Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: MyHomePage(title: 'Scroll To Index Demo'),
//     );
//   }
// }
class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const maxCount = 10;
  static const double maxHeight = 400;
  final random = math.Random();
  final scrollDirection = Axis.vertical;

  late AutoScrollController controller;

  // late List<List<int>> randomList;

  @override
  void initState() {
    super.initState();
    controller = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: scrollDirection);
    // randomList = List.generate(maxCount,
    //     (index) => <int>[index, (maxHeight * random.nextDouble()).toInt()]);
  }

  @override
  Widget build(BuildContext context) {
    // final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    // final randomList = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
    const space = SizedBox(height: 80);
    return SafeArea(
      child: Scaffold(
        // key: scaffoldKey,
        appBar: AppBar(
          // elevation: 0,
          title: const Text('FESTO MPS'),
        ),
        drawer: CustomDrawer(),
        body: Column(
          // alignment: Alignment.topCenter,
          children: [
            Container(
              // transform: Matrix4.rotationZ(-pi/180) ,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(10.0),
                  bottomLeft: Radius.circular(10.0),
                ),
                color: MyApp.appPrimaryColor.withOpacity(0.7),
              ),
              height: 60,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() => counter = 0);
                          _scrollToCounter();
                        },
                        child: Text('   ALL   ',
                            style: TextStyle(
                                color: counter == 0
                                    ? MyApp.appSecondaryColor
                                    : Colors.white)),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() => counter = 1);
                          _scrollToCounter();
                        },
                        child: Text('DISTRIBUTION',
                            style: TextStyle(
                                color: counter == 1
                                    ? MyApp.appSecondaryColor
                                    : Colors.white)),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() => counter = 2);
                          _scrollToCounter();
                        },
                        child: Text('SORTING',
                            style: TextStyle(
                                color: counter == 2
                                    ? MyApp.appSecondaryColor
                                    : Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
            ),    Container(
            margin: EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(

                    // height: 20,
                    padding:EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: MyApp.appPrimaryColor.withOpacity(0.4),
                    ),
                    child: Text('1', style: TextStyle(color: Colors.red,fontSize: 30)),
                  ),
                  Text('2', style: TextStyle(color: Colors.black)),
                  Text('3', style: TextStyle(color: Colors.grey)),
                  Text('6', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
            Expanded(
                child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                ListView(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: scrollDirection,
                    controller: controller,
                    children: [
                      space,
                      Padding(
                          padding: const EdgeInsets.all(8),
                          child: AutoScrollTag(
                            key: const ValueKey('ALL'),
                            controller: controller,
                            index: 0,
                            highlightColor: Colors.black.withOpacity(0.1),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              alignment: Alignment.topCenter,
                              height: 600,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.lightBlue, width: 4),
                                  borderRadius: BorderRadius.circular(12)),
                              child:
                                  const Center(child: Text('ALL STATIONS ')),
                            ),
                          )),
                      space,
                      Padding(
                          padding: const EdgeInsets.all(8),
                          child: AutoScrollTag(
                            key: const ValueKey('DISTRIBUTION'),
                            controller: controller,
                            index: 1,
                            highlightColor: Colors.black.withOpacity(0.1),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              alignment: Alignment.topCenter,
                              height: 600,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.lightBlue, width: 4),
                                  borderRadius: BorderRadius.circular(12)),
                              child: const Center(
                                  child: Text('DISTRIBUTION STATIONS ')),
                            ),
                          )),
                      space,
                      Padding(
                          padding: const EdgeInsets.all(8),
                          child: AutoScrollTag(
                            key: const ValueKey('SORTING'),
                            controller: controller,
                            index: 2,
                            highlightColor: Colors.black.withOpacity(0.1),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              alignment: Alignment.topCenter,
                              height: 600,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.lightBlue, width: 4),
                                  borderRadius: BorderRadius.circular(12)),
                              child: const Center(
                                  child: Text('SORTING STATIONS ')),
                            ),
                          )),
                      space,
                    ]),

              ],
            ))
          ],
        ),
        // floatingActionButton: Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceAround,
        //   children: [
        //     FloatingActionButton(
        //       onPressed: _prevCounter,
        //       tooltip: 'Decrement',
        //       child: Icon(Icons.arrow_back),
        //     ),
        //     FloatingActionButton(
        //       onPressed: _nextCounter,
        //       tooltip: 'Increment',
        //       child: Text(counter.toString()),
        //     ),
        //   ],
        // ),
      ),
    );
  }

  Future _scrollToCounter() async {
    await controller.scrollToIndex(counter,
        preferPosition: AutoScrollPosition.begin);
    controller.highlight(counter);
  }

  int counter = 0;

  Future _nextCounter() {
    setState(() => counter = (counter + 1) % maxCount);
    return _scrollToCounter();
  }

  Future _prevCounter() {
    setState(() => counter = (counter - 1) % maxCount);
    return _scrollToCounter();
  }
}
