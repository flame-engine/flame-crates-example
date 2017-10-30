Hello, everyone! I'm Luan and welcome to this first comprehensive Flame tutorial.

Flame is a minimalist Flutter game engine that provides a few modules to make a Canvas-based game.

In this tutorial, we are going to create a very simple game, where boxes will fall and the goal is to destroy them before they hit the bottom of the screen.

This will allow us to cover all the features provided by the framework, and demonstrate how to perform the most basic operations: rendering, sprites, audio, text, animations, and more.

Why did we select this game though? Apart from being very simple yet complete for exploration of the framework, one good factor is that we have the resources to do it!

For this game, we are going to use the following resources: one crate sprite, one explosion sprite (with animation), an explosion sound, a 'miss' sound (for when the box is not hit), a background music and also a pretty font for rendering the score.

As for now, sprite sheets are not supported, so, first, we need to convert all the resources to appropriated formats. Also, we need to convert all the audio for MP3 (OGG is also supported; WAV is not). That being all done, you can download a bundle with everything you will need resource-wise [here](https://github.com/luanpotter/flame-example/raw/master/tutorial/bundle.zip).

Also worth mentioning, everything described here is committed, as a fully-functional complete version, on [GitHub](https://github.com/luanpotter/flame-example). You can always take a look when in doubt. Also, the example was created following this exact steps, and taking frequent commits as snapshots. Throughout the tutorial, I will link the specific commits that advance the repository to the stage in question. This will allow you to make checkpoints and browse the old code to see anything that wasn't clear.

Apart from that, you will also need Flutter and Dart installed. If it suits you, you can also have IntelliJ IDEA, which is a very good place to write your code. In order to install this stuff, you can check out a plethora of tutorials out there, like [this one](https://flutter.io/setup/).

So, for now, I'll assume you have everything ready. So, just run the following and open it up!

```bash
    flutter create <your_name>
```

The first thing you need to do is to add the `flame` dependency. Go to your `pubspec.yaml` file and make sure the dependencies key lists flame:

```yaml
  dependencies:
    flutter:
      sdk: flutter
    flame: ^0.5.0
```

Here we are using the latest version, `0.5.0`, but you can also choose a new one if available.

Now, your main.dart file has a lot of stuff already: a 'main' method that needs to be kept; and a subsequent call to runApp method. This method takes Widgets and other Flutter components that are used to make app screens. Since we are making a game, we are going to draw everything on the Canvas, and won't use these components; so strip all that out.

Our main method is now empty, and we are going to add two things; first, some configuration:

```dart
    import 'package:flame/flame.dart';

    void main() {
        Flame.util.enableEvents();
        Flame.audio.disableLog();
    }
```

The `flame.dart` import gives access to the Flame static class, which is just a holder for several useful other classes. We will be using more of this later. For now, we are calling two methods in this Flame class.

The last one is self-explanatory, it disables some of the logging from `audioplayers` plugin. Now, shortly we will be adding audio to the game, and if it doesn't work, that's where you need to comment in order to troubleshoot. But we will get there eventually.

The first line is more complex. Basically, some crucial functionality from Flutter is absent because we are not using the runApp method. This `enableEvents` call does a bit of a workaround to get what is essential for every application, without the need of using Widgets.

Finally, we need to start our game. In order to do that, we are going to add one more class to the import list, the Game class. This class provides the abstraction necessary to create any game: a game loop. It must be subclassed so that you are required to implement the basis of any game: an update method, which is called whenever convenient and takes the amount of time passed since last update, and a render method, which has to know how to draw the current state of the game. The inner-workings of the loop are left for the Game class to solve (you can take a look, of course, it's very simple), and you just need to call start to, well, start.

```dart
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
```

> Checkpoint: [599f809](https://github.com/luanpotter/flame-example/commit/599f8090478e0597d1ee939b9b13c895f7314875)

PRINT HERE

Right now, the render doesn't do anything, so, if you boot it up, it should run, but give you a black screen. Sweet! So we got a functional app without any widgets and whatnot, and a blank canvas to start drawing our app.

And how is drawing done? Let's draw a simple rectangle to see it in action. Add the following to your render method:

```dart
    var rect = new Rect.fromLTWH(10.0, 10.0, 100.0, 100.0);
    var paint = new Paint()..color = new Color(0xFFFF0000);
    canvas.drawRect(rect, paint);
```

Here, as you can see, we define a rectangle, based on screen positions. The following image shows how to rules are oriented. Basically, the origin is in the top left corner, and the axis increase to the right and downwards.

![Screen Rules](https://github.com/luanpotter/flame-example/raw/master/tutorial/screenshots/print0.png)

Also, note that most `draw` methods take a Paint. A Paint is not just a single color, but could be a Degradè or some other textures. Normally, you would either want a solid color or go straight to a Sprite. So we just set the color inside the paint to an instance of Color.

Color represents a single ARGB color; you create it with an integer that you can write down in hex for easier reading; it's in the format A (alpha, transparency, normally 0xFF), and then two digits for R, G and B in that order.

There is also a collection of named colors; it's is inside material package though. Just beware to import just the Colors module, as not to accidentally use something else from the material package.

```dart
    import 'packages:flutter/material.dart' show Colors;

    var white = Colors.white;
```
So, great, now we have a square!

> Checkpoint: [4eff3bf](https://github.com/luanpotter/flame-example/commit/4eff3bf1eebb60ca4fd070b183b94950229ac8ae)

We also know how the rules work, but we don't know the screen dimensions! How are we going to draw something in the other three corners without this information? Fear not, as Flame has a method to fetch the actual dimension of the screen (that's because there is a documented [issue around that](https://github.com/flutter/flutter/issues/5259).

Basically, the async method

```dart
    var dimensions = await Flame.util.initialDimensions();
```

Note that the await keyword, just like in JavaScript, can only be used in an async function, so make sure to make your main async (Flutter won't care).

The next checkpoint will fetch the dimensions once in the main method and store them inside our Game class, because we are going to need them repeatedly.

> Checkpoint: [a1f9df3](https://github.com/luanpotter/flame-example/commit/a1f9df377d6a608df7f89bfdf557f6a25f057556)

Finally, we know how to draw any shape, anywhere on the screen. But we want sprites! The next checkpoint adds some of the assets we are going to use in the appropriate assets folder:

> Checkpoint: [92ebfd9](https://github.com/luanpotter/flame-example/commit/92ebfd96333a0df9f68f11f0b469c56ab0132771)

And the next one does one crucial thing you **cannot** forget: add everything to your `pubsepc.yaml` file. When your code is being built, Dart will only bundle the resources you specify there.

> Checkpoint [cf5975f](https://github.com/luanpotter/flame-example/commit/cf5975fd7d17a4be3b7fbb6511c6dbfb3d2d508a)

Finally, we are ready to draw our sprite. The basic way Flame allows you to do that is to expose a `Flame.images.load('path from within the images folder')` method that returns a promise for the loaded image, which can be then drawn with the `canvas.drawImage` method.

However, in the simple case of drawing a crate, it's very simpler to do, because we can use the `SpriteComponent` class, like so:

```dart
class Crate extends SpriteComponent {
  Crate() : super.square(128.0, 'crate.png') {
    this.angle = 0.0;
  }
}
```

The abstract Component class is an interface with two methods, render and update, just like our game. The idea is that the Game can be composed of Component's that have their render and update methods called within the Game's methods. SpriteComponent is an implementation that renders a sprite, given its name and size (square or width), the (x, y) position and the rotation angle. It will appropriately shrink or expand the image to fit the size desired.

In this case, we load the 'crate.png' file, that must be in the assets/images folder, and have a Crate class that draw boxes of 128x128 pixels, with rotation angle 0.

We then add a Crate property to the Game, instantiate it on the top of the screen, centered horizontally, and render it in our game loop:

```dart
    // in Game's constructor
    this.crate = new Crate();
    this.crate.x = dimensions.width / 2;
    this.crate.y = 200.0;
    // in the render method
    this.crate.render(canvas);
```

This will render our Crate! Awesome! The code is pretty succinct and easy to read as well.

> Checkpoint [7603ca4](https://github.com/luanpotter/flame-example/commit/7603ca48859056f5811f0a0e11100c395b507355)
