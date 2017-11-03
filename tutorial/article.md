## Introduction

Hello, everyone! I'm Luan and welcome to this first comprehensive Flame tutorial.

Flame is a minimalist Flutter game engine that provides a few modules to make a Canvas-based game.

In this tutorial, we are going to create a very simple game, where boxes will fall and the goal is to destroy them before they hit the bottom of the screen.

<img src="https://github.com/luanpotter/flame-example/raw/master/tutorial/screenshots/print1.png" alt="Game Running" width="250">

You can check the game yourself to see what we are up to installing [this APK](https://github.com/luanpotter/flame-example/raw/master/tutorial/flame_example.apk), or installing it [from the Play Store](https://play.google.com/store/apps/details?id=xyz.luan.flame.example).

This will allow us to cover all the features provided by the framework, and demonstrate how to perform the most basic operations: rendering, sprites, audio, text, animations, and more.

Why did we select this game though? Apart from being very simple yet complete for exploration of the framework, one good factor is that we have the resources to do it!

For this game, we are going to use the following resources: one crate sprite, one explosion sprite (with animation), an explosion sound, a 'miss' sound (for when the box is not hit), a background music and also a pretty font for rendering the score.

As for now, sprite sheets are not supported, so, first, we need to convert all the resources to appropriated formats. Also, we need to convert all the audio for MP3 (OGG is also supported; WAV is not). That being all done, you can download a bundle with everything you will need resource-wise [here](https://github.com/luanpotter/flame-example/raw/master/tutorial/bundle.zip).

Also worth mentioning, everything described here is committed, as a fully-functional complete version, on [GitHub](https://github.com/luanpotter/flame-example). You can always take a look when in doubt. Also, the example was created following this exact steps, and taking frequent commits as snapshots. Throughout the tutorial, I will link the specific commits that advance the repository to the stage in question. This will allow you to make checkpoints and browse the old code to see anything that wasn't clear.

One last thing; you can check the full documentation [here](https://github.com/luanpotter/flame/blob/master/README.md). If you have any questions, suggestions, bugs, feel free to open an issue or contact me.

Apart from that, you will also need Flutter and Dart installed. If it suits you, you can also have IntelliJ IDEA, which is a very good place to write your code. In order to install this stuff, you can check out a plethora of tutorials out there, like [this one](https://flutter.io/setup/).

## Basics

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

Right now, the render doesn't do anything, so, if you boot it up, it should run, but give you a black screen. Sweet! So we got a functional app without any widgets and whatnot, and a blank canvas to start drawing our app.

## Rendering Shapes

And how is drawing done? Let's draw a simple rectangle to see it in action. Add the following to your render method:

```dart
    var rect = new Rect.fromLTWH(10.0, 10.0, 100.0, 100.0);
    var paint = new Paint()..color = new Color(0xFFFF0000);
    canvas.drawRect(rect, paint);
```

Here, as you can see, we define a rectangle, based on screen positions. The following image shows how to rules are oriented. Basically, the origin is in the top left corner, and the axis increase to the right and downwards.

<img src="https://github.com/luanpotter/flame-example/raw/master/tutorial/screenshots/print0.png" alt="Screen Rules" width="250">

Also, note that most `draw` methods take a Paint. A Paint is not just a single color, but could be a Degradè or some other textures. Normally, you would either want a solid color or go straight to a Sprite. So we just set the color inside the paint to an instance of Color.

Color represents a single ARGB color; you create it with an integer that you can write down in hex for easier reading; it's in the format A (alpha, transparency, normally 0xFF), and then two digits for R, G and B in that order.

There is also a collection of named colors; it's is inside material package though. Just beware to import just the Colors module, as not to accidentally use something else from the material package.

```dart
    import 'packages:flutter/material.dart' show Colors;

    var white = Colors.white;
```
So, great, now we have a square!

> Checkpoint: [4eff3bf](https://github.com/luanpotter/flame-example/commit/4eff3bf1eebb60ca4fd070b183b94950229ac8ae)

We also know how the rulers work, but we don't know the screen dimensions! How are we going to draw something in the other three corners without this information? Fear not, as Flame has a method to fetch the actual dimension of the screen (that's because there is a documented [issue around that](https://github.com/flutter/flutter/issues/5259).

Basically, the async method

```dart
    var dimensions = await Flame.util.initialDimensions();
```

Note that the await keyword, just like in JavaScript, can only be used in an async function, so make sure to make your main async (Flutter won't care).

The next checkpoint will fetch the dimensions once in the main method and store them inside our Game class, because we are going to need them repeatedly.

> Checkpoint: [a1f9df3](https://github.com/luanpotter/flame-example/commit/a1f9df377d6a608df7f89bfdf557f6a25f057556)

## Rendering Sprites

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

In this case, we load the 'crate.png' file, that must be in the assets/images folder, and have a Crate class that draws boxes of 128x128 pixels, with rotation angle 0.

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

## Updating State in the Game Loop

Our crate is all but stopped in the air. We want to move it! Every crate is going to fall with constant speed, downwards. We need to do that in our update method; just change the Y position of the single Crate we have:

```dart
    @override
    void update(double t) {
        crate.y += t * SPEED;
    }
```

This method takes the time (in seconds) it took from the last update. Normally this is going to be very small (order of 10 ms). So the SPEED is a constant in those units; in our case, SPEED = 100 pixels/second.

> Checkpoint: [452dc40](https://github.com/luanpotter/flame-example/commit/452dc4054e2162b9ff09468517ba1c9ae8ae13e4)

## Handling Input

Hurray! The crates fall down and disappear, but you cannot interact with them. Let's add a method to destroy the crates we touch. For that, we are going to use a `window` event. The `window` object is available in every Flutter project globally, and it has a few useful properties. We are going to register on the main method an `onPointerDataPacket` event, that is, when the user taps the screen:

```dart
    window.onPointerDataPacket = (packet) {
        var pointer = packet.data.first;
        game.input(pointer.physicalX, pointer.physicalY);
    }
```

We just extract the (x,y) coordinate of the click and pass it straight to our Game; that way the Game can handle the click without worrying about events detail.

In order to make things more interesting, let's also refactor the Game class to have a List of Crates, instead of a single one. Afterall, that's what we want. We replace render and update methods with a forEach over the Crates, and the new input method becomes:

```dart
    void input(double x, double y) {
        crates.removeWhere((crate) {
            double dx = (crate.x - x).abs();
            double dy = (crate.y - y).abs();
            var diff = CRATE_SIZE / 2;
            return (dx < diff && dy < diff);
        });
    }
```

> Checkpoint: [364a6c2](https://github.com/luanpotter/flame-example/commit/364a6c20cc096050503c9dbca9797c68a9b13738)

## Rendering Multiple Sprites

There is one **crucial point** to mention here, and it's regarding the **render method**. When we render a Crate, the state of the Canvas is translated and rotate arbitrarily, in order to enable drawing. Since we are going to draw several crates, we need to **reset the Canvas between each drawn**. That is made with the methods `save`, that saves the current state, and `restore`, that restores the previously saved state, deleting it.

```dart
    @override
    void render(Canvas canvas) {
        canvas.save();
        crates.forEach((crate) {
            crate.render(canvas);
            canvas.restore();
            canvas.save();
        });
    }
```

This is an important remark, as it is the source of many weird bugs. Maybe we should do that automatically in each render? I don't know, what do you think?

Now we want more Crates! How to do that? Well, the update method can be our timer. So we want a new Crate to be added to the list (spawned) every second. So we created another variable in the Game class, to accumulate the delta times (`t`) from each update call. When it gets over 1, it's reset and a new crate spawned:

```dart
    @override
    void update(double t) {
        this.creationTimer += t;
        if (this.creationTimer >= 1) {
            this.creationTimer = 0.0;
            this.newCrate();
        }
        crates.forEach((crate) => crate.y += t * SPEED);
    }
```

Don't forget to keep the previous update, so the crates don't stop falling. Also, we change the speed to 250 pixels/second, to make things a little more interesting.

> Checkpoint: [3932372](https://github.com/luanpotter/flame-example/commit/3932372f737c1dc442f812e25be9598750d19d01)

## Rendering Animations

<img src="https://github.com/luanpotter/flame-example/raw/master/tutorial/screenshots/print2.png" alt="Explosion!" width="250">

*This should be a GIF, right? We are working on a setup for better prints and GIFs for this tutorial!*

Now we know the basics of Sprite Handling and Rendering. Let's move to the next step: Explosions! What game is good without 'em? The explosion is a beast of a different kind, because it features an animation. Animations in Flame are done simply by rendering different things on render according to the current tick. The same way we added a hand-made timer to spawn boxes, we are going to add a lifeTime property for every Explosion. Also, Explosion won't inherit from SpriteComponent, as for the latter can only have one Sprite. We are going to extend the superclass, PositionComponent, and implement rendering with `Flame.image.load`.

Since every explosion has lots of frames, and they need to be drawn responsively, we are going to pre-load every frame once, and save in a static variable within Explosion class; like so:

```dart
    static List<Image> images = [];
    static fetch() async {
        for (var i = 0; i <= 6; i++) {
            images.add(await Flame.images.load('explosion-' + i.toString() + '.png'));
        }
    }
```

Note that we load every one of our 7 animation frames, in order. Then, in the render method, we make a simple logic to decide which frame to draw:

```dart
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
```

Note that we are drawing 'by hand', using drawImageRect, as explained earlier. This code is similar to what SpriteComponent does under the hood. Also note that, if the image is not in the array, nothing is drawn - so after TIME seconds (we set it to 0.75, or 750 ms), nothing is rendered.

That's well and good, but we don't want to keep polluting our explosions array with exploded explosions, so we also add a destroy() method that returns, based on the lifeTime, whether we should destroy the explosion object.

Finally, we update our Game, adding a List of Explosion, rendering them on the render method, and updating then on the update method. They need to be updated to increment their lifeTime. We also take this time to refactor what was previously in the Game.update method, i.e., makes the boxes fall, to be inside the Crate.update method, as that's a responsibility of the Crate. Now the game update only delegates to others. Finally, in the update, we need to remove from the list what has been destroyed. For that, List provides a very useful method: removeWhere:

```dart
    explosions.removeWhere((exp) => exp.destroy());
```

We already used that on the input method, to remove the boxes that were touched from the array. There is also where we will create an explosion.

Take a look at the checkpoint for more details.

> Checkpoint: [d8c30ad](https://github.com/luanpotter/flame-example/commit/d8c30adca502ae5f7548dfcb40e715db348fa944)

## Playing Audio

In the next commit, we are finally going to play some audio! To do so, you need to add the file to the assets folder, inside `assets/audio/`. It must be an MP3 or an OGG file. Then, anywhere in your code, run:

```dart
    Flame.audio.play('filename.mp3');
```

Where `filename.mp3` is the name of the file inside. In our case, we will play the `explosion.mp3` sound when we click in a box.

Furthermore, let's start awarding punctuation. We add a `points` variable to hold the current number of points. It starts with zero; we get 10 points per box clicked, and lose 20 when the box hit the ground.

We now have an obligation to deal with runaway boxes. Based on what we did to the Explosion class, we add a destroy method for the Crate, that is going to return whether they are out of the screen. This is starting to become a pattern! If destroyed, we remove from the array and adjust the points.

For now, the scoring is working, but it's not being shown anywhere; that will come soon.

The audio will not work in this next checkpoint because I forgot to add the files and put them in the `pubspec.yaml`; that's done in the following commit.

> Checkpoint: [43a7570](https://github.com/luanpotter/flame-example/commit/43a7570304d954a8cb38b76f863d73bc7d75d081)

Now we want more sounds! The `audioplayers` (mind the s) lib the Flame uses allow you to play multiple sounds at once, as you might already have noticed if you went click frenzy, but now let's use that to our advantage, by playing a miss sound, when the box hits the ground (destroy method of the Crate), and a background music.

In order to play the background music on a loop, use the loop method, that works just like before:

```dart
    Flame.audio.loop('music.ogg');
```

In this commit, we also fix the destroy condition for the Crates, that we missed in the previous commit (because there was no way to know, now there is sound).

> Checkpoint: [f575150](https://github.com/luanpotter/flame-example/commit/f575150a2fbcad7ea6b19bff08c6d289ed8d5404)

## Rendering Text

Now that we have all the audio we want (background, music, sound effects, MP3, OGG, loop, simultaneously), let's get into text rendering. We need to see that score, after all. The way this is done 'by hand' is to create a Paragraph object and use the drawParagraph of the Canvas. It takes a lot of configuration and it's a rather confusing API, but can be accomplished like so:

```dart
    String text = points.toString(); // text to render
    ParagraphBuilder paragraph = new ParagraphBuilder(new ParagraphStyle());
    paragraph.pushStyle(new TextStyle(color: new Color(0xFFFFFFFF), fontSize: 48.0));
    paragraph.addText(text);
    var p = paragraph.build()..layout(new ParagraphConstraints(width: 180.0));
    canvas.drawParagraph(p, new Offset(this.dimensions.width - p.width - 10, this.dimensions.height - p.height - 10));
```

> Checkpoint: [e09221e](https://github.com/luanpotter/flame-example/commit/e09221e86c8f959bab1870173fa856f7f00f1951)

This is drawn in the default font, and you can use the fontFamily property to specify a different common system font; though, probably, in your game, you will want to add a custom one.

So I headed to 1001fonts.com and got [this pretty commercial free Halo font](www.1001fonts.com/halo3-font.html) as a TTF. Again, just drop the file in `assets/fonts`, but now it must be imported differently in the `pubspec.yaml` file. Instead of adding one more asset, there is a dedicated font tag, which is commented by default with complete instructions on how to add the fonts. So, assign it a name and do something like:

```yaml
    fonts:
     - family: Halo
       fonts:
        - asset: assets/fonts/halo.ttf 
```

This extra abstraction layer is from Flutter itself and allows you to add several files to the same font (to define bold, bigger sizes, etc). Now, back to our Paragraph, we just add the property `fontFamily: 'Halo'` to the `TextStyle` constructor.

Run and you will see the pretty Halo font!

> Checkpoint: [3155bda](https://github.com/luanpotter/flame-example/commit/3155bdaaf1ad35325e55ef7c08457c2d7350a9d6)

This method described will give you more control, if you want multiple styles in the same paragraph, for example. But if you want, like in this case, a single styled simple paragraph, just use the `Flame.util.text` helper to create it:

```dart
    Paragraph p = Flame.util.text(text, color: Colors.white, fontSize: 48.0, fontFamily: 'Halo');
```

This single line replaces those previous 4, and exposes the most important features. The text (first argument) is required, and all the rest are optional, with sensible defaults.

For the color, again we are using the `Colors.white` helper, but we can also use `new Color(0xFFFFFFFF)` if you want a specific color.

> Checkpoint: [952a9df](https://github.com/luanpotter/flame-example/commit/952a9dfd753d7e335359b4f7327e4f2bbc2938be)

And there you have it! A complete game with sprite rendering, text rendering, audio, game loop, events and state management.

## Release

Is your game ready to release?

Just follow [these few simple steps](https://flutter.io/android-release/) from the Flutter tutorial.

They are all pretty straightforward, as you can see in this final checkpoint, except for the Icons part, which might cause a bit of a headache. My recommendation is to make a big (512 or 1024 px) version of your icon, and use the [Make App Icon](https://makeappicon.com) website to generate a zip with everything you need (iOS and Android).

> Checkpoint: [2974f29](https://github.com/luanpotter/flame-example/commit/2974f29804d548c33fa9a736d1d3744414aaba0f)

## What Else?

Did you enjoy Flame? If you have any suggestions, bugs, questions, feature requests, or anything, please feel free to contact me!

Want to improve your game and learn more? How about adding a Server with Firebase and Google Sign In? How about adding ads? How about adding a Main Menu and multiple screens?

There's a lot to improve, of course -- this is just an example game. But it should have given a basic idea of the core concepts of game development with Flutter (with or without Flame).

Hope everyone enjoyed it!
