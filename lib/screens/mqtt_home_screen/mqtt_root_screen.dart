import 'dart:async';

import 'package:festomps/providers/mqtt_provider.dart';
import 'package:festomps/screens/stations_screen.dart';
import 'package:festomps/widgets/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../widgets/custom_widgets.dart';
import './offline_screen.dart';

import './mqttfile.dart';
import '../../enum.dart';

class MainHome extends StatefulWidget {
  const MainHome({Key? key}) : super(key: key);
  static const routeName = '/main_home';

  static AppBar appBar(GlobalKey<ScaffoldState> scaffoldKey, String title) =>
      AppBar(
        title: Custom.titleText(title),
        leading: IconButton(
          icon: Custom.icon(Icons.menu, MyApp.appSecondaryColor),
          onPressed: () => scaffoldKey.currentState?.openDrawer(),
        ),
      );

  @override
  State<MainHome> createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> {
  bool _conn = false;
  var _runLoop = true;

  late MQTTClientWrapper mqttClient;
  late Timer timer;
  MqttServerClient? _client;

  @override
  void initState() {
    super.initState();
    connStatus = Status.offline;
    // request for initial values

    mqttClient = MQTTClientWrapper();
    timer = Timer.periodic(const Duration(milliseconds: 500), (timer) async {
      if (_runLoop) {
        _runLoop = false;
        if (_client == null) {
          await mqttClient.prepareMqttClient().then((value) {
            _client = value;
          });
        }
        switch (mqttClient.connectionState) {
          case MqttCurrentConnectionState.idle:
            break;
          case MqttCurrentConnectionState.connecting:
            break;
          case MqttCurrentConnectionState.connected:
            if (_conn == false) {
              setState(() {
                _conn = true;
                Provider.of<MqttProvider>(context, listen: false)
                    .setClient(mqttProtocol: mqttClient, client: _client!);
                connStatus = Status.online;
              });
            }
            break;
          case MqttCurrentConnectionState.errorWhenConnecting:
          case MqttCurrentConnectionState.disconnected:
            _client = null;
            setState(() {
              _conn = false;
              Provider.of<MqttProvider>(context, listen: false).resetMqtt();
              connStatus = Status.offline;
            });
            break;
        }
        _runLoop = true;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  late Status connStatus;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: Custom.titleText('FESTO MPS'),
          leading: IconButton(
            icon: Custom.icon(Icons.menu, MyApp.appSecondaryColor),
            onPressed: () => scaffoldKey.currentState?.openDrawer(),
          ),
        ),
        drawer: const CustomDrawer(),
        body: connStatus == Status.offline
            ? const OfflineScreen()
            : const SingleChildScrollView(
                child: SizedBox(height: 3500, child: StationsScreen())),
      ),
    );
  }
}