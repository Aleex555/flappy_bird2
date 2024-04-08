import 'dart:math';

import 'package:flame/components.dart';

import 'box.dart';
import 'game.dart';

class BoxStack extends PositionComponent with HasGameRef<FlappyEmberGame> {
  @override
  Future<void> onLoad() async {
    position.x = gameRef.size.x;
    final gameHeight = gameRef.size.y;
    const boxHeight = 50;
    const boxSpacing = boxHeight * (2 / 3);
    final initialY = gameRef.isBottom ? gameHeight - boxHeight : -boxHeight / 3;
    final boxes = List.generate(gameRef.stackHeight, (i) {
      return Box(
        position:
            Vector2(0, initialY + i * boxSpacing * (gameRef.isBottom ? -1 : 1)),
      );
    });
    addAll(gameRef.isBottom ? boxes : boxes.reversed);
  }

  @override
  void update(double dt) {
    if (position.x < -Box.initialSize.x) {
      removeFromParent();
    }
    position.x -= gameRef.speed * dt;
  }
}
