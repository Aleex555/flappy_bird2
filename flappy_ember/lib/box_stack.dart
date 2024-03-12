import 'package:flame/components.dart';
import 'package:flappy_ember/box.dart';
import 'package:flappy_ember/game.dart'; // Asegúrate de tener la referencia correcta a tu juego aquí

class BoxStack extends PositionComponent with HasGameRef<FlappyEmberGame> {
  late final List<Box> boxes;
  late double speed;

  BoxStack({
    required List<dynamic> boxesData,
    required this.speed,
  }) {
    // Crea las cajas a partir de los datos proporcionados
    boxes = boxesData
        .map((data) => Box(
              position: Vector2(data['x'] as double, data['y'] as double),
            ))
        .toList();
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    // Añade todas las cajas como componentes hijos
    for (var box in boxes) {
      add(box);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Mueve la pila de cajas hacia la izquierda
    position.add(Vector2(-speed * dt, 0));

    // Si la pila de cajas sale de la pantalla, la marca para ser eliminada
    if (position.x + size.x < 0) {
      removeFromParent();
    }
  }
}
