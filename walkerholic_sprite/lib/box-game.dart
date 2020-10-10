import 'dart:ui';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flame/spritesheet.dart';
import 'package:flutter/animation.dart';
import 'package:flame/position.dart';
import 'package:flame/components/component.dart';
import 'package:flame/flame.dart';

var player;

class MyGame extends Game {

  static final spriteSheet = SpriteSheet(
    imageName: 'Skeleton_Walk.png',
    textureWidth: 22,
    textureHeight: 33,
    columns: 13,
    rows: 1,
  );

  Position _position = Position(0, 220);
  Position _position2 = Position(20, 50);

  Position _size = Position(150, 150);
  Position _size2 = Position(150, 150);



  final animation = spriteSheet.createAnimation(0, stepTime: 0.05);


  @override
  void render(Canvas canvas) {
    animation.getSprite().renderPosition(canvas, _position, size: _size);
    animation.getSprite().renderPosition(canvas, _position2, size: _size2);

  }

  @override
  void update(double t) {
    animation.update(t);
    if(_position.x > 170){
      _position.x = 0;
    }
    else {
      _position.x++;
    }
    if(_position2.x > 170){
      _position2.x = 0;
    }
    else {
      _position2.x = _position2.x +3;
    }

  }
}
