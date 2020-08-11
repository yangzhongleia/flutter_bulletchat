import 'package:flutter/material.dart';
class BulletChatData{

  BulletType bulletType;
  ///its essential
  int timeFromStart;
  ///if bulletType is BulletType.SAVAGE,its essential
  int duration;
  //if bulletType is BulletType.SAVAGE,and center is false ,its essential
  EdgeInsets margin;
  //if bulletType is BulletType.SAVAGE,its essential
  /// if center in the widget
  bool center;

  ///the content
  Object content;
  BulletChatData(this.content,this.bulletType,this.timeFromStart,{this.duration,this.margin,this.center});

}

enum BulletType{

  NORMAL,
  SAVAGE
}