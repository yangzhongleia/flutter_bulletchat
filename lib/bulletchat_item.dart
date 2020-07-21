import 'package:flutter/material.dart';
import 'bulletchat_item_child.dart';
import 'bulletchat.dart';
class BulletChatItem extends StatefulWidget {
  bool finished = false;
  Widget child;
  int rowNum;
  GlobalKey<BulletChatItemState> globalKey;
  double marginTop;
  Function callBack;
  int startTime;
  int lastFinishTime;
  int lastShowTime;
  int screenTime;
  double width;
  bool forceToAvoid;
  Function showTimeCall;
  int index;
  bool removable;
  AvoidOption option;
  BulletChatItem(
      {this.child,
        this.marginTop,
        this.globalKey,
        this.rowNum,
        this.callBack,
        this.startTime,
        this.lastFinishTime,
        this.screenTime,
        this.forceToAvoid,
        this.width,
        this.lastShowTime,
        this.showTimeCall,
        this.index,
        this.removable,
        this.option
      })
      : super(key: globalKey);
  @override
  BulletChatItemState createState() => BulletChatItemState();
}

class BulletChatItemState extends State<BulletChatItem>
    with TickerProviderStateMixin {
//  Animation<double> animation;
  Animation<Offset> animation;

  ///360三秒为基准
  ///
  ///
  double width;
  AnimationController controller;
//
  Animation<EdgeInsets> movement;

  int startTime;
//  AnimationController xAnimationController;
  AnimateChild animateChild;
//  GlobalKey<AnimateChildState> globalKey;

  Duration duration;

  bool visible = true;
  @override
  initState() {
    super.initState();


//    globalKey = GlobalKey();
    animateChild = AnimateChild(getWidth, widget.child);

    delayTime = 0;
    firstDuration =0;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
  }

  @override
  void dispose() {
//    controller.dispose();
    // TODO: implement dispose


    super.dispose();
//    print("dispose ${widget.index}");
  }

  bool anima = false;
  int count = 0;
  bool shouldReder = true;
  @override
  Widget build(BuildContext context) {
    return body2(context);
  }

  Widget body2(BuildContext context) {
    if (width == null) {
      return Positioned(
        child: animateChild,
        left: 15000,
        top: widget.marginTop,
      );
    } else {
      if (!anima) {
        count++;
        if (widget.startTime != null) {}
        controller = AnimationController(
            duration: Duration(milliseconds: durationTime), vsync: this);
        controller.addStatusListener((status) {
          if (status == AnimationStatus.completed) {
//         dispose();

//          widget.finished = true;
            if (mounted) dispose();
          }
        });
        movement = EdgeInsetsTween(
          begin: EdgeInsets.only(
            top: widget.marginTop,
            left: MediaQuery.of(context).size.width,
          ),
          end: EdgeInsets.only(top: widget.marginTop, left: width),
        ).animate(controller)
          ..addListener(() {
            setState(() {});
          });
        if (delayTime > 0) {
          Future.delayed(Duration(milliseconds: delayTime), () {
            controller.forward();
          });
        } else {
          controller.forward();
        }
      }

      anima = true;

//      print("showtime${showTime()}");
      return Visibility(
          visible: true,
          child: Positioned(
            child: animateChild,
            left: movement.value.left,
            top: widget.marginTop,
          ));
    }
  }


  int durationTime = 0;
  int rstartTime = 0;
  int firstDuration = 0;
  int time() {
    rstartTime = widget.startTime;
    double extra = (-width ) / widget.width;
    int extraTime = (widget.screenTime * extra).toInt();
    if (widget.index == 0) {
//      Fluttertoast.showToast(msg: null)
    }
    print("》》》${widget.index} ${extraTime}");
    print("》》》${widget.index} ${extra}");
//    print("extratime>>>${extraTime}");
    duration = Duration(milliseconds: widget.screenTime + extraTime);
//    print("comparetime>>>>${compareTime()}");
    return widget.screenTime + extraTime - compareTime();
  }

  int delayTime = 0;
  int compareTime() {
    if (arriveLeftTime1() < widget.lastFinishTime) {
      int t = widget.lastFinishTime - arriveLeftTime1();
//      print("arriveleft${arriveLeftTime()}");
      if (t < firstDuration / 2) {
//        return t;
//        return t;

        print("<1/2");
//        firstDuration = firstDuration-t;
//        visible = true;
//        shouldReder = true;

        if (widget.option==AvoidOption.AVOIDCOLLISION) {

//          print("showtime${showTime()}");
          if(mounted){

            if (widget.removable) {

              visible = false;
              widget.callBack(widget.rowNum, widget.lastFinishTime, widget.index);
              widget.showTimeCall(widget.rowNum, widget.lastShowTime);
              shouldReder = false;

              dispose();
//            visible = true;
//            shouldReder = true;
//            return t;
            }else {
              return   0;
            }

          }

        }else{
          visible = true;
          shouldReder = true;
          return 0;
        }
      } else {
        if (widget.option==AvoidOption.AVOIDCOLLISION) {

//          print("showtime${showTime()}");
          if(mounted){
            if(widget.removable){
              visible = false;
              widget.callBack(widget.rowNum, widget.lastFinishTime, widget.index);
              widget.showTimeCall(widget.rowNum, widget.lastShowTime);

              shouldReder = false;
              dispose();
            }else{
              return  0;
            }
          }

        }else{
          return 0;
        }

//        dispose();
//        delayTime = t-(widget.screenTime/2).toInt();
//        rstartTime = rstartTime-delayTime;
//        return (widget.screenTime/2).toInt();

        return 0;
      }
      return 0;
    }else{
      return 0;
    }
//     if (widget.lastShowTime > widget.startTime) {
//      visible = false;
//
//      widget.callBack(widget.rowNum, widget.lastFinishTime, widget.index);
//      widget.showTimeCall(widget.rowNum, widget.lastShowTime);
////      print("showtime${showTime()}");
//      shouldReder = false;
//      if (mounted)
//        {
//          if(widget.removable){
//            dispose();
//          }else{
//
//          }
//
//          return 0;
//        }
//    } else {
//      return 0;
//    }
  }

  int compareTime1() {
    if (arriveLeftTime1() < widget.lastFinishTime) {
      int t = widget.lastFinishTime - arriveLeftTime1();
//      print("arriveleft${arriveLeftTime()}");
      if (t < firstDuration / 2) {
//        return t;
//        return t;
        if (widget.option==AvoidOption.AVOIDCOLLISION) {
          visible = false;
          widget.callBack(widget.rowNum, widget.lastFinishTime, widget.index);
          widget.showTimeCall(widget.rowNum, widget.lastShowTime);
          shouldReder = false;
//          print("showtime${showTime()}");
          if(mounted){

            if (widget.removable) {
              dispose();
            }else {

            }

          }

        }
      } else {
        if (widget.option==AvoidOption.AVOIDCOLLISION) {
          visible = false;
          widget.callBack(widget.rowNum, widget.lastFinishTime, widget.index);
          widget.showTimeCall(widget.rowNum, widget.lastShowTime);

          shouldReder = false;
//          print("showtime${showTime()}");
          if(mounted){
            if(widget.removable){
              dispose();
            }else{

            }
          }

        }

//        dispose();
//        delayTime = t-(widget.screenTime/2).toInt();
//        rstartTime = rstartTime-delayTime;
//        return (widget.screenTime/2).toInt();

        return 0;
      }
      return 0;
    }
    if (widget.lastShowTime > widget.startTime) {
      visible = false;

      widget.callBack(widget.rowNum, widget.lastFinishTime, widget.index);
      widget.showTimeCall(widget.rowNum, widget.lastShowTime);
//      print("showtime${showTime()}");
      shouldReder = false;
      if (mounted)
      {
        if(widget.removable){
          dispose();
        }else{

        }

        return 0;
      }
    } else {
      return 0;
    }
  }
  int widthToDuration(){
    return widget.screenTime+(((-width)/widget.width)*widget.screenTime).toInt();
  }



  int showTime() {
    return widget.startTime +
        (((-width) / widget.width) * widget.screenTime).toInt();
  }

  int arriveLeftTime() {

    return (widget.startTime +
        widget.screenTime +
        ((-width) / widget.width) * widget.screenTime)
        .toInt();
  }
  int arriveLeftTime1() {

    return widget.startTime+widget.screenTime;
  }

  getWidth(var width) {
    this.width = -width;
    firstDuration = widthToDuration();
    print("durationtime${firstDuration}");
    durationTime = time();
    if (count == 0 && shouldReder) {

      widget.showTimeCall(widget.rowNum, showTime());
      widget.callBack(widget.rowNum, widget.startTime + firstDuration, widget.index);

//      print("callBack${widget.startTime}");

    }

    if (shouldReder) setState(() {});
  }
}