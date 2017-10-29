import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart' show Colors;

import 'package:flame/game.dart';
import 'package:flame/component.dart';
import 'package:flame/flame.dart';

const SPEED = 250.0;
const CRATE_SIZE = 128.0;

var points = 0;

main() async {
  Flame.util.enableEvents();
  Flame.audio.disableLog();

  Explosion.fetch();

  var dimensions = await Flame.util.initialDimensions();

  Flame.audio.loop('music.ogg');

  var game = new MyGame(dimensions)..start();
  window.onPointerDataPacket = (packet) {
    var pointer = packet.data.first;
    game.input(pointer.physicalX, pointer.physicalY);
  };
}

class Crate extends SpriteComponent {
  double maxY;

  Crate() : super.square(CRATE_SIZE, 'crate.png') {
    this.angle = 0.0;
  }

  @override
  void update(double t) {
    y += t * SPEED;
  }

  bool destroy() {
    return y >= maxY + CRATE_SIZE / 2;
  }
}

class Explosion extends PositionComponent {
  static final Paint paint = new Paint()..color = new Color(0xffffffff);
  static List<Image> images = [];
  static const TIME = 0.75;

  double lifeTime = 0.0;

  Explosion(Crate crate) {
    this.x = crate.x;
    this.y = crate.y;
  }

  static fetch() async {
    for (var i = 0; i <= 6; i++) {
      images.add(await Flame.images.load('explosion-' + i.toString() + '.png'));
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.translate(x - CRATE_SIZE / 2, y - CRATE_SIZE / 2);
    int i = (6 * this.lifeTime / TIME).round();
    if (images.length > i && images[i] != null) {
      Image image = images[i];
      Rect src = new Rect.fromLTWH(0.0, 0.0, image.width.toDouble(), image.height.toDouble());
      Rect dst = new Rect.fromLTWH(0.0, 0.0, CRATE_SIZE, CRATE_SIZE);
      canvas.drawImageRect(image, src, dst, paint);
    }
  }

  @override
  void update(double t) {
    this.lifeTime += t;
  }

  bool destroy() {
    return this.lifeTime >= TIME;
  }
}

Random rnd = new Random();

class MyGame extends Game {

  Size dimensions;
  List<Crate> crates = [];
  List<Explosion> explosions = [];
  double creationTimer = 0.0;

  MyGame(this.dimensions) {
    crates.add(crate(dimensions.width / 2));
  }

  Crate crate(double x) {
    Crate crate = new Crate();
    crate.x = x;
    crate.y = 200.0;
    crate.maxY = this.dimensions.height;
    return crate;
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    crates.forEach((crate) {
      crate.render(canvas);
      canvas.restore();
      canvas.save();
    });
    explosions.forEach((exp) {
      exp.render(canvas);
      canvas.restore();
      canvas.save();
    });

    String text = points.toString();
    Paragraph p = Flame.util.text(text, color: Colors.white, fontSize: 48.0, fontFamily: 'Halo');
    canvas.drawParagraph(p, new Offset(this.dimensions.width - p.width - 10, this.dimensions.height - p.height - 10));
  }

  @override
  void update(double t) {
    this.creationTimer += t;
    if (this.creationTimer >= 1) {
      this.creationTimer = 0.0;
      this.newCrate();
    }
    crates.forEach((crate) => crate.update(t));
    crates.removeWhere((crate) {
      bool destroy = crate.destroy();
      if (destroy) {
        points -= 20;
        Flame.audio.play('miss.mp3');
      }
      return destroy;
    });
    explosions.forEach((exp) => exp.update(t));
    explosions.removeWhere((exp) => exp.destroy());
  }

  void input(double x, double y) {
    crates.removeWhere((crate) {
      double dx = (crate.x - x).abs();
      double dy = (crate.y - y).abs();
      var diff = CRATE_SIZE / 2;
      var remove = (dx < diff && dy < diff);
      if (remove) {
        explosions.add(new Explosion(crate));
        Flame.audio.play('explosion.mp3');
        points += 10;
      }
      return remove;
    });
  }

  void newCrate() {
    double x = CRATE_SIZE/2 + rnd.nextDouble() * (this.dimensions.width - CRATE_SIZE);
    crates.add(crate(x));
  }
}