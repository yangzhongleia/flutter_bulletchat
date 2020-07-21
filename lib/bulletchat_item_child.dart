import 'package:flutter/material.dart';
class AnimateChild extends StatefulWidget {
  Function function;

  Widget child;

  AnimateChild(this.function,this.child);
  @override
  AnimateChildState createState() => AnimateChildState();
}

class AnimateChildState extends State<AnimateChild> {
//  GlobalKey _key = GlobalKey();

  GlobalKey<AnimateChildState> globalKey = GlobalKey();

  _getRenderBox(_) {
//    print("renderer");
    //获取`RenderBox`对象
    RenderBox renderBox =  globalKey.currentContext.findRenderObject();
    widget.function(renderBox.size.width);
  }

  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addPostFrameCallback(_getRenderBox);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key:  globalKey,
//      child: Text("11"),
      child: widget.child,
    );
  }

  sendWidth(){
    RenderBox renderBox = globalKey.currentContext.findRenderObject();
    widget.function(renderBox.size.width);
  }
}