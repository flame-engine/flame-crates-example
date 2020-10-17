import 'dart:math';
import 'dart:ui';

import 'package:flame/components/mixins/has_game_ref.dart';
import 'package:flame/components/mixins/resizable.dart';
import 'package:flame/components/sprite_component.dart';
import 'package:flame/components/sprite_animation_component.dart';
import 'package:flame/extensions/vector2.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/palette.dart';
import 'package:flame/text_config.dart';
import 'package:flame_audio/flame_audio.dart';
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

  FlameAudio.loop('music.ogg');
  runApp(game.widget);
}

class Crate extends SpriteComponent with HasGameRef<MyGame>, Resizable {
  bool explode = false;

  Crate(Vector2 gameSize)
      : super.fromImage(
          Vector2.all(CRATE_SIZE),
          Flame.images.fromCache('crate.png'),
        ) {
    x = rnd.nextDouble() * (gameSize.x - CRATE_SIZE);
    y = 0.0;
  }

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
    if (y == null || gameSize == null) {
      return false;
    }
    final destroy = y >= gameSize.y + CRATE_SIZE / 2;
    if (destroy) {
      gameRef.points -= 20;
      FlameAudio.play('miss.mp3');
    }
    return destroy;
  }
}

class Explosion extends SpriteAnimationComponent {
  static const TIME = 0.75;

  Explosion(Crate crate)
      : super.sequenced(
          Vector2.all(CRATE_SIZE),
          Flame.images.fromCache('explosion.png'),
          7,
          textureSize: Vector2.all(31),
          destroyOnFinish: true,
        ) {
    position = crate.position.clone();
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
    textConfig.render(canvas, text, Vector2.all(15));
  }

  @override
  void update(double dt) {
    creationTimer += dt;
    if (creationTimer >= 1) {
      creationTimer = 0;
      add(Crate(size));
    }
    super.update(dt);
  }

  @override
  void onTapDown(TapDownDetails details) {
    final position = details.globalPosition;
    components.whereType<Crate>().forEach((crate) {
      final remove = crate.toRect().contains(position);
      if (remove) {
        crate.explode = true;
        add(Explosion(crate));
        FlameAudio.play('explosion.mp3');
        points += 10;
      }
    });
  }
}
