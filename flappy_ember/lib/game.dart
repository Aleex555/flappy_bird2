// Importaciones necesarias
import 'dart:convert';
import 'dart:ui';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/src/components/core/component.dart';
import 'package:flappy_ember/appdata.dart';
import 'package:flappy_ember/box_stack.dart';
import 'package:flappy_ember/ground.dart';
import 'package:flappy_ember/opponent.dart';
import 'package:flappy_ember/player.dart';
import 'package:flappy_ember/sky.dart';
import 'package:flappy_ember/websockets_handler.dart';
import 'package:flutter/material.dart';

class FlappyEmberGame extends FlameGame
    with HasCollisionDetection, TapDetector {
  Function? onGameStart;
  FlappyEmberGame() {
    _initializeWebSocket();
  }

  late final WebSocketsHandler _webSocketsHandler;
  double speed = 200;
  late final Player _player = Player();
  double _timeSinceBox = 0;
  double _boxInterval = 1;
  double _timeSinceLastUpdate = 0;
  final double updateInterval = 0.5;
  List<dynamic> connectedPlayers = [];
  Map<String, Opponent> opponents = {};

  @override
  Future<void> onLoad() async {
    add(_player);
    add(Sky());
    add(Ground());
    add(ScreenHitbox());
  }

  @override
  void onTap() {
    _player.fly();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _timeSinceBox += dt;
    if (_timeSinceBox > _boxInterval) {
      add(BoxStack());
      _timeSinceBox = 0;
    }
    // Envía la posición del jugador al servidor cada updateInterval segundos
    _timeSinceLastUpdate += dt;
    if (_timeSinceLastUpdate >= updateInterval) {
      _sendPlayerPosition();
      _timeSinceLastUpdate = 0;
    }
  }

  void _initializeWebSocket() {
    _webSocketsHandler = WebSocketsHandler();
    _webSocketsHandler.connectToServer("localhost", 8888, _onMessageReceived);
  }

  void _onMessageReceived(String message) {
    final data = jsonDecode(message);

    switch (data['type']) {
      case 'welcome':
        _webSocketsHandler.sendMessage(jsonEncode({
          'type': 'init',
          'name': "sghdjfhg",
        }));
        print("Welcome: ${data['value']}");
        String assignedColorHex = data['color'] as String;
        Color assignedColor;
        if (RegExp(r'^#([0-9A-Fa-f]{6})$').hasMatch(assignedColorHex)) {
          // Es un valor hexadecimal, convertirlo a un Color
          assignedColor =
              Color(int.parse(assignedColorHex.replaceFirst('#', '0xff')));
        } else {
          // No es un valor hexadecimal, buscar en un mapeo de nombres de colores conocidos
          assignedColor = _colorFromName(assignedColorHex) ??
              Colors.black; // Usar negro como color por defecto
        }
        // Cambiar el color del jugador
        _player.changeColor(assignedColor);
        break;
      case 'data':
        List<dynamic> opponentsData = data['opponents'] as List<dynamic>;
        for (var oppData in opponentsData) {
          final id = oppData['id'].toString();
          if (id == _webSocketsHandler.mySocketId) {
            // Ignora los datos si pertenecen al jugador actual
            continue;
          }
          final x = oppData['x'] as double;
          final y = oppData['y'] as double;

          // Si el oponente ya existe, actualiza su posición.
          // De lo contrario, crea un nuevo Opponent y lo agrega al juego.
          if (opponents.containsKey(id)) {
            final opponent = opponents[id]!;
            opponent.targetPosition = Vector2(x, y);
          } else {
            // Aquí, necesitas decidir cómo obtener el color u otras propiedades del oponente.
            // Para este ejemplo, simplemente se utiliza un color predeterminado.
            Color? color1 = _colorFromName(oppData['color'] as String);

            final newOpponent = Opponent(
              id: id,
              color: color1!,
              initialPosition: Vector2(0, 0),
              targetPosition: Vector2(0, 0),
            );
            opponents[id] = newOpponent;
            add(newOpponent);
          }
        }
        break;
      case 'playerListUpdate':
        break;
      case "gameStart":
        onGameStart?.call();
        break;
    }
  }

  Color? _colorFromName(String name) {
    switch (name) {
      case 'vermell':
        return Colors.red;
      case 'verd  ':
        return Colors.green;
      case 'taronja':
        return Colors.orange;
      case 'blau':
        return Colors.blue;
      default:
        return null;
    }
  }

  void _sendPlayerPosition() {
    _webSocketsHandler.sendMessage(jsonEncode({
      'type': 'move',
      'x': _player.x,
      'y': _player.y,
    }));
  }

  void disconnect() {
    _webSocketsHandler.disconnectFromServer();
  }

  @override
  void onRemove() {
    _webSocketsHandler.disconnectFromServer();
    super.onRemove();
  }
}
