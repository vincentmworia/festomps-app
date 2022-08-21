import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import '../screens/mqtt_home_screen/mqttfile.dart';

class MqttProvider with ChangeNotifier {
  MQTTClientWrapper? _mqttProtocol;
  MqttServerClient? _client;

  MQTTClientWrapper get mqttProtocol => _mqttProtocol!;

  MqttServerClient get client => _client!;

  void setClient(
      {required MQTTClientWrapper mqttProtocol,
      required MqttServerClient client}) {
    _client = client;
    _mqttProtocol = mqttProtocol;
  }

  void resetMqtt() {
    _mqttProtocol = null;
    _client = null;
  }
}
