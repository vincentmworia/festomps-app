import 'dart:async';

import 'package:festomps/private_data.dart';
import 'package:festomps/providers/activate_button.dart';
import 'package:festomps/providers/mqtt_provider.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:provider/provider.dart';
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
  late AutoScrollController _controller;
  final String _distribution = "DISTRIBUTION";
  final String _sorting = "SORTING";
  final String _all = "ALL";
  final scrollDirection = Axis.vertical;
  var counter = 0;
  late ViewMode _viewMode = ViewMode.stepper;

  late int _allCurrentStep;
  late bool _allStationPower;

  late int _distCurrentStep;
  late bool _distStationManAutoState;
  late bool _distStationPower;

  late int _sortCurrentStep;
  late bool _sortStationPower;
  late bool _sortStationManAutoState;
  late Workpiece _sortWorkpieceName;

  StreamController mainStream = StreamController();

  StreamController distCodeStep = StreamController();
  StreamController distManStep = StreamController();
  StreamController distOn = StreamController();
  StreamController distManMode = StreamController();
  StreamController distAutoMode = StreamController();
  StreamController distWorkpieceNumber = StreamController();

  StreamController sortCodeStep = StreamController();
  StreamController sortManStep = StreamController();
  StreamController sortOn = StreamController();
  StreamController sortManMode = StreamController();
  StreamController sortAutoMode = StreamController();
  StreamController sortWorkpieceNumber = StreamController();

  StreamController allOn = StreamController();
  StreamController allCodeStep = StreamController();
  StreamController allWorkpieceNumber = StreamController();

  @override
  void initState() {
    super.initState();

    _allCurrentStep = 0;
    _allStationPower = false;

    _distCurrentStep = 0;
    _distStationManAutoState = false;
    _distStationPower = false;

    _sortCurrentStep = 0;
    _sortStationPower = false;
    _sortStationManAutoState = false;
    _sortWorkpieceName = Workpiece.unknown;

    _controller = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: scrollDirection);

    final client = Provider.of<MqttProvider>(context, listen: false).client;
    client.subscribe('#', MqttQos.atMostOnce);

    client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;

      if (c[0].topic == 'CODE STEP DISTRIBUTION') {
        final message =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        _distCurrentStep = int.parse(message);
        distCodeStep.sink
            .add({'step': _distCurrentStep, 'workpiece': _sortWorkpieceName});
      }
      if (c[0].topic == 'MANUAL STEP DISTRIBUTION') {
        final message =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        distManStep.sink.add(message);
      }
      if (c[0].topic == "MANUAL AUTO MODE DISTRIBUTION") {
        final message =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        _distStationManAutoState = message == "True" ? true : false;
        distManMode.sink.add(_distStationManAutoState);
        distAutoMode.sink.add(!_distStationManAutoState);
      }
      if (c[0].topic == "SYSTEM ON DISTRIBUTION") {
        final message =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        distOn.sink.add(message == "True" ? true : false);
      }

      if (c[0].topic == 'CODE STEP SORTING') {
        final message =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        final data = message.split(':');
        _sortCurrentStep = int.parse(data[0]);
        _sortWorkpieceName = data[1] == 'red'
            ? Workpiece.red
            : data[1] == 'metallic'
                ? Workpiece.metallic
                : data[1] == 'black'
                    ? Workpiece.black
                    : Workpiece.unknown;
        sortCodeStep.sink
            .add({'step': _sortCurrentStep, 'workpiece': _sortWorkpieceName});
        distWorkpieceNumber.sink.add({
          'black': data[2],
          'metallic': data[3],
          'red': data[4],
          'total': data[5]
        });
        sortWorkpieceNumber.sink.add({
          'black': data[2],
          'metallic': data[3],
          'red': data[4],
          'total': data[5]
        });
        allWorkpieceNumber.sink.add({
          'black': data[2],
          'metallic': data[3],
          'red': data[4],
          'total': data[5]
        });
      }
      if (c[0].topic == 'CODE STEP ALL') {
        final message =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        _allCurrentStep = int.parse(message);
        allCodeStep.sink
            .add({'step': _allCurrentStep, 'workpiece': _sortWorkpieceName});
      }
      if (c[0].topic == 'MANUAL STEP SORTING') {
        final message =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        sortManStep.sink.add(message);
      }
      if (c[0].topic == "MANUAL AUTO MODE SORTING") {
        final message =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        _sortStationManAutoState = message == "True" ? true : false;
        sortManMode.sink.add(_sortStationManAutoState);
        sortAutoMode.sink.add(!_sortStationManAutoState);
      }
      if (c[0].topic == "SYSTEM ON SORTING") {
        final message =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        sortOn.sink.add(message == "True" ? true : false);
      }
      if (c[0].topic == "SYSTEM ON ALL") {
        final message =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        allOn.sink.add(message == "true" ? true : false);
      }

      if (c[0].topic == 'REQUEST INIT') {
        final message =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        mainStream.sink.add(message);
      }
    });
    // mainStream.sink.add('terminated');
    Provider.of<MqttProvider>(context, listen: false)
        .mqttProtocol
        .publishMessage('REQUEST INIT', 'true');
  }

  @override
  void dispose() {
    super.dispose();
    distCodeStep.close();
    distManStep.close();
    distManMode.close();
    distAutoMode.close();
    distOn.close();
    distWorkpieceNumber.close();

    sortCodeStep.close();
    sortManStep.close();
    sortManMode.close();
    sortAutoMode.close();
    sortOn.close();
    sortWorkpieceNumber.close();

    allCodeStep.close();
    allOn.close();
    allWorkpieceNumber.close();

    mainStream.close();
  }

  Future _scrollToCounter() async {
    await _controller.scrollToIndex(counter,
        preferPosition: AutoScrollPosition.begin);
  }

  Widget _workpieceView(String stationName, double height) => StreamBuilder(
      stream: stationName == _distribution
          ? distWorkpieceNumber.stream
          : stationName == _sorting
              ? sortWorkpieceNumber.stream
              : allWorkpieceNumber.stream,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center();
        }
        final data = snap.data as Map<String, String>;
        return SizedBox(
          height: height,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _colorTitle(data['metallic'] as String, Colors.grey),
              _colorTitle(data['red'] as String, Colors.red),
              _colorTitle(data['black'] as String, Colors.black),
              _colorTitle(data['total'] as String, MyApp.appPrimaryColor),
            ],
          ),
        );
      });

  Widget _topic(String title, int ctr) => SizedBox(
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            // enableFeedback: false,
          ),
          onPressed: () {
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
        width: 45,
        height: 45,
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

  Widget _bn(String title, String station) =>
      Consumer<ActivateBn>(builder: (context, activeBn, child) {
        return InkWell(
          onTap: activeBn.bnStatus
              ? null
              : () {
                  activeBn.changeActiveBnStatus(true);
                  Provider.of<MqttProvider>(context, listen: false)
                      .mqttProtocol
                      .publishMessage('$title $station', 'true');
                  Future.delayed(Duration(milliseconds: activeBnDelayTime))
                      .then((value) => activeBn.changeActiveBnStatus(false));
                },
          child: Container(
            width: 130,
            height: 65,
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
              style: TextStyle(
                  color:
                      activeBn.bnStatus ? MyApp.appPrimaryColor : Colors.white),
            )),
          ),
        );
      });

  Widget _cardView(double height, Widget child, [bool whiteBg = false]) => Card(
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Container(
            height: height,
            decoration: BoxDecoration(
                // border: Border.all(color: MyApp.appPrimaryColor,width: 1),
                color: whiteBg
                    ? Colors.white
                    : MyApp.appPrimaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30)),
            child: child),
      );

  Widget _streamPower(String stationName, double containerHeight) =>
      StreamBuilder(
          stream: stationName == _distribution
              ? distOn.stream
              : stationName == _sorting
                  ? sortOn.stream
                  : allOn.stream,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center();
            }
            _allStationPower = false;
            _distStationPower = false;
            _sortStationPower = false;
            if (stationName == _distribution) {
              _distStationPower = snap.data as bool;
            } else if (stationName == _sorting) {
              _sortStationPower = snap.data as bool;
            } else if (stationName == _all) {
              _allStationPower = snap.data as bool;
            }
            return Container(
              width: (!(stationName == _all))
                  ? containerHeight / 8
                  : containerHeight / 5,
              height: (!(stationName == _all))
                  ? containerHeight / 8
                  : containerHeight / 5,
              decoration: BoxDecoration(
                border: Border.all(color: MyApp.appSecondaryColor),
                shape: BoxShape.circle,
                color: MyApp.appSecondaryColor.withOpacity(
                    ((_distStationPower && stationName == _distribution) ||
                            (_sortStationPower && stationName == _sorting) ||
                            (_allStationPower && stationName == _all))
                        ? 1
                        : 0.1),
              ),
            );
          });

  Widget _streamMonitorView(
          String stationName, double containerWidth, double containerHeight) =>
      StreamBuilder(
          stream: stationName == _distribution
              ? distCodeStep.stream
              : stationName == _sorting
                  ? sortCodeStep.stream
                  : allCodeStep.stream,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return  Center(child:Custom.titleText('TURN ON SERVER!'),);
            }
            final data = snap.data as Map<String, dynamic>;
            if (stationName == _distribution) {
              _distCurrentStep = data['step'] as int;
            } else if (stationName == _sorting) {
              _sortCurrentStep = data['step'] as int;
            } else if (stationName == _sorting) {
              _allCurrentStep = data['step'] as int;
            }

            _sortWorkpieceName = data['workpiece'] as Workpiece;
            return Stack(
              children: [
                if (_viewMode == ViewMode.stepper)
                  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: stationName == _distribution
                          ? StepperView(_distCurrentStep, Station.distribution,
                              _sortWorkpieceName)
                          : stationName == _sorting
                              ? StepperView(_sortCurrentStep, Station.sorting,
                                  _sortWorkpieceName)
                              : StepperView(_allCurrentStep, Station.all,
                                  _sortWorkpieceName))
                else
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: stationName == _distribution
                        ? ImageView(_distCurrentStep, Station.distribution,
                            _sortWorkpieceName, containerWidth, containerHeight)
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
            );
          });

  Widget _streamManualAuto(
      String stationName, double containerWidth, double containerHeight) {
    final width = containerWidth / 2;
    final height = containerHeight / 6;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
          width: width * 0.4,
          height: height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Auto'),
              SizedBox(
                width: width * 0.2,
                child: const Divider(
                  color: MyApp.appPrimaryColor,
                ),
              ),
              StreamBuilder(
                  stream: stationName == _distribution
                      ? distAutoMode.stream
                      : sortAutoMode.stream,
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center();
                    }
                    return Container(
                      width: width * 0.35,
                      height: height * 0.65,
                      decoration: BoxDecoration(
                        color: MyApp.appSecondaryColor
                            .withOpacity(snap.data as bool ? 1 : 0.1),
                      ),
                    );
                  }),
            ],
          ),
        ),
        SizedBox(
          width: width * 0.4,
          height: height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Manual'),
              SizedBox(
                width: width * 0.2,
                child: const Divider(
                  color: MyApp.appPrimaryColor,
                ),
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  StreamBuilder(
                      stream: stationName == _distribution
                          ? distManMode.stream
                          : sortManMode.stream,
                      builder: (context, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const Center();
                        }
                        return Container(
                          width: width * 0.35,
                          height: height * 0.65,
                          decoration: BoxDecoration(
                            color: MyApp.appSecondaryColor
                                .withOpacity(snap.data as bool ? 1 : 0.1),
                          ),
                        );
                      }),
                  StreamBuilder(
                      stream: stationName == _distribution
                          ? distManStep.stream
                          : sortManStep.stream,
                      builder: (context, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const Center();
                        }
                        return Text(
                          snap.data as String,
                          style: const TextStyle(
                              color: Colors.black, fontSize: 25.0),
                          textAlign: TextAlign.center,
                        );
                      })
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stationDisplay(
    String stationName,
    double height,
  ) =>
      AutoScrollTag(
        key: ValueKey(stationName),
        controller: _controller,
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
                          _streamMonitorView(
                              stationName, containerWidth, containerHeight),
                          _viewMode == ViewMode.image ? true : false),
                      _workpieceView(stationName, containerHeight * 0.1),
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
                                        _streamPower(
                                            stationName, containerHeight),
                                      ],
                                    ),
                                    if (!(stationName == _all))
                                      _streamManualAuto(stationName,
                                          containerWidth, containerHeight)
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
    elevation: 0,
    title: Custom.titleText('FESTO MPS'),
      ),
      drawer: Provider.of<ActivateBn>(context, listen: false).bnStatus
      ? null
      : const CustomDrawer(),
      body: StreamBuilder(
      stream: mainStream.stream,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Container(
            color: MyApp.appSecondaryColor2.withOpacity(0.5),
            child: const Center(
                child: Text(
              'Fetching\nserver\ndata...',
              style: TextStyle(
                  letterSpacing: 20.0, color: Colors.white, fontSize: 30.0),
            )),
          );
        }
        return Stack(
          children: [
            Column(
              children: [
                Container(
                  color: MyApp.appPrimaryColor,
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _topic('     ALL      ', 0),
                      _topic('DISTRIBUTION', 1),
                      _topic('  SORTING   ', 2),
                    ],
                  ),
                ),
                Expanded(
                    child: LayoutBuilder(builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: scrollDirection,
                    controller: _controller,
                    child: Column(children: [
                      _stationDisplay(_all, constraints.maxHeight),
                      _stationDisplay(_distribution, constraints.maxHeight),
                      _stationDisplay(_sorting, constraints.maxHeight),
                    ]),
                  );
                }))
              ],
            ),
            if (snap.data as String == "terminated")
              Container(
                color: Colors.grey,
                child: const Center(
                    child: Text(
                  'SERVER\nOFF',
                  style: TextStyle(
                      letterSpacing: 20.0,
                      color: Colors.white,
                      fontSize: 30.0),
                )),
              ),
          ],
        );
      }),
    );
  }
}
