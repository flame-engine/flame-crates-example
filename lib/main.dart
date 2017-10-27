import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flame/flame.dart';

void main() {
  Flame.util.enableEvents();
  Flame.audio.disableLog();

  new MyGame().start();
}

class MyGame extends Game {

  @override
  void render(Canvas canvas) {
    var rect = new Rect.fromLTWH(10.0, 10.0, 100.0, 100.0);
    var paint = new Paint()..color = new Color(0xFFFF0000);
    canvas.drawRect(rect, paint);
  }

  @override
  void update(double t) {
    // TODO: implement update
  }
}