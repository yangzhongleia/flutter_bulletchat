import 'dart:async';
import 'package:flutter/material.dart';
//import 'BarrageItem2.dart';
import 'bulletchat_item.dart';

typedef BarrageItemBuilder = Widget Function(BuildContext context, int index);

///

///
class BulletChat extends StatefulWidget {
  GlobalKey<BulletChatState> globalKey;
  IndexedWidgetBuilder builder;
//  bool startsWhenBuilt;
  List<int> timeStampsInMill;
  double width;
  int maxLine;

  ///from 0 to 1
  double speedCoefficient;

  AvoidOption option;

  ///from 0 to 1
//  double width;
//  double height;
//  bool tryAvoidCollide;
  BulletChat.builder(
      {@required BarrageItemBuilder builder,
        @required List<int> timeStampsInMill,
        @required double width,
        @required int maxLine,
        @required GlobalKey<BulletChatState> globalKey,
        @required AvoidOption option,

        ///from 0 to 2,by default its 1,
        @required double speedCoefficient = 1}
//      double width,
//      double height
      )
      : assert(builder != null),
        assert(timeStampsInMill != null),
        assert(speedCoefficient != null),
        assert(speedCoefficient > 0&&speedCoefficient<=3),
        assert(globalKey != null),
        assert(width != null),
        assert(maxLine != null),

//        assert(barrageController != null),
        this.builder = builder,
        this.timeStampsInMill = timeStampsInMill,
        this.maxLine = maxLine,
        this.width = width,
        this.speedCoefficient = speedCoefficient,
        this.option = option,
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
  int _savageCount = 0;
  Map<int, int> _showTime = Map();
  Map<int, int> _finishTimeMap = Map();
  bool _savage = false;
  Widget _savageWidget;
  Timer _globalTimer;
  int _time;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _screenTime =
        ((widget.width / 300) * 3000 / widget.speedCoefficient).toInt();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      start(0);
    });
//    start(0);
  }

  @override
  Widget build(BuildContext context) {
    return _buildBody();
  }

  void start(int time) {
    _shouldProduce = true;
    _clickClock(time==0?time:time+1500);

    _produce(context, _savageWidget, false);
    _isShowing =true;


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
    if(_findIndex(t)==-1){
      _shouldProduce = false;
    }else{
      this._index = _findIndex(t);
      print("index${this._index}");
      _globalTimer = Timer.periodic(new Duration(milliseconds: 1), (t) {
        this._time++;
      });
    }


  }





  int _findIndex(int t){

    if(t==0){
      return 0;
    }




    if(t>widget.timeStampsInMill[widget.timeStampsInMill[widget.timeStampsInMill.length-1]]){
      return -1;
    }
    int index =0;

    for(int i=0;i<widget.timeStampsInMill.length;i++){

      if(widget.timeStampsInMill[i]<=t){
        continue;
      }else{
        index =i;
        break;
      }

    }

    return index;

  }






  Widget _buildBody() {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints boxConstraints) {

          var boxConstraint = boxConstraints;
          double height = boxConstraint.maxHeight;
          double width = boxConstraint.maxWidth;


          this._width = width;
          this._height = height;

          return


            Container(
              width: width,
              height: height,
              child:

              Container(

                  width: _shouldProduce?width:0,
                  height: height,
                  child:Stack(
                    children: _list,
                  )

              )
              ,


            );


        });
  }



  _produce(BuildContext context, Widget child, bool temp) {
    if (_shouldProduce) {
      _durationTime = widget.timeStampsInMill[_index];


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
        Widget childWidget = temp
            ? child
            : widget.builder(
            context, _index - _savageCount > 0 ? _index - _savageCount : 0);

        _list.add(BulletChatItem(
          child: childWidget,
          marginTop: this._height/widget.maxLine * _rowIndex[_index].toDouble(),
          globalKey: key,
          rowNum: _rowIndex[_index],
          callBack: setFinishTime,
          startTime: _time,
          screenTime: _screenTime,
          lastShowTime:
          _showTime[_rowIndex[_index]] == null ? 0 : _showTime[_rowIndex[_index]],
          lastFinishTime: _finishTimeMap[_rowIndex[_index]] == null
              ? 0
              : _finishTimeMap[_rowIndex[_index]],
          forceToAvoid: true,
          width: widget.width,
          showTimeCall: setLastShowTime,
          index: _index,
          removable: !temp,
          option: widget.option,
        ));

        setState(() {});
      });
    }
  }


  void setLastShowTime(int row, int startTime) {
    _showTime[row] = startTime;
  }




  void setFinishTime(int row, int startTime, int index) {
    _finishTimeMap[row] = startTime;
//    this.callBackIndex = index;

    if (index < widget.timeStampsInMill.length - 1) {
//            while(true){
//              if(callBackIndex==index){

      this._index++;
//                while(true){
//                  if(shouldcontinue){
      if (_savage) {
        print("temp");
        _savageCount++;
        int lastTime =
        index - 1 >= 0 ? widget.timeStampsInMill[this._index - 1] : 0;

        print("time$lastTime");
        widget.timeStampsInMill.insert(this._index, lastTime);
        _produce(context, _savageWidget, true);
        _savage = false;
      } else {
        _produce(context, _savageWidget, false);
      }
    }
  }


  void _clearData() {
    _list.removeWhere((element) => element.finished);
  }

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



  addSavageBarrage(
      {BuildContext context,
        Widget child,
        int durationInMill,
        EdgeInsets margin,
        bool center}) {
    //创建一个OverlayEntry对象
    OverlayEntry overlayEntry = new OverlayEntry(builder: (context) {
      //外层使用Positioned进行定位，控制在Overlay中的位置
      if (center) {
        return new Positioned(
//          top: MediaQuery.of(context).size.height * 0.7,
            top: 0,
            left: 0,
            child: new Material(
                color: Colors.transparent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: this._width,
                      height: this._height,
                      child: child,
                      alignment: Alignment.center,
                    )
                  ],
                )));
      } else {
        print("child");
        return new Positioned(
//          top: MediaQuery.of(context).size.height * 0.7,
            top: margin.top,
            left: margin.left,
            bottom: margin.bottom,
            right: margin.right,
            child: new Material(
                color: Colors.transparent,
                child: Container(
                  height: this._height,
                  child: child,
//                      alignment: Alignment.center,
                )));
      }
    });
    //往Overlay中插入插入OverlayEntry
    Overlay.of(context).insert(overlayEntry);
    //两秒后，移除Toast
    Future.delayed(Duration(milliseconds: durationInMill)).then((value) {
      overlayEntry.remove();
    });
  }

  addBarrage(Widget child) {
    _savageWidget = child;
    _savage = true;
  }
}

enum AvoidOption { AVOIDCOLLISION,  ALLOWCOLLISION }
