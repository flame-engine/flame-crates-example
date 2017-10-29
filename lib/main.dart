import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flame/component.dart';
import 'package:flame/flame.dart';

const SPEED = 100.0;
const CRATE_SIZE = 128.0;

main() async {
  Flame.util.enableEvents();
  Flame.audio.disableLog();

  var dimensions = await Flame.util.initialDimensions();
  var game = new MyGame(dimensions)..start();
  window.onPointerDataPacket = (packet) {
    var pointer = packet.data.first;
    game.input(pointer.physicalX, pointer.physicalY);
  };
}

class Crate extends SpriteComponent {
  Crate() : super.square(CRATE_SIZE, 'crate.png') {
    this.angle = 0.0;
  }
}

class MyGame extends Game {

  Size dimensions;
  List<Crate> crates = [];

  MyGame(this.dimensions) {
    crates.add(crate(dimensions.width / 2));
  }

  static Crate crate(double x) {
    Crate crate = new Crate();
    crate.x = x;
    crate.y = 200.0;
    return crate;
  }

  @override
  void render(Canvas canvas) {
    crates.forEach((crate) => crate.render(canvas));
  }

  @override
  void update(double t) {
    crates.forEach((crate) => crate.y += t * SPEED);
  }

  void input(double x, double y) {
    crates.removeWhere((crate) {
      double dx = (crate.x - x).abs();
      double dy = (crate.y - y).abs();
      var diff = CRATE_SIZE / 2;
      return (dx < diff && dy < diff);
    });
  }
}