import 'dart:async';
import 'dart:convert';

import 'package:festomps/main.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:provider/provider.dart';

import '../../providers/mqtt_provider.dart';
import '../custom_widgets.dart';
import '../../enum.dart';
import '../../screens/mqtt_home_screen/image_view.dart';
import '../../screens/mqtt_home_screen/stepper_view.dart';

class MonitorPanel extends StatefulWidget {
  const MonitorPanel(
    this.stationName, {
    Key? key,
    required this.width,
    required this.height,
  }) : super(key: key);
  final Station stationName;
  final double width;
  final double height;

  @override
  State<MonitorPanel> createState() => _MonitorPanelState();
}

enum ViewMode {
  stepper,
  image,
}

class _MonitorPanelState extends State<MonitorPanel> {
  ViewMode _viewMode = ViewMode.stepper;

  late StreamController _stepDistribution;
  late StreamController _stepSorting;
  late StreamController _stepAll;

  // late StreamController _workpieceName;

  @override
  void initState() {
    super.initState();
    final client = Provider.of<MqttProvider>(context, listen: false).client;
    client.subscribe('#', MqttQos.atMostOnce);
    client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;

      if (c[0].topic == 'CODE STEP DISTRIBUTION') {
        final message =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        _stepDistribution.sink.add(message);
      }
      if (c[0].topic == 'CODE STEP SORTING') {
        final message =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        _stepSorting.sink.add(message);
      }
      if (c[0].topic == 'CODE STEP ALL') {
        final message =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        _stepAll.sink.add(message);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _disposeListeners() {
    switch (widget.stationName) {
      case Station.distribution:
        _stepSorting.close();
        _stepAll.close();
        break;
      case Station.sorting:
        _stepDistribution.close();
        _stepAll.close();
        break;
      case Station.all:
        _stepDistribution.close();
        _stepSorting.close();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    _stepDistribution = StreamController();
    _stepSorting = StreamController();
    _stepAll = StreamController();
    _disposeListeners();
    return LayoutBuilder(builder: (context, constraints) {
      return StreamBuilder(
          stream: widget.stationName == Station.distribution
              ? _stepDistribution.stream
              : widget.stationName == Station.sorting
                  ? _stepSorting.stream
                  : _stepAll.stream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Custom.containerLoading(constraints.maxHeight);
            }
            int currentStep = 0;
            Workpiece workpiece = Workpiece.unknown;
            switch (widget.stationName) {
              case Station.distribution:
                currentStep = int.parse(snapshot.data as String);
                break;
              case Station.sorting:
                currentStep = int.parse(snapshot.data as String);
                break;
              case Station.all:
                currentStep = int.parse(snapshot.data as String);
                break;
            }
            return Stack(
              children: [
                if (_viewMode == ViewMode.image)
                  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: StepperView(
                          currentStep, widget.stationName ))
                else
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ImageView(currentStep, widget.stationName,
                        widget.width, widget.height ),
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
                    decoration: BoxDecoration(
                      // color: Colors.black26,
                      borderRadius: BorderRadius.circular(widget.width * 0.075),
                    ),
                    // child:const Center(child:  Text('...double click...')),
                  ),
                ),
              ],
            );
          });
    });
  }
}
