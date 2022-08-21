import 'dart:async';
import 'dart:convert';

import 'package:festomps/providers/mqtt_provider.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../enum.dart';
import '../../private_data.dart';
import '../../providers/activate_button.dart';

class ControlBns extends StatefulWidget {
  const ControlBns({
    Key? key,
    required this.controlBn,
    required this.bnDimensions,
    required this.stationName,
  }) : super(key: key);
  final Widget Function(
      {required Map<String, double> dimension,
      required String text,
      required Function() onTap,
      required bool activeBn}) controlBn;
  final Map<String, double> bnDimensions;
  final Station stationName;

  @override
  State<ControlBns> createState() => _ControlBnsState();
}

class _ControlBnsState extends State<ControlBns> {
  Future<void> _bnTrue() => Future.delayed(
        Duration(milliseconds: activeBnDelayTime),
      ).then((_) => setState(() =>
          Provider.of<ActivateBn>(context, listen: false)
              .changeActiveBnStatus(true)));

  Future<void> _startStopResetPressed(String button) async {
    Provider.of<ActivateBn>(context, listen: false).changeActiveBnStatus(false);
    final mqttProtocol = Provider.of<MqttProvider>(context).mqttProtocol;
    switch (widget.stationName) {
      case Station.distribution:
        mqttProtocol.publishMessage('$button DISTRIBUTION', 'true');

        break;
      case Station.sorting:
        break;
      case Station.all:
        break;
    }
    _bnTrue();
  }

  @override
  Widget build(BuildContext context) {
    final activeBn = Provider.of<ActivateBn>(context).bnStatus;
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          widget.controlBn(
              dimension: widget.bnDimensions,
              text: 'START${(widget.stationName == Station.all) ? ' ALL' : ''}',
              onTap: () => _startStopResetPressed('START'),
              activeBn: activeBn),
          widget.controlBn(
            dimension: widget.bnDimensions,
            activeBn: activeBn,
            text: 'STOP${(widget.stationName == Station.all) ? ' ALL' : ''}',
            onTap: () => _startStopResetPressed('STOP'),
          ),
          widget.controlBn(
            dimension: widget.bnDimensions,
            activeBn: activeBn,
            text: 'RESET${(widget.stationName == Station.all) ? ' ALL' : ''}',
            onTap: () => _startStopResetPressed('RESET'),
          ),
        ]);
  }
}
