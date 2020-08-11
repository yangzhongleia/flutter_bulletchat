import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


typedef BulletItemBuilder = Widget Function(
    BuildContext context, BulletChatData data);
typedef StaticBulletItemBuilder = Widget Function(
    BuildContext context, BulletChatData data);

///

///
class BulletChat extends StatefulWidget {
  GlobalKey<BulletChatState> globalKey;

  /// function to build all the widget
  BulletItemBuilder builder;

  ///
  ///
  /// timesstamps of all the bulletchat item in millisecond
//  List<int> timeStampsInMill;

  /// timesstamps of all the staticbulletchat item in millisecond

  ///the bulletchat viewport width
  double width;

  double height;

  /// max lines to display
  int maxLine;

  ///it decides speed of the animation from , should bigger than 0 and not bigger than 3
  double speedCoefficient;

  AvoidOption option;

  List<BulletChatData> data;

  ///function to build staticbullet
  StaticBulletItemBuilder staticBulletItemBuilder;
  BulletChat.builder(
      {@required BulletItemBuilder builder,
//        @required List<int> timeStampsInMill,
      @required double width,
      @required double height,
      @required int maxLine,
      @required GlobalKey<BulletChatState> globalKey,
      @required List<BulletChatData> data,
      AvoidOption option = AvoidOption.AVOIDCOLLISION,
      double speedCoefficient = 1,
      List<int> staticBulletTimeStampInMill,
      StaticBulletItemBuilder staticBulletItemBuilder}
//      double width,
//      double height
      )
      : assert(builder != null),
//        assert(timeStampsInMill != null),
        assert(speedCoefficient != null),
        assert(speedCoefficient > 0 && speedCoefficient <= 3),
        assert(globalKey != null),
        assert(width != null),
        assert(height != null),
        assert(maxLine != null),

//        assert(barrageController != null),
        this.builder = builder,
//        this.timeStampsInMill = timeStampsInMill,
        this.maxLine = maxLine,
        this.width = width,
        this.height = height,
        this.speedCoefficient = speedCoefficient,
//        this.option = AvoidOption.AVOIDCOLLISION,
        this.staticBulletItemBuilder = staticBulletItemBuilder,
        this.data = data,
        super(
          key: globalKey,
        );

//        this.width = width,
//        this.height = height;

  @override
  BulletChatState createState() => BulletChatState();
}

class BulletChatState extends State<BulletChat> {
  int _screenTime = 0;
  int _index = 0;
  int _durationTime = 0;
  bool _shouldProduce = true;
  bool _isShowing = true;
  List<BulletChatItem> _list = List();

  Map<int, int> _rowIndex = Map();
  double _width = 0;
  double _height = 0;
  int _tempCount = 0;
  Map<int, int> _showTime = Map();
  Map<int, int> _finishTimeMap = Map();
  bool _temp = false;
  Widget _tempWidget;
  Timer _globalTimer;
  int _time;

  List<BulletChatData> _normalData = List();
  List<BulletChatData> _staticData = List();

  int _staticIndex = 0;

  Widget _staticTempWidget;


  BulletChatData _bulletChatData;
  BuildContext _context;

  bool staticFinished = false;
  bool normalFinished = false;

  List<StaticWidget> _child = List();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    initData();
    _screenTime =
        ((this._width / 300) * 3000 / widget.speedCoefficient).toInt();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      start(0);
//      handle();
    });
