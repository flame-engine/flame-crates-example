import 'dart:math';
import 'dart:ui';

import 'package:flame/components/animation_component.dart';
import 'package:flame/components/component.dart';
import 'package:flame/components/mixins/has_game_ref.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/palette.dart';
import 'package:flame/position.dart';
import 'package:flame/text_config.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' show runApp;

const SPEED = 250.0;
const CRATE_SIZE = 64.0;

final rnd = Random();
final textConfig = TextConfig(
  color: BasicPalette.white.color,
  fontSize: 48.0,
  fontFamily: 'Halo',
);

void main() async {
  await Flame.init();
  await Flame.images.loadAll(['explosion.png', 'crate.png']);

  final game = MyGame();

  Flame.audio.loop('music.ogg');
  runApp(game.widget);
}

class Crate extends SpriteComponent with HasGameRef<MyGame> {
  bool explode = false;
  double maxY;

  Crate() : super.square(CRATE_SIZE, 'crate.png');

  @override
  void update(double dt) {
    super.update(dt);
    y += dt * SPEED;
  }

  @override
  bool destroy() {
    if (explode) {
      return true;
    }
    if (y == null || maxY == null) {
      return false;
    }
    final destroy = y >= maxY + CRATE_SIZE / 2;
    if (destroy) {
      gameRef.points -= 20;
      Flame.audio.play('miss.mp3');
    }
    return destroy;
  }

  @override
  void resize(Size size) {
    x = rnd.nextDouble() * (size.width - CRATE_SIZE);
    y = 0.0;
    maxY = size.height;
  }
}

class Explosion extends AnimationComponent {
  static const TIME = 0.75;

  Explosion(Crate crate)
      : super.sequenced(
          CRATE_SIZE,
          CRATE_SIZE,
          'explosion.png',
          7,
          textureWidth: 31.0,
          textureHeight: 31.0,
          destroyOnFinish: true,
        ) {
    x = crate.x;
    y = crate.y;
    animation.stepTime = TIME / 7;
  }
}

class MyGame extends BaseGame with TapDetector {
  double creationTimer = 0.0;
  int points = 0;

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final text = points.toString();
    textConfig.render(canvas, text, Position(15, 15));
  }

  @override
  void update(double dt) {
    creationTimer += dt;
    if (creationTimer >= 1) {
      creationTimer -= 1;
      add(Crate());
    }
    super.update(dt);
  }

  @override
  void onTapDown(TapDownDetails details) {
    final position = details.globalPosition;
    components.forEach((component) {
      if (!(component is Crate)) {
        return;
      }
      final crate = component as Crate;
      final remove = crate.toRect().contains(position);
      if (remove) {
        crate.explode = true;
        add(Explosion(crate));
        Flame.audio.play('explosion.mp3');
        points += 10;
      }
    });
  }
}
