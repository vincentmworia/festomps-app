import 'dart:async';

import 'package:festomps/providers/mqtt_provider.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    Key? key,
  }) : super(key: key);
  static const routeName = '/home_screen';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  StreamController distCodeStep = StreamController();
  StreamController distManStep = StreamController();
  StreamController distOn = StreamController();
  StreamController distManMode = StreamController();

  StreamController sortCodeStep = StreamController();
  StreamController sortManStep = StreamController();
  StreamController sortOn = StreamController();
  StreamController sortManMode = StreamController();
  StreamController sortWorkpieceNumber = StreamController();

  StreamController allOn = StreamController();
  StreamController allCodeStep = StreamController();

  @override
  void initState() {
    super.initState();

    final client = Provider
        .of<MqttProvider>(context, listen: false)
        .client;
    client.subscribe('#', MqttQos.atMostOnce);

    client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;

      if (c[0].topic == 'CODE STEP DISTRIBUTION') {
        final message =
        MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        distCodeStep.sink.add(message);
      }
      if (c[0].topic == 'MANUAL STEP DISTRIBUTION') {
        final message =
        MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        distManStep.sink.add(message);
      }
      if (c[0].topic == "MANUAL AUTO MODE DISTRIBUTION") {
        final message =
        MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        distManMode.sink.add(message);
      }
      if (c[0].topic == "SYSTEM ON DISTRIBUTION") {
        final message =
        MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        distOn.sink.add(message);
      }

      if (c[0].topic == 'CODE STEP SORTING') {
        final message =
        MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        sortCodeStep.sink.add(message);
      }
      if (c[0].topic == 'CODE STEP ALL') {
        final message =
        MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        allCodeStep.sink.add(message);
        // todo add after filter
        sortWorkpieceNumber.sink.add(message);
      }
      if (c[0].topic == 'MANUAL STEP SORTING') {
        final message =
        MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        sortManStep.sink.add(message);
      }
      if (c[0].topic == "MANUAL AUTO MODE SORTING") {
        final message =
        MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        sortManMode.sink.add(message);
      }
      if (c[0].topic == "SYSTEM ON SORTING") {
        final message =
        MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        sortOn.sink.add(message);
      }
      if (c[0].topic == "SYSTEM ON ALL") {
        final message =
        MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        allOn.sink.add(message);
      }
    });
    // todo request for first data
    Provider
        .of<MqttProvider>(context, listen: false)
        .mqttProtocol
        .publishMessage('REQUEST INIT', 'true');

  }

  @override
  void dispose() {
    super.dispose();
    distCodeStep.close();
    distManStep.close();
    distManMode.close();
    distOn.close();

    sortCodeStep.close();
    sortManStep.close();
    sortManMode.close();
    sortOn.close();

    allCodeStep.close();
    allOn.close();
  }

  Widget streamData(streamCtrl) =>
      Container(
        padding: const EdgeInsets.all(30.0),
        decoration:
        BoxDecoration(border: Border.all(color: Colors.green, width: 2.0)),
        child: StreamBuilder(
            stream: streamCtrl.stream,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Text('Wait..'),
                );
              }

              final data = snap.data;
              String msg = '';
              if (data == null) {
                msg = 'no data';
              } else {
                msg = data as String;

                if (msg.contains(':')) {
                  // msg.substring(msg.indexOf(':'),msg.indexOf(','));
                  var codestepWp = msg.split(':');
                  print('\n $codestepWp');
                  print('CODE STEP: ${codestepWp[0]}');
                  print('WORKPIECE: ${codestepWp[1]}');
                }
              }
              return Text(
                msg,
                style: const TextStyle(fontSize: 30.0),
              );
            }),
      );

  @override
  Widget build(BuildContext context) {
    const space = SizedBox(
      height: 25,
    );
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      // todo animate with station selected
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: SizedBox(
            height: 3000,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                streamData(distCodeStep),
                streamData(distManStep),
                streamData(distManMode),
                streamData(distOn),
                space,
                streamData(sortCodeStep),
                streamData(sortManStep),
                streamData(sortManMode),
                streamData(sortOn),
                space,
                streamData(sortWorkpieceNumber),
                space,
                streamData(allCodeStep),
                streamData(allOn),
                space,
                SizedBox(
                  height: 60.0,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          textStyle: const TextStyle(
                            fontSize: 30.0,
                          )),
                      onPressed: () {
                        print('pressed');
                        Provider
                            .of<MqttProvider>(context, listen: false)
                            .mqttProtocol
                            .publishMessage('START DISTRIBUTION', 'true');
                      },
                      child: const Text('START')),
                ),
                SizedBox(
                  height: 60.0,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          textStyle: const TextStyle(
                            fontSize: 30.0,
                          )),
                      onPressed: () {
                        Provider
                            .of<MqttProvider>(context, listen: false)
                            .mqttProtocol
                            .publishMessage('STOP DISTRIBUTION', 'true');
                      },
                      child: const Text('STOP')),
                ),
                SizedBox(
                  height: 60.0,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          textStyle: const TextStyle(
                            fontSize: 30.0,
                          )),
                      onPressed: () {
                        Provider
                            .of<MqttProvider>(context, listen: false)
                            .mqttProtocol
                            .publishMessage('RESET DISTRIBUTION', 'true');
                      },
                      child: const Text('RESET')),
                ),
                SizedBox(
                  height: 80,
                ),
                SizedBox(
                  height: 60.0,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          textStyle: const TextStyle(
                            fontSize: 30.0,
                          )),
                      onPressed: () {
                        print('press');
                        Provider
                            .of<MqttProvider>(context, listen: false)
                            .mqttProtocol
                            .publishMessage('START SORTING', 'true');
                      },
                      child: const Text('START')),
                ),
                SizedBox(
                  height: 60.0,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          textStyle: const TextStyle(
                            fontSize: 30.0,
                          )),
                      onPressed: () {
                        Provider
                            .of<MqttProvider>(context, listen: false)
                            .mqttProtocol
                            .publishMessage('STOP SORTING', 'true');
                      },
                      child: const Text('STOP')),
                ),
                SizedBox(
                  height: 60.0,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          textStyle: const TextStyle(
                            fontSize: 30.0,
                          )),
                      onPressed: () {
                        Provider
                            .of<MqttProvider>(context, listen: false)
                            .mqttProtocol
                            .publishMessage('RESET SORTING', 'true');
                      },
                      child: const Text('RESET')),
                ),
                SizedBox(
                  height: 80,
                ),
                SizedBox(
                  height: 60.0,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          textStyle: const TextStyle(
                            fontSize: 30.0,
                          )),
                      onPressed: () {
                        print('press');
                        Provider
                            .of<MqttProvider>(context, listen: false)
                            .mqttProtocol
                            .publishMessage('START ALL', 'true');
                      },
                      child: const Text('START')),
                ),
                SizedBox(
                  height: 60.0,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          textStyle: const TextStyle(
                            fontSize: 30.0,
                          )),
                      onPressed: () {
                        Provider
                            .of<MqttProvider>(context, listen: false)
                            .mqttProtocol
                            .publishMessage('STOP ALL', 'true');
                      },
                      child: const Text('STOP')),
                ),
                SizedBox(
                  height: 60.0,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          textStyle: const TextStyle(
                            fontSize: 30.0,
                          )),
                      onPressed: () {
                        Provider
                            .of<MqttProvider>(context, listen: false)
                            .mqttProtocol
                            .publishMessage('RESET ALL', 'true');
                      },
                      child: const Text('RESET')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
