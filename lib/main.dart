import 'dart:io';
import 'dart:typed_data';

import 'package:cat_f/DragableWidgit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:toast/toast.dart';
import 'dart:convert';
import 'dart:ui' as ui;

import 'SlideColorPicker.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool chooseBackgroundColor = true;
  bool chooseTextColor = true;
  String url = "";
  static GlobalKey previewContainer = new GlobalKey();
  int picWidth;
  int picHeight;

  _MyHomePageState() {
    _init();
  }

  void _init() {
    getPhoto();
  }

  Future getPhoto() async {
    //创建一个HttpClient
    HttpClient httpClient = new HttpClient();
    //打开Http连接
    HttpClientRequest request = await httpClient
        .getUrl(Uri.parse("https://api.thecatapi.com/v1/images/search"));
    //等待连接服务器（会将请求信息发送给服务器）
    HttpClientResponse response = await request.close();
    //读取响应内容
    String _text = await response.transform(utf8.decoder).join();
    final map = json.decode(_text.substring(1, _text.length - 1));
    picWidth = map["width"];
    picHeight = map["height"];

    setState(() {
      url = map["url"];
    });
  }

  void addText() {
    setState(() {
      childList.add(ChildProperty(Offset(20, 40), Size(150, 40)));
    });
  }

  void changeBackgroundColor() {
    setState(() {
      chooseTextColor = !chooseTextColor;
      chooseBackgroundColor = true;
//      for (ChildProperty child in childList) {
//        if (child.isChosen) {
//          child.backgroundColor = backgroundColor;
//        }
//      }
    });
  }

  void changeTextColor() {
    setState(() {
      chooseBackgroundColor = !chooseBackgroundColor;
      chooseTextColor = true;
    });
  }

  void savePic() async {
    RenderRepaintBoundary boundary =
        previewContainer.currentContext.findRenderObject();
    ui.Image image = await boundary.toImage();
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData.buffer.asUint8List();
    print(pngBytes);
    File imgFile = await _getLocalFile();
    imgFile.writeAsBytes(pngBytes);
    print(imgFile.path);
    Toast.show("save pic toast", context,
        duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
  }

  Future _getLocalFile() async {
    // 获取应用目录
    Directory dir =
        new Directory((await getExternalStorageDirectory()).path + "/Friday");
    if (!await dir.exists()) {
      dir.createSync();
    }
    return new File('${dir.absolute.path}/screenshot_${DateTime.now()}.png');
  }

  List<ChildProperty> childList = new List();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      resizeToAvoidBottomPadding: false,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          alignment: AlignmentDirectional.centerStart,
          children: <Widget>[
            Padding(
              padding: new EdgeInsets.fromLTRB(0, 0, 0, 200),
              child: RepaintBoundary(
                key: previewContainer,
                child: Stack(
                  alignment: AlignmentDirectional.centerStart,
                  children: <Widget>[
                    Padding(
                      padding: new EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: Image.network(
                        url,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                    Padding(
                      padding: new EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: DraggableWidgetPage(childList),
                    )
                  ],
                ),
              ),
            ),
            Positioned(
                bottom: 50,
                child: Offstage(
                  offstage: chooseBackgroundColor,
                  child: SlideColorPicker(
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    onChanged: (color) {
                      setState(() {
//                        backgroundColor = color;
                        for (ChildProperty child in childList) {
                          if (child.isChosen) {
                            child.textColor = color;
                          }
                        }
                      });
                    },
                  ),
                )),
            Positioned(
                bottom: 50,
                child: Offstage(
                  offstage: chooseTextColor,
                  child: SlideColorPicker(
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    onChanged: (color) {
                      setState(() {
//                        textColor = color;
                        for (ChildProperty child in childList) {
                          if (child.isChosen) {
                            child.backgroundColor = color;
                          }
                        }
                      });
                    },
                  ),
                )),
            Positioned(
              bottom: 0,
              child: _BottomToolWidget(getPhoto, addText, changeBackgroundColor,
                  changeTextColor, savePic),
            ),
          ],
        ),
      ),
    );
  }
}

typedef VoidCallback = void Function();

class _BottomToolWidget extends StatefulWidget {
  final VoidCallback changePic;
  final VoidCallback addText;
  final VoidCallback changeBackgroundColor;
  final VoidCallback changeTextColor;
  final VoidCallback savePic;

  _BottomToolWidget(this.changePic, this.addText, this.changeBackgroundColor,
      this.changeTextColor, this.savePic);

  @override
  State<StatefulWidget> createState() => _BottomToolWidgetState(
      changePic, addText, changeBackgroundColor, changeTextColor, savePic);
}

class _BottomToolWidgetState extends State<_BottomToolWidget>
    with SingleTickerProviderStateMixin {
  final VoidCallback changePic;
  final VoidCallback addText;
  final VoidCallback changeBackgroundColor;
  final VoidCallback changeTextColor;
  final VoidCallback savePic;

  _BottomToolWidgetState(this.changePic, this.addText,
      this.changeBackgroundColor, this.changeTextColor, this.savePic);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.0,
      child: DefaultTabController(
          length: 1,
          child: Column(
            children: <Widget>[_tabView()],
          )),
    );
  }

  Widget _tabView() {
    return SizedBox(
        height: 50,
        width: MediaQuery.of(context).size.width,
        child: Column(children: <Widget>[
          Expanded(
            child: TabBarView(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    getTabViewItem(Icons.font_download, "背景色"),
                    getTabViewItem(Icons.title, "文字颜色"),
                    getTabViewItem(Icons.add_to_photos, "增加文本"),
                    getTabViewItem(Icons.search, "换个图"),
                    getTabViewItem(Icons.file_download, "保存图片"),
                  ],
                )
              ],
            ),
          )
        ]));
  }

  Widget getTabViewItem(IconData icon, String txt) {
    return GestureDetector(
      onTap: () => handleBottomClick(txt),
      child: Column(
        children: <Widget>[Icon(icon), Text(txt)],
      ),
    );
  }

  handleBottomClick(String text) {
    switch (text) {
      case "背景色":
        changeBackgroundColor();
        break;

      case "文字颜色":
        changeTextColor();
        break;

      case "增加文本":
        addText();
        break;

      case "换个图":
        changePic();
        break;

      case "保存图片":
        savePic();
        break;
    }
  }
}
