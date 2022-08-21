import 'dart:async';

import 'package:festomps/providers/mqtt_provider.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:provider/provider.dart';

import '../../enum.dart';
import './widget_functions.dart';
import './buttons_widget.dart';

class ControlPanel extends StatefulWidget {
  const ControlPanel({
    Key? key,
    required this.width,
    required this.height,
    required this.stationName,
  }) : super(key: key);
  final double width;
  final double height;
  final Station stationName;

  static const offColor = Color.fromRGBO(12, 4, 4, 0.2);

  @override
  State<ControlPanel> createState() => _ControlPanelState();
}

class _ControlPanelState extends State<ControlPanel> {
  late MachineMode machineModeDistribution;
  late MachineMode machineModeSorting;
  late bool powerDistribution;
  late bool powerSorting;
  late bool powerAll;

  late StreamController _streamControllerDistributionPower;
  late StreamController _streamControllerDistributionManualAuto;
  late StreamController _streamControllerDistributionTxtManAuto;

  late StreamController _streamControllerSortingManualAuto;
  late StreamController _streamControllerSortingPower;
  late StreamController _streamControllerSortingTxtManAuto;

  late StreamController _streamControllerAllPower;

  @override
  void initState() {
    super.initState();
    _streamControllerDistributionPower = StreamController();
    _streamControllerSortingPower = StreamController();
    _streamControllerAllPower = StreamController();
    _streamControllerDistributionManualAuto = StreamController();
    _streamControllerSortingManualAuto = StreamController();
    _streamControllerDistributionTxtManAuto = StreamController();
    _streamControllerSortingTxtManAuto = StreamController();

    machineModeDistribution = MachineMode.auto;
    machineModeSorting = MachineMode.manual;
    powerDistribution = true;
    powerSorting = false;
    powerAll = false;

    final client = Provider.of<MqttProvider>(context, listen: false).client;
    client.subscribe('#', MqttQos.atMostOnce);
    client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;

      if (c[0].topic == 'SYSTEM ON DISTRIBUTION') {
        final message =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        _streamControllerDistributionPower.sink.add(message);
      }
      if (c[0].topic == "MANUAL STEP DISTRIBUTION") {
        final message =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        _streamControllerDistributionTxtManAuto.sink.add(message);
      }
      if (c[0].topic == "MANUAL AUTO MODE DISTRIBUTION") {
        final message =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        _streamControllerDistributionManualAuto.sink.add(message);
      }

      if (c[0].topic == 'SYSTEM ON SORTING') {
        final message =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        _streamControllerSortingPower.sink.add(message);
      }
      if (c[0].topic == "MANUAL STEP SORTING") {
        final message =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        _streamControllerSortingTxtManAuto.sink.add(message);
      }
      if (c[0].topic == "MANUAL AUTO MODE SORTING") {
        final message =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        _streamControllerSortingManualAuto.sink.add(message);
      }
    });
  }

  Widget _controlBn(
          {required Map<String, double> dimension,
          required String text,
          required Function() onTap,
          required bool activeBn}) =>
      SizedBox(
        height: dimension['height'],
        width: dimension['width'],
        child: ElevatedButton(
          onPressed: activeBn ? onTap : null,
          child: Text(
            text,
            textAlign: TextAlign.center,
          ),
        ),
      );


  Widget _streamManualAuto({
    required double width,
    required double height,
    required Stream stream,
  }) =>
      StreamBuilder(
          stream: stream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center();
            }

            final machineStateMode = snapshot.data as Map<String, dynamic>;
            MachineMode mcMode = machineStateMode['system_mode'] as MachineMode;
            final stp = machineStateMode['manual_step_number'] as String;

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ControlWidget.autoManualDisplay(
                    width: width,
                    height: height,
                    text: 'Auto',
                    dividerColor: Theme.of(context).primaryColor,
                    isActive: mcMode == MachineMode.auto ? true : false,
                    step: stp),
                ControlWidget.autoManualDisplay(
                    width: width,
                    height: height,
                    text: 'Manual',
                    dividerColor: Theme.of(context).primaryColor,
                    isActive: mcMode == MachineMode.manual ? true : false,
                    step: stp)
              ],
            );
          });


  // void _disposeListeners() {}
  void _disposeListeners() {
    switch (widget.stationName) {
      case Station.distribution:
        _streamControllerSortingPower.close();
        _streamControllerAllPower.close();
        _streamControllerSortingManualAuto.close();
        _streamControllerSortingTxtManAuto.close();
        break;
      case Station.sorting:
        _streamControllerDistributionPower.close();
        _streamControllerAllPower.close();
        _streamControllerDistributionManualAuto.close();
        _streamControllerDistributionTxtManAuto.close();
        break;
      case Station.all:
        _streamControllerDistributionPower.close();
        _streamControllerSortingPower.close();
        _streamControllerDistributionManualAuto.close();
        _streamControllerSortingManualAuto.close();
        _streamControllerDistributionTxtManAuto.close();
        _streamControllerSortingTxtManAuto.close();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Streams Initialization

    _disposeListeners();

    return LayoutBuilder(
      builder: (context, cons) {
        Map<String, double> bnDimensions = {
          'width': cons.maxWidth * 0.35,
          'height': (cons.maxHeight * 0.19)/3,
        };
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  SizedBox(
                    height: (widget.stationName == Station.all)
                        ? cons.maxHeight
                        : cons.maxHeight,
                    width: 120,
                    child: ControlBns(
                      controlBn: _controlBn,
                      bnDimensions: bnDimensions,
                      stationName: widget.stationName,
                    ),
                  ),
                ]),
            Column(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (widget.stationName != Station.all)
                      SizedBox(height: cons.maxHeight * 0.075 * 0.5),
                    if (widget.stationName == Station.all)
                      SizedBox(height: cons.maxHeight * 0.2),
                    const Text('POWER'),
                    if (widget.stationName == Station.distribution)
                      ControlWidget.streamPower(
                          width: cons.maxWidth * 0.5,
                          height: (widget.stationName == Station.all)
                              ? cons.maxHeight * 0.45
                              : cons.maxHeight * 0.35,
                          stream:
                          _streamControllerDistributionPower.stream),
                    if (widget.stationName == Station.sorting)
                      ControlWidget.streamPower(
                          width: cons.maxWidth * 0.5,
                          height: (widget.stationName == Station.all)
                              ? cons.maxHeight * 0.45
                              : cons.maxHeight * 0.35,
                          stream: _streamControllerSortingPower.stream),
                    if (widget.stationName == Station.all)
                      ControlWidget.streamPower(
                          width: cons.maxWidth * 0.5,
                          height: (widget.stationName == Station.all)
                              ? cons.maxHeight * 0.45
                              : cons.maxHeight * 0.35,
                          stream: _streamControllerAllPower.stream),
                  ],
                ),
                if (widget.stationName != Station.all &&
                    MediaQuery.of(context).size.height > 600)
                  SizedBox(height: cons.maxHeight * 0.075 * 0.5),
                if (widget.stationName == Station.distribution)
                  _streamManualAuto(
                    width: cons.maxWidth,
                    height: cons.maxHeight,
                    stream:
                    _streamControllerDistributionManualAuto.stream,
                  ),
                if (widget.stationName == Station.sorting)
                  _streamManualAuto(
                    width: cons.maxWidth,
                    height: cons.maxHeight,
                    stream: _streamControllerSortingManualAuto.stream,
                  ),
              ],
            )
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _disposeListeners();
  }
}
