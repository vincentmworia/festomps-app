import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

enum MqttSubscriptionState {
  idle,
  subscribed,
}

class MQTTClientWrapper with ChangeNotifier {
  MqttCurrentConnectionState get connectionState => _connectionState;
  MqttServerClient? client;

  MqttCurrentConnectionState _connectionState = MqttCurrentConnectionState.idle;
  MqttSubscriptionState subscriptionState = MqttSubscriptionState.idle;

  // using async tasks, so the connection won't hinder the code flow
  Future<MqttServerClient?> prepareMqttClient() async {
    client = MqttServerClient.withPort(
        '8a32997794c84b92a769a6a46bb1582f.s1.eu.hivemq.cloud',
        'Vincent Mworia',
        8883);
    client!.secure = true;
    client!.securityContext = SecurityContext.defaultContext;
    client!.keepAlivePeriod = 20;
    client!.onDisconnected = _onDisconnected;
    client!.onConnected = _onConnected;
    client!.onSubscribed = _onSubscribed;

    try {
      _connectionState = MqttCurrentConnectionState.connecting;
      await client!.connect('Vincent Mworia', 'mwendamworia');
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      _connectionState = MqttCurrentConnectionState.errorWhenConnecting;
      client!.disconnect();
    }
    if (client!.connectionStatus?.state == MqttConnectionState.connected) {
      _connectionState = MqttCurrentConnectionState.connected;
    } else {
      _connectionState = MqttCurrentConnectionState.errorWhenConnecting;
      client!.disconnect();
    }
    if(kDebugMode){
      print('ACTION TIME');
    }
    return client;

    // _subscribeToTopic('Stations/Distribution/Monitor');
    // _publishMessage('Stations/Distribution/Control',
    //     '{start: true, stop: true, reset:false,SAWA ,}');
  }

  void publishMessage(String topic, String message) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);
    if (kDebugMode) {
      print('Publishing message "$message" to topic $topic');
    }

    client!.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
  }

  // callbacks for different events
  void _onSubscribed(String topic) {
    if (kDebugMode) {
      print('Subscription confirmed for topic $topic');
    }
    subscriptionState = MqttSubscriptionState.subscribed;
  }

  void _onDisconnected() {
    _connectionState = MqttCurrentConnectionState.disconnected;
  }

  void _onConnected() {
    _connectionState = MqttCurrentConnectionState.connected;
    if (kDebugMode) {
      print('OnConnected client callback - Client connection was sucessful');
    }
  }
}

// connection states for easy identification
enum MqttCurrentConnectionState {
  idle,
  connecting,
  connected,
  disconnected,
  errorWhenConnecting
}

String prepareStateMessageFrom(MqttCurrentConnectionState state) {
  String stateText = 'Null';
  switch (state) {
    case MqttCurrentConnectionState.idle:
      stateText = 'Idle';
      break;
    case MqttCurrentConnectionState.connecting:
      stateText = 'connecting';
      break;
    case MqttCurrentConnectionState.connected:
      stateText = 'Connected';
      break;
    case MqttCurrentConnectionState.disconnected:
      stateText = 'Disconnected';
      break;
    case MqttCurrentConnectionState.errorWhenConnecting:
      stateText = 'Error when connecting';
      break;
  }
  return stateText;
}
