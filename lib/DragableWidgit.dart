import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class DraggableWidgetPage extends StatefulWidget {
  List<ChildProperty> childList;

  DraggableWidgetPage(this.childList);

  @override
  State<StatefulWidget> createState() {
    return _DraggableWidgetPageState(childList);
  }
}

class _DraggableWidgetPageState extends State<DraggableWidgetPage> {
  GlobalKey stackKey = new GlobalKey();
  Offset startPoint = new Offset(20, 40); // 按下时相对子widget的坐标
  Size startSize = new Size(150, 80); // 按下时子widget的大小
  List<ChildProperty> childList;

  _DraggableWidgetPageState(this.childList);

  Size _getStackSizes() {
    final RenderBox renderBoxRed = stackKey.currentContext.findRenderObject();
    return renderBoxRed.size;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Scaffold(
        resizeToAvoidBottomPadding: false,
        backgroundColor: Color.fromARGB(0, 0, 0, 0),
        body: Stack(
          key: stackKey,
          alignment: AlignmentDirectional.centerStart,
          children: _createChildren(),
        ),
      ),
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode()); // 收起键盘
        setState(() {
          for (int i = 0; i < childList.length; i++) {
            childList[i].isChosen = false;
          }
        });
      },
    );
  }

  List<Widget> _createChildren() {
    return new List<Widget>.generate(childList.length, (int index) {
      final controller = TextEditingController.fromValue(TextEditingValue(
        text: childList[index].text,
      ));
      return Positioned(
        left: childList[index].pos.dx,
        top: childList[index].pos.dy,
        child: GestureDetector(
          child: Container(
              width: childList[index].size.width,
              height: childList[index].size.height,
              color: childList[index].backgroundColor,
              child: Stack(
                children: <Widget>[
                  Offstage(
                    offstage: childList[index].isChosen,
                    child: AutoSizeText(
                      childList[index].text,
                      style: TextStyle(
                        fontSize: childList[index].fontSize,
                        color: childList[index].textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Offstage(
                    offstage: !childList[index].isChosen,
                    child: TextField(
                      controller: controller,
                      textAlign: TextAlign.center,
                      onChanged: (content) {
                        setState(() {
                          childList[index].text = content;
                        });
                      },
                      style: new TextStyle(
                        fontSize: childList[index].fontSize / 3,
                        color: childList[index].textColor,
                      ),
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(0),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              )),
                    ),
                  )
                ],
              )),
          onTap: () {
            setState(() {
              for (int i = 0; i < childList.length; i++) {
                if (i == index) {
                  childList[i].isChosen = true;
                } else {
                  childList[i].isChosen = false;
                }
              }
            });
          },
          onPanDown: (e) {
            startPoint = Offset(e.globalPosition.dx - childList[index].pos.dx,
                e.globalPosition.dy - childList[index].pos.dy);
            startSize = childList[index].size;
          },
          onPanUpdate: (e) {
            setState(() {
              if (startSize.width - startPoint.dx < 50 &&
                  startSize.height - startPoint.dy < 50) {
                childList[index].size = Size(
                    (startSize.width +
                            e.globalPosition.dx -
                            startPoint.dx -
                            childList[index].pos.dx)
                        .clamp(30.0, 300.0),
                    (startSize.height +
                            e.globalPosition.dy -
                            startPoint.dy -
                            childList[index].pos.dy)
                        .clamp(30.0, 200.0));
              } else {
                childList[index].pos = new Offset(
                    (e.globalPosition.dx - startPoint.dx).clamp(0.0,
                        _getStackSizes().width - childList[index].size.width),
                    (e.globalPosition.dy - startPoint.dy).clamp(
                        20.0,
                        _getStackSizes().height -
                            childList[index].size.height));
              }
            });
          },
        ),
      );
    });
  }
}

class ChildProperty {
  Offset pos;
  Size size;
  bool isChosen = false;
  String text = "点击输入文字";
  Color textColor = Colors.black;
  Color backgroundColor = Colors.white;
  double fontSize = 80;

  ChildProperty(this.pos, this.size);
}
