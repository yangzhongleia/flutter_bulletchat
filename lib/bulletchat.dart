import 'dart:async';
import 'package:flutter/material.dart';
import 'bulletchat_data.dart';
//import 'BarrageItem2.dart';
import 'bulletchat_item.dart';

typedef BulletItemBuilder = Widget Function(
    BuildContext context, BulletChatData data);
typedef SavageBulletItemBuilder = Widget Function(
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

  /// timesstamps of all the savagebulletchat item in millisecond

  ///the bulletchat viewport width
  double width;

  /// max lines to display
  int maxLine;

  ///it decides speed of the animation from , should bigger than 0 and not bigger than 3
  double speedCoefficient;

  AvoidOption option;

  List<BulletChatData> data;

  ///function to build savagebullet
  SavageBulletItemBuilder savageBulletItemBuilder;
  BulletChat.builder(
      {@required BulletItemBuilder builder,
//        @required List<int> timeStampsInMill,
      @required double width,
      @required int maxLine,
      @required GlobalKey<BulletChatState> globalKey,
      @required List<BulletChatData> data,
      AvoidOption option = AvoidOption.AVOIDCOLLISION,
      double speedCoefficient = 1,
      List<int> savageBulletTimeStampInMill,
      SavageBulletItemBuilder savageBulletItemBuilder}
//      double width,
//      double height
      )
      : assert(builder != null),
//        assert(timeStampsInMill != null),
        assert(speedCoefficient != null),
        assert(speedCoefficient > 0 && speedCoefficient <= 3),
        assert(globalKey != null),
        assert(width != null),
        assert(maxLine != null),

//        assert(barrageController != null),
        this.builder = builder,
//        this.timeStampsInMill = timeStampsInMill,
        this.maxLine = maxLine,
        this.width = width,
        this.speedCoefficient = speedCoefficient,
//        this.option = AvoidOption.AVOIDCOLLISION,
        this.savageBulletItemBuilder = savageBulletItemBuilder,
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
  List<BulletChatData> _savageData = List();

  int _savageIndex = 0;
  int _savageTempCount = 0;
  Widget _savageTempWidget;
  BulletChatData _savageBulletChatData;
  bool _savageTemp = false;

  BulletChatData _bulletChatData;
  BuildContext _context;

  bool savageFinished = false;
  bool normalFinished = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    initData();
    _screenTime =
        ((widget.width / 300) * 3000 / widget.speedCoefficient).toInt();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      start(0);
    });
//    start(0);
  }

  void initData() {
    for (int i = 0; i < widget.data.length; i++) {
      if (widget.data[i].bulletType == BulletType.NORMAL) {
        _normalData.add(widget.data[i]);
      } else {
        _savageData.add(widget.data[i]);
      }
    }
    print("normal${_normalData.length}");
    print("savage${_savageData.length}");
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
    if(widget.savageBulletItemBuilder!=null&&_savageData.length>0){
      _produceSavageBullet(context, _savageTempWidget);

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
      print("index${this._index}");
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
    return
      Material(
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints boxConstraints) {
              var boxConstraint = boxConstraints;
              double height = boxConstraint.maxHeight;
              double width = boxConstraint.maxWidth;

              this._width = width;
              this._height = height;

              return Container(
                width: width,
                height: height,
                child: Container(
                    width: _shouldProduce ? width : 0,
                    height: height,
                    child: Stack(
                      children: _list,
                    )),
              );
            }),

      )
      ;
  }

  _produce(BuildContext context, Widget child, bool temp) {
    if(_index==_normalData.length-1){
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
          width: widget.width,
          showTimeCall: setLastShowTime,
          index: _index,
          removable: !temp,
          option: AvoidOption.AVOIDCOLLISION,
        ));

        setState(() {});
      });
    }
  }

  _produceSavageBullet(
    BuildContext context,
    Widget child,
    /// if center in the widget
  ) {
    Widget child1;
    if (_savageTemp) {
      _savageTempCount++;
      _savageData.insert(_savageIndex, _savageBulletChatData);
      child1 = _savageTempWidget;
    }
     print("savageindex$_savageIndex");
    Future.delayed(
        Duration(milliseconds: _savageData[_savageIndex].timeFromStart - _time),
        () {
      _addSavageBullet(
          context: context,
          child: child1 == null
              ? widget.savageBulletItemBuilder(context, _savageData[_savageIndex])
              : child1,
          durationInMill: _savageData[_savageIndex].duration,
          margin: _savageData[_savageIndex].margin,
          center: _savageData[_savageIndex].center);
      _savageIndex++;
      _savageTemp = false;
      if(_savageIndex<_savageData.length){
        _produceSavageBullet(context, child);
      }else{
        savageFinished = true;
      }
    });



  }

  void setLastShowTime(int row, int startTime) {
    _showTime[row] = startTime;
  }

  /// it should be called when the viewport size changed but screen orientation not changed
  /// if the screen orientation changed , should not call this
  void onSizeChanged({double width,double height}){

    widget.width = width;
     this._height = height;
    _screenTime =
        ((widget.width / 300) * 3000 / widget.speedCoefficient).toInt();
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
          print("temp");
          _tempCount++;
          int lastTime =
              index1 - 1 >= 0 ? _normalData[this._index - 1].timeFromStart : 0;

          print("time$lastTime");
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

  _addSavageBullet(
      {BuildContext context,
      Widget child,
      int durationInMill,
      EdgeInsets margin,

      /// if center in the widget
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

  addBullet(Widget child, BulletChatData bulletChatData) {
    if(!normalFinished){

      _tempWidget = child;
      this._bulletChatData = bulletChatData;
      _temp = true;


    }else{

      _tempCount++;
      int lastTime =
      this._index - 1 >= 0 ? _normalData[this._index - 1].timeFromStart : 0;

      print("time$lastTime");
//        _normalData.insert(this._index, lastTime);
      this._bulletChatData.timeFromStart = lastTime;
      _normalData.insert(this._index, this._bulletChatData);
      _produce(context, _tempWidget, true);
      _temp = false;

    }

  }

  addSavageBullet(Widget child, BulletChatData bulletChatData) {
    if(widget.savageBulletItemBuilder!=null){
      _savageTempWidget = child;
      this._savageBulletChatData = bulletChatData;
      this._savageTemp = true;
    }

    if(widget.savageBulletItemBuilder==null||savageFinished){

      _addSavageBullet(context: _context,child: child,durationInMill: bulletChatData.duration,margin: bulletChatData.margin,center: bulletChatData.center);

    }


  }
}

enum AvoidOption { AVOIDCOLLISION, ALLOWCOLLISION }