//    start(0);
  }

  void initData() {
    for (int i = 0; i < widget.data.length; i++) {
      if (widget.data[i].bulletType == BulletType.NORMAL) {
        _normalData.add(widget.data[i]);
      } else {
        _staticData.add(widget.data[i]);
      }
    }

    this._width = widget.width;
    this._height = widget.height;
//    print("normal${_normalData.length}");
//    print("static${_staticData.length}");
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    return _buildBody();
  }

  /// if time is not 0, it will add 1500 millionseconds delayed to avoid collision from last time，
  /// for example, you call method stop(),and then immediately call start()
  void start(int time) {
    _shouldProduce = true;
    _clickClock(time == 0 ? time : time + 1500);

    _produce(context, _tempWidget, false);
    if (widget.staticBulletItemBuilder != null && _staticData.length > 0) {
      _produceStaticBullet(context, _staticTempWidget);
    }
    _isShowing = true;
  }

  void stop() {
    _shouldProduce = false;
    _isShowing = false;
    _globalTimer.cancel();
    _rowIndex.clear();
    _showTime.clear();
    _finishTimeMap.clear();

    setState(() {});
  }

  bool get isShowing => _isShowing;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  void _clickClock(int time) {
    this._time = time;
    final int t = time;
    if (_findIndex(t) == -1) {
      _shouldProduce = false;
    } else {
      this._index = _findIndex(t);
//      print("index${this._index}");
      _globalTimer = Timer.periodic(new Duration(milliseconds: 1), (t) {
        this._time++;
      });
    }
  }

  ///find index of the item should be built next
  int _findIndex(int t) {
    if (t == 0) {
      return 0;
    }

    if (t > _normalData[_normalData.length - 1].timeFromStart) {
      return -1;
    }
    int index1 = 0;

    for (int i = 0; i < _normalData.length; i++) {
      if (_normalData[i].timeFromStart <= t) {
        continue;
      } else {
        index1 = i;
        break;
      }
    }

    return index1;
  }

  Widget _buildBody() {
    return Scaffold(
        body:

//        LayoutBuilder(
//            builder: (BuildContext context, BoxConstraints boxConstraints) {
//              var boxConstraint = boxConstraints;
//              double height = boxConstraint.maxHeight;
//              double width = boxConstraint.maxWidth;
//
//              this._width = width;
//              this._height = height;

            Container(
      width: this._width,
      height: this._height,
      child: Container(
          width: _shouldProduce ? this._width : 0,
          height: this._height,
          child: Stack(
            children: [
              Stack(
                children: _list,
              ),
              Stack(
                children: _child,
              )
            ],
          )),
    )
//            }
//            ),

        );
  }


  _produce(BuildContext context, Widget child, bool temp) {
    if (_index == _normalData.length - 1) {
      normalFinished = true;
    }
    if (_shouldProduce) {
      _durationTime = _normalData[_index].timeFromStart;

      Future.delayed(Duration(milliseconds: (_durationTime - _time).abs()), () {
        int row;
        if (_rowIndex[_index] == null) {
//            print("build");
//            print("index$index");

          row = _availableRow(_index);
          _rowIndex[_index] = row;
        }

//          int finishTime  = finishTimeMap[row];
        GlobalKey<BulletChatItemState> key = GlobalKey();
        Widget childWidget =
            temp ? child : widget.builder(context, _normalData[_index]);

        _list.add(BulletChatItem(
          child: childWidget,
          marginTop:
              this._height / widget.maxLine * _rowIndex[_index].toDouble(),
          globalKey: key,
          rowNum: _rowIndex[_index],
          callBack: setFinishTime,
          startTime: _time,
          screenTime: _screenTime,
          lastShowTime: _showTime[_rowIndex[_index]] == null
              ? 0
              : _showTime[_rowIndex[_index]],
          lastFinishTime: _finishTimeMap[_rowIndex[_index]] == null
              ? 0
              : _finishTimeMap[_rowIndex[_index]],
          forceToAvoid: true,
          width: this._width,
          showTimeCall: setLastShowTime,
          index: _index,
          removable: !temp,
          option: AvoidOption.AVOIDCOLLISION,
        ));

        setState(() {});
      });
    }
  }

  _produceStaticBullet(
    BuildContext context,
    Widget child,

    /// if center in the widget
  ) {
//    Widget child1;
//    if (_staticTemp) {
//      _staticTempCount++;
//      _staticData.insert(_staticIndex, _staticBulletChatData);
//      child1 = _staticTempWidget;
//    }
//    print("staticindex$_staticIndex");

    if (_shouldProduce) {
      Future.delayed(
          Duration(
              milliseconds:
                  (_staticData[_staticIndex].timeFromStart - _time).abs()), () {
        _addStaticBullet(
            context: context,
//          child: child1 == null
//              ? widget.staticBulletItemBuilder(
//                  context, _staticData[_staticIndex])
//              : child1,
            child: widget.staticBulletItemBuilder(
                context, _staticData[_staticIndex]),
            durationInMill: _staticData[_staticIndex].duration,
            margin: _staticData[_staticIndex].margin,
            center: _staticData[_staticIndex].center,
            index: _staticIndex);
        _staticIndex++;

        if (_staticIndex < _staticData.length) {
          _produceStaticBullet(context, child);
        } else {
          staticFinished = true;
        }
      });
    }
  }

  void setLastShowTime(int row, int startTime) {
    _showTime[row] = startTime;
  }

  /// it should be called when the viewport size changed but screen orientation not changed
  /// if the screen orientation changed , should not call this
  void onSizeChanged({double width, double height}) {
    this._width = width;
    this._height = height;
    _screenTime =
        ((this._width / 300) * 3000 / widget.speedCoefficient).toInt();
  }

  void setFinishTime(int row, int startTime, int index1) {
    _finishTimeMap[row] = startTime;
//    this.callBackIndex = index;

    if (index1 < _normalData.length - 1) {
//            while(true){
//              if(callBackIndex==index){

      this._index++;
//                while(true){
//                  if(shouldcontinue){
      if (_temp) {
        if (this._bulletChatData.bulletType == BulletType.NORMAL) {
//          print("temp");
          _tempCount++;
          int lastTime =
              index1 - 1 >= 0 ? _normalData[this._index - 1].timeFromStart : 0;

//          print("time$lastTime");
//        _normalData.insert(this._index, lastTime);
          this._bulletChatData.timeFromStart = lastTime;
          _normalData.insert(this._index, this._bulletChatData);
          _produce(context, _tempWidget, true);
          _temp = false;
        } else {}
      } else {
        _produce(context, _tempWidget, false);
      }
    }
  }

  void _clearData() {
    _list.removeWhere((element) => element.finished);
  }

  /// find which row is available
  int _availableRow(int index) {
//    print("index${index}");
    int temp = 100000000;
    int row = 0;
    for (int i = 0; i < widget.maxLine; i++) {
//      print("finishmap1${finishTimeMap[0]}");
      if (_finishTimeMap[i] == null) {
        row = i;
        break;
      } else if (_finishTimeMap[i] < temp) {
        temp = _finishTimeMap[i];
        row = i;
      }
    }
    return row;
  }

  /// add an item without animation from right to left ,
  /// [durationInMill] ,how long should the item be showing

  _addStaticBullet(
      {BuildContext context,
      Widget child,
      int durationInMill,
      EdgeInsets margin,

      /// if center in the widget
      bool center,
      int index}) {
    //创建一个OverlayEntry对象
//    OverlayEntry overlayEntry = new OverlayEntry(builder: (context) {
//      //外层使用Positioned进行定位，控制在Overlay中的位置
//      if (center) {
//        return new Positioned(
////          top: MediaQuery.of(context).size.height * 0.7,
//            top: 0,
//            left: 100,
//            child: new Material(
//                color: Colors.transparent,
//                child: Column(
//                  crossAxisAlignment: CrossAxisAlignment.center,
//                  children: <Widget>[
//                    Container(
//                      width: this._width,
//                      height: this._height,
//                      child: child,
//                      alignment: Alignment.center,
//                    )
//                  ],
//                )));
//      } else {
//        print("child");
//        return new Positioned(
////          top: MediaQuery.of(context).size.height * 0.7,
//            top: margin.top,
//            left: margin.left,
//            bottom: margin.bottom,
//            right: margin.right,
//            child: new Material(
//                color: Colors.transparent,
//                child: Container(
//                  height: this._height,
//                  child: child,
////                      alignment: Alignment.center,
//                )));
//      }
//    });
//    //往Overlay中插入插入OverlayEntry
//    Overlay.of(context).insert(overlayEntry);
//    //两秒后，移除Toast
//    Future.delayed(Duration(milliseconds: durationInMill)).then((value) {
//      overlayEntry.remove();
//    });

    _child.add(StaticWidget(
        durationInMill, child, center, margin, remove, _time, index));
    setState(() {});
  }

  addBullet(Widget child) {
    if (!normalFinished) {
      _tempWidget = child;
      int lastTime =
          this._index - 1 >= 0 ? _normalData[this._index - 1].timeFromStart : 0;
//      this._bulletChatData = bulletChatData;
      this._bulletChatData = BulletChatData("", BulletType.NORMAL, lastTime);
      _normalData.insert(this._index, this._bulletChatData);
      _temp = true;
    } else {
      _tempCount++;
      int lastTime =
          this._index - 1 >= 0 ? _normalData[this._index - 1].timeFromStart : 0;

//      print("time$lastTime");
//        _normalData.insert(this._index, lastTime);
      this._bulletChatData.timeFromStart = lastTime;
      _normalData.insert(this._index, this._bulletChatData);
      _produce(context, _tempWidget, true);
      _temp = false;
    }
  }


  ///clear data
  void remove(int index) {
//    _child.removeAt(0);

//  _child.removeWhere((element) => _child.indexOf(element)==0);
    _child.removeWhere((element) {
//      if(element.finished){


//        if(element.finished){
//          print("finishe${element.finished}${_child.indexOf(element)}");
//        }
        if(!element.finished){
          print("unfinishe${element.finished}${element.index}");
        }

//      }
      if(_time-element.startTime>=element.time){
        return true;
      }
      return element.finished;


    });

    setState(() {});
  }

  addStaticBullet(
      {Widget child, int duration, EdgeInsets margin, @required bool center}) {
    BulletChatData bulletChatData = BulletChatData("", BulletType.STATIC, _time,
        duration: duration,
        margin: margin == null ? EdgeInsets.only(left: 0) : margin,
        center: center);


    _addStaticBullet(
        context: _context,
        child: child,
        durationInMill: bulletChatData.duration,
        margin: bulletChatData.margin,
        center: bulletChatData.center,
        index: _staticIndex);

//    }


  }
}

