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
    // TODO: implement render
  }

  @override
  void update(double t) {
    // TODO: implement update
  }
}