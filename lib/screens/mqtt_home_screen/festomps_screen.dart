import 'package:flutter/material.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../../enum.dart';
import '../../main.dart';
import '../../widgets/custom_drawer.dart';
import '../../widgets/custom_widgets.dart';
import 'image_view.dart';
import 'stepper_view.dart';

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

  Widget _workpieceView(height) => SizedBox(
        height: height,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _colorTitle(_wpMetallic.toString(), Colors.grey),
            _colorTitle(_wpRed.toString(), Colors.red),
            _colorTitle(_wpBlack.toString(), Colors.black),
            _colorTitle(_wpTotal.toString(), MyApp.appPrimaryColor),
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

  Widget _bn(String title, String station) => InkWell(
        onTap: () {
          print(title);
          print(station);
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
            station == _distribution
                ? '$title DIST'
                : station == _sorting
                    ? '$title SORT'
                    : '$title ALL',
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

  final String _distribution = "DISTRIBUTION";
  final String _sorting = "SORTING";
  final String _all = "ALL";

  Widget _stationDisplay(
    String stationName,
    double height,
  ) =>
      AutoScrollTag(
        key: ValueKey(stationName),
        controller: controller,
        index: stationName == _distribution
            ? 1
            : stationName == _sorting
                ? 2
                : 0,
        highlightColor: Colors.black,
        child: Column(
          children: [
            SizedBox(
              height: height * 0.085,
              child: Center(
                  child: Custom.titleText(
                      stationName == _all ? 'ALL STATIONS' : stationName)),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: SizedBox(
                height: height * 0.9,
                child: LayoutBuilder(builder: (context, constraints) {
                  final containerWidth = constraints.maxWidth;
                  final containerHeight = constraints.maxHeight;
                  return Column(
                    children: [
                      _cardView(
                          containerHeight * 0.425,
                          Stack(
                            children: [
                              if (_viewMode == ViewMode.stepper)
                                Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: stationName == _distribution
                                        ? StepperView(
                                            _distCurrentStep,
                                            Station.distribution,
                                            _sortWorkpieceName)
                                        : stationName == _sorting
                                            ? StepperView(
                                                _sortCurrentStep,
                                                Station.sorting,
                                                _sortWorkpieceName)
                                            : StepperView(
                                                _allCurrentStep,
                                                Station.all,
                                                _sortWorkpieceName))
                              else
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: stationName == _distribution
                                      ? ImageView(
                                          _distCurrentStep,
                                          Station.distribution,
                                          _sortWorkpieceName,
                                          containerWidth,
                                          containerHeight)
                                      : stationName == _sorting
                                          ? ImageView(
                                              _sortCurrentStep,
                                              Station.sorting,
                                              _sortWorkpieceName,
                                              containerWidth,
                                              containerHeight)
                                          : ImageView(
                                              _allCurrentStep,
                                              Station.all,
                                              _sortWorkpieceName,
                                              containerWidth,
                                              containerHeight),
                                ),
                              GestureDetector(
                                onDoubleTap: () {
                                  setState(
                                    () => _viewMode == ViewMode.stepper
                                        ? _viewMode = ViewMode.image
                                        : _viewMode = ViewMode.stepper,
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
                                borderRadius: BorderRadius.circular(30)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _bn('START', stationName),
                                    _bn('STOP', stationName),
                                    _bn('RESET', stationName),
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
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
                                                color: MyApp.appSecondaryColor),
                                            shape: BoxShape.circle,
                                            color: MyApp.appSecondaryColor
                                                .withOpacity(_distStationPower
                                                    ? 1
                                                    : 0.1),
                                          ),
                                        )
                                      ],
                                    ),
                                    // todo ROW OF MAN/AUTO STATE
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
      );
  late int _allCurrentStep;
  late int _distCurrentStep;
  late int _sortCurrentStep;
  late Workpiece _sortWorkpieceName;
  late bool _allStationPower;
  late bool _distStationPower;
  late bool _sortStationPower;
  late bool _distStationManAutoState;
  late bool _sortStationManAutoState;
  late int _distStationManAutoStep;
  late int _sortStationManAutoStep;

  late int _wpRed;
  late int _wpBlack;
  late int _wpMetallic;
  late int _wpTotal;

  @override
  Widget build(BuildContext context) {
    _allCurrentStep = 10;
    _allStationPower = true;

    _distCurrentStep = 4;
    _distStationPower = true;
    _distStationManAutoState = true;
    _distStationManAutoStep = 3;

    _sortStationPower = false;
    _sortCurrentStep = 4;
    _sortStationManAutoState = true;
    _sortStationManAutoStep = 5;
    _sortWorkpieceName = Workpiece.red;

    _wpRed = 1;
    _wpMetallic = 31;
    _wpBlack = 234;
    _wpTotal = 266;

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
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              scrollDirection: scrollDirection,
              controller: controller,
              child: Column(children: [
                _stationDisplay(_all, constraints.maxHeight),
                _stationDisplay(_distribution, constraints.maxHeight),
                _stationDisplay(_sorting, constraints.maxHeight),
              ]),
            );
          }))
        ],
      ),
    ));
  }
}
