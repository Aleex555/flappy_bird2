import 'dart:ffi';

import 'package:flame/game.dart';
import 'package:flappy_ember/game.dart';
import 'package:flutter/material.dart';

enum ConnectionStatus {
  setupscreen,
  playersscreen,
}

class AppData with ChangeNotifier {
  List<dynamic> connectedPlayers = [];
  String namePlayer = "";
  bool partida = false;
  ConnectionStatus connectionStatus = ConnectionStatus.setupscreen;

  void forceNotifyListeners() {
    super.notifyListeners();
  }

  void setUsuarios(List<dynamic> value) {
    connectedPlayers = value;
    notifyListeners();
  }

  void setNamePlayer(String value) {
    namePlayer = value;
    notifyListeners();
  }

  String getNamePlayer() {
    return namePlayer;
  }

  void setPartida(bool value) {
    partida = value;
    notifyListeners();
  }

  bool getPartida() {
    return partida;
  }
}