enum AvoidOption { AVOIDCOLLISION, ALLOWCOLLISION }

class StaticWidget extends StatefulWidget {
  int index;
  int time;
  Widget child;
  bool center;
  EdgeInsets margin;
  Function function;
  bool finished = false;
  int startTime;
  StaticWidget(this.time, this.child, this.center, this.margin, this.function,
      this.startTime, this.index);

  @override
  _StaticWidgetState createState() => _StaticWidgetState();
}

class _StaticWidgetState extends State<StaticWidget> {
  double opacity =1;
  @override
  void initState() {

//    print("index>${widget.index}");
//    print("time>${widget.time}");
//    print("starttime>${widget.startTime}");



//    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {

      Timer(Duration(milliseconds: widget.time), (){
        widget.finished= true;
//        opacity =0;
//        setState(() {
//
//        });

        print("index${widget.index}");
        widget.function(widget.index);

      });

//      Future.delayed(Duration(milliseconds: widget.time)).then((value) {
//        widget.finished= true;
////        opacity =0;
////        setState(() {
////
////        });
//
//        print("index${widget.index}");
//        widget.function(widget.index);
//
//      });
//    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.center == null) {
      return
           Positioned(
            left: widget.margin.left,
            top: widget.margin.top,
            right: widget.margin.right,
            bottom: widget.margin.bottom,
            child: widget.child)
        ;
    }
    if (widget.center) {
      return LayoutBuilder(builder: (context, box) {
        double width = box.maxWidth;
        double height = box.maxHeight;
        return Container(
          color: Colors.transparent,
          width: width,
          height: height,
          alignment: Alignment.center,
          child: widget.child,
        );
      })

       ;
    } else {
      return   Positioned(
          left: widget.margin.left,
          top: widget.margin.top,
          right: widget.margin.right,
          bottom: widget.margin.bottom,
          child: widget.child)
      ;
    }
  }
}


class BulletChatData{

  BulletType bulletType;
  ///its essential
  int timeFromStart;
  ///if bulletType is BulletType.Static,its essential
  int duration;
  //if bulletType is BulletType.Static,and center is false ,its essential
  EdgeInsets margin;
  //if bulletType is BulletType.Static,its essential
  /// if center in the widget
  bool center;

  ///the content
  Object content;
  BulletChatData(this.content,this.bulletType,this.timeFromStart,{this.duration,this.margin,this.center});

}

enum BulletType{

  NORMAL,
  STATIC
}

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
//    print("》》》${widget.index} ${extraTime}");
//    print("》》》${widget.index} ${extra}");
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

//        print("<1/2");
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
//    print("durationtime${firstDuration}");
    durationTime = time();
    if (count == 0 && shouldReder) {

      widget.showTimeCall(widget.rowNum, showTime());
      widget.callBack(widget.rowNum, widget.startTime + firstDuration, widget.index);

//      print("callBack${widget.startTime}");

    }

    if (shouldReder) setState(() {});
  }
}
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
