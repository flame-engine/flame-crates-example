import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flame/flame.dart';

main() async {
  Flame.util.enableEvents();
  Flame.audio.disableLog();

  var dimensions = await Flame.util.initialDimensions();
  new MyGame(dimensions).start();
}

class MyGame extends Game {

  Size dimensions;

  MyGame(this.dimensions);

  @override
  void render(Canvas canvas) {
    var rect = new Rect.fromLTWH(100.0, 100.0, dimensions.width - 200.0, dimensions.height - 200.0);
    var paint = new Paint()..color = new Color(0xFFFF0000);
    canvas.drawRect(rect, paint);
  }

  @override
  void update(double t) {
    // TODO: implement update
  }
}