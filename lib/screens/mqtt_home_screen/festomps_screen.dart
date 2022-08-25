import 'package:flutter/material.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../../enum.dart';
import '../../main.dart';
import '../../widgets/custom_drawer.dart';
import '../../widgets/custom_widgets.dart';
import '../../widgets/monitor_panel/image_view.dart';
import '../../widgets/monitor_panel/stepper_view.dart';

class FestoMpsScreen extends StatefulWidget {
  const FestoMpsScreen({Key? key}) : super(key: key);

  @override
  State<FestoMpsScreen> createState() => _FestoMpsScreenState();
}

class _FestoMpsScreenState extends State<FestoMpsScreen> {
  late AutoScrollController controller;
  final scrollDirection = Axis.vertical;
  var counter = 0;
  late ViewMode _viewMode = ViewMode.stepper;

  @override
  void initState() {
    super.initState();
    controller = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: scrollDirection);
    // controller.highlight(counter)
  }

  Future _scrollToCounter() async {
    await controller.scrollToIndex(counter,
        preferPosition: AutoScrollPosition.begin);
    // controller.highlight(counter);
  }
Widget _workpieceView(height)=>
    SizedBox(
      height:height ,
      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.spaceAround,
        crossAxisAlignment:
        CrossAxisAlignment.center,
        children: [
          _colorTitle('1', Colors.grey),
          _colorTitle('25', Colors.red),
          _colorTitle('173', Colors.black),
          _colorTitle('176', MyApp.appPrimaryColor),
        ],
      ),
    );
  Widget _topic(String title, int ctr) => SizedBox(
        height: 35,
        child: InkWell(
          splashColor: MyApp.appSecondaryColor,
          onTap: () {
            setState(() => counter = ctr);
            _scrollToCounter();
          },
          child: Text(title,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color:
                      counter == ctr ? MyApp.appSecondaryColor : Colors.white)),
        ),
      );

  Widget _colorTitle(String title, Color clr) => Container(
        decoration: BoxDecoration(color: clr, shape: BoxShape.circle),
        width: 50,
        height: 50,
        child: Center(
          child: FittedBox(
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Text(title,
                  style: const TextStyle(color: Colors.white, fontSize: 20)),
            ),
          ),
        ),
      );

  Widget _bn(String title) => InkWell(
        onTap: () {
          print(title);
        },
        child: Container(
          width: 140,
          height: 70,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: MyApp.appPrimaryColor,
          ),
          child: Center(
              child: Text(
            title,
            style: const TextStyle(color: Colors.white),
          )),
        ),
      );

  Widget _cardView(double height, Widget child) => Card(
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Container(
            height: height,
            decoration: BoxDecoration(
                // border: Border.all(color: MyApp.appPrimaryColor,width: 1),
                color: MyApp.appPrimaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30)),
            child: child),
      );
  late int _currentStepAll;
  late int _currentStepDist;
  late int _currentStepSort;
  late Workpiece _workpieceAll;
  late Workpiece _workpieceSort;

  @override
  Widget build(BuildContext context) {
    // final deviceHeight =
    //     MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;
    return SafeArea(
        child: Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        title: Custom.titleText('FESTO MPS'),
      ),
      drawer: const CustomDrawer(),
      body: Column(
        children: [
          Container(
            color: MyApp.appPrimaryColor,
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _topic('ALL', 0),
                _topic('DISTRIBUTION', 1),
                _topic('SORTING', 2),
              ],
            ),
          ),
          Expanded(child: LayoutBuilder(builder: (context, constraints) {
            // final width = constraints.maxWidth;
            final height = constraints.maxHeight;
            // final space = SizedBox(height: height * 0.1);
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              scrollDirection: scrollDirection,
              controller: controller,
              child: Column(children: [
                AutoScrollTag(
                  key: const ValueKey('ALL'),
                  controller: controller,
                  index: 0,
                  highlightColor: Colors.black,
                  child: Column(
                    children: [
                      SizedBox(
                        height: height * 0.085,
                        child: Center(child: Custom.titleText('ALL STATIONS')),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: SizedBox(
                          height: height * 0.9,
                          child: LayoutBuilder(builder: (context, constraints) {
                            final containerWidth = constraints.maxWidth;
                            final containerHeight = constraints.maxHeight;
                            _currentStepAll = 10;
                            _workpieceAll = Workpiece.red;
                            return Column(
                              children: [
                                _cardView(
                                    containerHeight * 0.425,
                                    Stack(
                                      children: [
                                        if (_viewMode == ViewMode.stepper)
                                          Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: StepperView(
                                                  _currentStepAll,
                                                  Station.all,
                                                  _workpieceAll))
                                        else
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: ImageView(
                                                _currentStepAll,
                                                Station.all,
                                                _workpieceAll,
                                                containerWidth,
                                                containerHeight),
                                          ),
                                        GestureDetector(
                                          onDoubleTap: () {
                                            setState(
                                              () => _viewMode ==
                                                      ViewMode.stepper
                                                  ? _viewMode = ViewMode.image
                                                  : _viewMode =
                                                      ViewMode.stepper,
                                            );
                                          },
                                          child: Container(
                                            width: double.infinity,
                                            height: double.infinity,
                                            decoration: const BoxDecoration(
                                                // color: Colors.red,
                                                borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(30),
                                              topLeft: Radius.circular(30),
                                            )),
                                          ),
                                        ),
                                      ],
                                    )),
                           _workpieceView(containerHeight * 0.1),
                                _cardView(
                                    containerHeight * 0.425,
                                    Container(
                                      height: containerHeight * 0.425,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(30)),
                                      child:  Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                        children: [
                                          Column(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                            children: [
                                              _bn('START ALL'),
                                              _bn('STOP ALL'),
                                              _bn('RESET ALL'),
                                            ],
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            children: [
                                              Custom.normalText('Power'),
                                              Container(
                                                width: 120,
                                                height: 120,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: MyApp
                                                          .appSecondaryColor),
                                                  shape: BoxShape.circle,
                                                  color: MyApp
                                                      .appSecondaryColor
                                                      .withOpacity(0.2),
                                                ),
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    )),
                              ],
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
                AutoScrollTag(
                  key: const ValueKey('DISTRIBUTION'),
                  controller: controller,
                  index: 1,
                  // highlightColor: Colors.black ,
                  child: Column(
                    children: [
                      SizedBox(
                        height: height * 0.085,
                        child: Center(
                            child: Custom.titleText(
                          'DISTRIBUTION',
                        )),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: SizedBox(
                          height: height * 0.9,
                          child: LayoutBuilder(builder: (context, constraints) {
                            final containerWidth = constraints.maxWidth;
                            final containerHeight = constraints.maxHeight;
                            _currentStepDist = 4;

                            return Column(
                              children: [
                                _cardView(
                                    containerHeight * 0.425,
                                    Stack(
                                      children: [
                                        if (_viewMode == ViewMode.stepper)
                                          Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: StepperView(
                                                  _currentStepDist,
                                                  Station.distribution,
                                                  Workpiece.unknown))
                                        else
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: ImageView(
                                                _currentStepDist,
                                                Station.distribution,
                                                Workpiece.unknown,
                                                containerWidth,
                                                containerHeight),
                                          ),
                                        GestureDetector(
                                          onDoubleTap: () {
                                            setState(
                                              () => _viewMode ==
                                                      ViewMode.stepper
                                                  ? _viewMode = ViewMode.image
                                                  : _viewMode =
                                                      ViewMode.stepper,
                                            );
                                          },
                                          child: Container(
                                            width: double.infinity,
                                            height: double.infinity,
                                            decoration: const BoxDecoration(
                                                // color: Colors.red,
                                                borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(30),
                                              topLeft: Radius.circular(30),
                                            )),
                                          ),
                                        ),
                                      ],
                                    )),

                                _workpieceView(containerHeight * 0.1),
                                _cardView(
                                    containerHeight * 0.425,
                                    Container(
                                      height: containerHeight * 0.425,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(30)),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                        children: [
                                          Column(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                            children: [
                                              _bn('START ALL'),
                                              _bn('STOP ALL'),
                                              _bn('RESET ALL'),
                                            ],
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            children: [
                                              Custom.normalText('Power'),
                                              Container(
                                                width: 120,
                                                height: 120,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: MyApp
                                                          .appSecondaryColor),
                                                  shape: BoxShape.circle,
                                                  color: MyApp
                                                      .appSecondaryColor
                                                      .withOpacity(0.2),
                                                ),
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    )),
                              ],
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
                AutoScrollTag(
                  key: const ValueKey('SORTING'),
                  controller: controller,
                  index: 2,
                  // highlightColor: Colors.black,
                  child: Column(
                    children: [
                      SizedBox(
                        height: height * 0.085,
                        child:
                            Center(child: Custom.titleText('SORTING')),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: SizedBox(
                          height: height * 0.9,
                          child: LayoutBuilder(builder: (context, constraints) {
                            final containerWidth = constraints.maxWidth;
                            final containerHeight = constraints.maxHeight;
                            _currentStepSort = 14;
                            _workpieceSort = Workpiece.red;

                            return Column(
                              children: [
                                _cardView(
                                    containerHeight * 0.425,
                                    Stack(
                                      children: [
                                        if (_viewMode == ViewMode.stepper)
                                          Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: StepperView(
                                                  _currentStepSort,
                                                  Station.all,
                                                  _workpieceSort))
                                        else
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: ImageView(
                                                _currentStepSort,
                                                Station.all,
                                                _workpieceSort,
                                                containerWidth,
                                                containerHeight),
                                          ),
                                        GestureDetector(
                                          onDoubleTap: () {
                                            setState(
                                              () => _viewMode ==
                                                      ViewMode.stepper
                                                  ? _viewMode = ViewMode.image
                                                  : _viewMode =
                                                      ViewMode.stepper,
                                            );
                                          },
                                          child: Container(
                                            width: double.infinity,
                                            height: double.infinity,
                                            decoration: const BoxDecoration(
                                                // color: Colors.red,
                                                borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(30),
                                              topLeft: Radius.circular(30),
                                            )),
                                          ),
                                        ),
                                      ],
                                    )),

                                _workpieceView(containerHeight * 0.1),
                                _cardView(
                                    containerHeight * 0.425,
                                    Container(
                                      height: containerHeight * 0.425,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(30)),
                                      child:Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                        children: [
                                          Column(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                            children: [
                                              _bn('START ALL'),
                                              _bn('STOP ALL'),
                                              _bn('RESET ALL'),
                                            ],
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            children: [
                                              Custom.normalText('Power'),
                                              Container(
                                                width: 120,
                                                height: 120,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: MyApp
                                                          .appSecondaryColor),
                                                  shape: BoxShape.circle,
                                                  color: MyApp
                                                      .appSecondaryColor
                                                      .withOpacity(0.2),
                                                ),
                                              )
                                            ],
                                          ),
                                        ],
                                      )
                                    )),
                              ],
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            );
          }))
        ],
      ),
    ));
  }
}
