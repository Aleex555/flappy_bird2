import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Opponent extends SpriteAnimationComponent {
  final String id;
  Color color = Colors.white;
  late Vector2 targetPosition;
  double interpolationSpeed =
      5.0; // Controla qué tan rápido se mueve hacia targetPosition

  Opponent({
    required this.id,
    required this.color,
    required Vector2 initialPosition,
    Vector2? targetPosition,
  }) : super(
            position: initialPosition,
            size: Vector2.all(50)); // Usa initialPosition

  @override
  Future<void> onLoad() async {
    String imagePath = _getImagePathForColor(color);
    animation = await SpriteAnimation.load(
      imagePath,
      SpriteAnimationData.sequenced(
        amount: 4,
        textureSize: Vector2.all(16),
        stepTime: 0.12,
      ),
    );
  }

  String _getImagePathForColor(Color color) {
    // Asumiendo que 'color' es el Color de Flutter y que mapeas estos a tus colores definidos
    if (color == Colors.red) {
      // Vermell
      return 'embervermell.png';
    } else if (color == Colors.blue) {
      // Blau
      return 'emberblau.png';
    } else if (color == Colors.orange) {
      // Taronja
      return 'embertaronja.png';
    } else if (color == Colors.green) {
      // Verd
      return 'emberverd.png';
    } else {
      return 'ember.png'; // Un color por defecto si no se reconoce el color
    }
  }

  // Tu implementación de _getImagePathForColor...

  @override
  void update(double dt) {
    super.update(dt);

    // Interpola la posición hacia targetPosition
    final distance = targetPosition - position;
    if (distance.length > 1.0) {
      // Verifica que la distancia sea suficiente para moverse
      position += distance.normalized() * interpolationSpeed * dt;
    }
  }
}
