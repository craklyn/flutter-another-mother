import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';

import 'package:another_brother/label_info.dart';
import 'package:another_brother/printer_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final controller = PageController(initialPage: 1);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Another Brother Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: PageView(children: [
//        BleRjPrintHappyMothersDay(title: 'RJ-4250WB BLE Sample'),
        QlBluetoothPrintHappyMothersDay(
            title: 'QL-1110NWB Bluetooth Happy Mother\'s Day!'),
        /*
        BleRjPrintPage(title: 'RJ-4250WB BLE Sample'),
        QlBluetoothPrintPage(title: 'QL-1110NWB Bluetooth Sample'),
        WifiPrintPage(title: 'PJ-773 WiFi Sample'),
        WifiPrinterListPage(title: "Sample WiFi List")
        */
      ]),
    );
  }
}

class WifiPrintPage extends StatefulWidget {
  WifiPrintPage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _WifiPrintPageState createState() => _WifiPrintPageState();
}

class _WifiPrintPageState extends State<WifiPrintPage> {
  bool _error = false;

  void print(BuildContext context) async {
    var printer = new Printer();
    var printInfo = PrinterInfo();
    printInfo.printerModel = Model.PJ_773;
    printInfo.printMode = PrintMode.FIT_TO_PAGE;
    printInfo.isAutoCut = true;
    printInfo.port = Port.NET;
    // Set the label type.
    printInfo.paperSize = PaperSize.A4;

    // Set the printer info so we can use the SDK to get the printers.
    await printer.setPrinterInfo(printInfo);

    // Get a list of printers with my model available in the network.
    List<NetPrinter> printers =
        await printer.getNetPrinters([Model.PJ_773.getName()]);

    if (printers.isEmpty) {
      // Show a message if no printers are found.
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("No printers found on your network."),
        ),
      ));

      return;
    }
    // Get the IP Address from the first printer found.
    printInfo.ipAddress = printers.single.ipAddress;

    printer.setPrinterInfo(printInfo);
    printer.printImage(await loadImage('assets/brother_hack.png'));
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Don't forget to grant permissions to your app in Settings.",
                textAlign: TextAlign.center,
              ),
            ),
            Image(image: AssetImage('assets/brother_hack.png'))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => print(context),
        tooltip: 'Print',
        child: Icon(Icons.print),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<ui.Image> loadImage(String assetPath) async {
    final ByteData img = await rootBundle.load(assetPath);
    final Completer<ui.Image> completer = new Completer();
    ui.decodeImageFromList(new Uint8List.view(img.buffer), (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }
}

class BleRjPrintHappyMothersDay extends StatefulWidget {
  BleRjPrintHappyMothersDay({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _BleRjPrintHappyMothersDayState createState() =>
      _BleRjPrintHappyMothersDayState();
}

class _BleRjPrintHappyMothersDayState extends State<BleRjPrintHappyMothersDay> {
  bool _error = false;
  var _belated = "";
  var _mdAddress = "";
  var _mdDate = "Mother's day";
  var _assetImage = 'assets/blank.png';

  void print(BuildContext context) async {
    var printer = new Printer();
    var printInfo = PrinterInfo();
    printInfo.printerModel = Model.RJ_4250WB;
    printInfo.printMode = PrintMode.FIT_TO_PAGE;
    printInfo.isAutoCut = true;
    printInfo.port = Port.BLE;
    // Set the label type.
    double width = 102.0;
    double rightMargin = 0.0;
    double leftMargin = 0.0;
    double topMargin = 0.0;
    CustomPaperInfo customPaperInfo = CustomPaperInfo.newCustomRollPaper(
        printInfo.printerModel,
        Unit.Mm,
        width,
        rightMargin,
        leftMargin,
        topMargin);
    printInfo.customPaperInfo = customPaperInfo;

    // Set the printer info so we can use the SDK to get the printers.
    await printer.setPrinterInfo(printInfo);

    // Get a list of printers with my model available in the network.
    List<BLEPrinter> printers = await printer.getBLEPrinters(3000);

    if (printers.isEmpty) {
      // Show a message if no printers are found.
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("No printers found on your network."),
        ),
      ));

      return;
    }
    // Get the BT name from the first printer found.
    printInfo.setLocalName(printers.single.localName);

    printer.setPrinterInfo(printInfo);
    printer.printImage(await loadImage('assets/brother_hack.png'));
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "How will you\naddress your Mother?",
                  textAlign: TextAlign.right,
                ),
              ),
              SizedBox(
                width: 125.0,
                child: ElevatedButton(
                  child: Text('Randomize'),
                  onPressed: () {
                    setState(() {
                      var phrases = [
                        "Dearest mother",
                        "Yo! Mama",
                        "Dear Grandma",
                        "дорогая мама",
                        "Dear BrotherMother",
                      ];
                      var rng = new Random();
                      _mdAddress = phrases[rng.nextInt(phrases.length)];
                    });
                  },
                ),
              ),
              Padding(padding: const EdgeInsets.all(8.0)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "What year are\nyou celebrating?",
                  textAlign: TextAlign.right,
                ),
              ),
              SizedBox(
                width: 125.0,
                child: TextFormField(
                    maxLength: 4,
                    initialValue: "2021",
                    decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Enter the year'),
                    onChanged: (x) {
                      setState(() {
                        try {
                          var year = int.parse(x);
                          if (year >= 2000 && year <= 2050) {
                            int day = 1;

                            do {
                              var dayDatetime = DateTime(year, 5, day);
                              if (dayDatetime.weekday == DateTime.sunday) break;
                              day += 1;
                            } while (true);

                            _mdDate = "May " + (day + 7).toString() + ", " + x;
                            _belated = (year < 2021) ? " belated" : "";
                          }
                        } on FormatException {}
                      });
                    }),
              ),
              Padding(padding: const EdgeInsets.all(8.0)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "What design do\nyou want?",
                  textAlign: TextAlign.right,
                ),
              ),
              SizedBox(
                width: 125.0,
                child: ElevatedButton(
                  child: Text('Randomize'),
                  onPressed: () {
                    setState(() {
                      var images = [
                        "blank.png",
                        "brother_hack.png",
                        "flower.png",
                        "flower2.png",
                        "dolphin.png",
                        "mother_lover.png"
                      ];

                      var rng = new Random();
                      _assetImage =
                          "assets/" + images[rng.nextInt(images.length)];
                    });
                  },
                ),
              ),
              Padding(padding: const EdgeInsets.all(8.0)),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              //"Do not forget to grant permissions to your app in Settings.",
              "\n",
              textAlign: TextAlign.center,
            ),
          ),
          new Container(
            margin: const EdgeInsets.all(15.0),
            padding: const EdgeInsets.all(3.0),
            decoration:
                BoxDecoration(border: Border.all(color: Colors.blueAccent)),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image(width: 50.0, image: AssetImage(_assetImage)),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "$_mdAddress,\n" +
                          "Happy$_belated mother's day!\n" +
                          (_belated == " belated"
                              ? ""
                              : "Do not open until $_mdDate"),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Image(width: 50.0, image: AssetImage(_assetImage))
                ]),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => print(context),
        tooltip: 'Print',
        child: Icon(Icons.print),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<ui.Image> loadImage(String assetPath) async {
    final ByteData img = await rootBundle.load(assetPath);
    final Completer<ui.Image> completer = new Completer();
    ui.decodeImageFromList(new Uint8List.view(img.buffer), (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }
}

class BleRjPrintPage extends StatefulWidget {
  BleRjPrintPage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _BleRjPrintPageState createState() => _BleRjPrintPageState();
}

class _BleRjPrintPageState extends State<BleRjPrintPage> {
  bool _error = false;

  void print(BuildContext context) async {
    var printer = new Printer();
    var printInfo = PrinterInfo();
    printInfo.printerModel = Model.RJ_4250WB;
    printInfo.printMode = PrintMode.FIT_TO_PAGE;
    printInfo.isAutoCut = true;
    printInfo.port = Port.BLE;
    // Set the label type.
    double width = 102.0;
    double rightMargin = 0.0;
    double leftMargin = 0.0;
    double topMargin = 0.0;
    CustomPaperInfo customPaperInfo = CustomPaperInfo.newCustomRollPaper(
        printInfo.printerModel,
        Unit.Mm,
        width,
        rightMargin,
        leftMargin,
        topMargin);
    printInfo.customPaperInfo = customPaperInfo;

    // Set the printer info so we can use the SDK to get the printers.
    await printer.setPrinterInfo(printInfo);

    // Get a list of printers with my model available in the network.
    List<BLEPrinter> printers = await printer.getBLEPrinters(3000);

    if (printers.isEmpty) {
      // Show a message if no printers are found.
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("No printers found on your network."),
        ),
      ));

      return;
    }
    // Get the BT name from the first printer found.
    printInfo.setLocalName(printers.single.localName);

    printer.setPrinterInfo(printInfo);
    printer.printImage(await loadImage('assets/brother_hack.png'));
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Don't forget to grant permissions to your app in Settings.",
                textAlign: TextAlign.center,
              ),
            ),
            Image(image: AssetImage('assets/brother_hack.png'))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => print(context),
        tooltip: 'Print',
        child: Icon(Icons.print),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<ui.Image> loadImage(String assetPath) async {
    final ByteData img = await rootBundle.load(assetPath);
    final Completer<ui.Image> completer = new Completer();
    ui.decodeImageFromList(new Uint8List.view(img.buffer), (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }
}

class QlBluetoothPrintPage extends StatefulWidget {
  QlBluetoothPrintPage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _QlBluetoothPrintPageState createState() => _QlBluetoothPrintPageState();
}

class _QlBluetoothPrintPageState extends State<QlBluetoothPrintPage> {
  bool _error = false;

  void print(BuildContext context) async {
    var printer = new Printer();
    var printInfo = PrinterInfo();
    printInfo.printerModel = Model.QL_1110NWB;
    printInfo.printMode = PrintMode.FIT_TO_PAGE;
    printInfo.isAutoCut = true;
    printInfo.port = Port.BLUETOOTH;
    // Set the label type.
    printInfo.labelNameIndex = QL1100.ordinalFromID(QL1100.W103.getId());

    // Set the printer info so we can use the SDK to get the printers.
    await printer.setPrinterInfo(printInfo);

    // Get a list of printers with my model available in the network.
    List<BluetoothPrinter> printers =
        await printer.getBluetoothPrinters([Model.QL_1110NWB.getName()]);

    if (printers.isEmpty) {
      // Show a message if no printers are found.
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("No paired printers found on your device."),
        ),
      ));

      return;
    }
    // Get the IP Address from the first printer found.
    printInfo.macAddress = printers.single.macAddress;

    printer.setPrinterInfo(printInfo);
    printer.printImage(await loadImage('assets/brother_hack.png'));
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Don't forget to grant permissions to your app in Settings.",
                textAlign: TextAlign.center,
              ),
            ),
            Image(image: AssetImage('assets/brother_hack.png'))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => print(context),
        tooltip: 'Print',
        child: Icon(Icons.print),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<ui.Image> loadImage(String assetPath) async {
    final ByteData img = await rootBundle.load(assetPath);
    final Completer<ui.Image> completer = new Completer();
    ui.decodeImageFromList(new Uint8List.view(img.buffer), (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }
}

class WifiPrinterListPage extends StatefulWidget {
  WifiPrinterListPage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _WifiPrinterListPageState createState() => _WifiPrinterListPageState();
}

class _WifiPrinterListPageState extends State<WifiPrinterListPage> {
  Future<List<NetPrinter>> getMyNetworkPrinters() async {
    Printer printer = new Printer();
    PrinterInfo printInfo = new PrinterInfo();

    await printer.setPrinterInfo(printInfo);
    return printer
        .getNetPrinters([Model.QL_1110NWB.getName(), Model.PJ_773.getName()]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: FutureBuilder(
        future: getMyNetworkPrinters(),
        builder: (buildContext, snapShot) {
          if (snapShot.connectionState == ConnectionState.waiting) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Looking for printers."),
            );
          }

          if (snapShot.hasData) {
            // TODO Return a list
            List<NetPrinter> foundPrinters = snapShot.data;

            if (foundPrinters.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("No printers found."),
              );
            }

            return ListView.builder(
                itemCount: foundPrinters.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text("Printer: ${foundPrinters[index].modelName}"),
                      subtitle: Text("IP: ${foundPrinters[index].ipAddress}"),
                      onTap: () {
                        // TODO Do anything you want! Maybe print?
                      },
                    ),
                  );
                });
          } else {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Looking for printers."),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {});
        },
        tooltip: 'Retry',
        child: Icon(Icons.refresh),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<ui.Image> loadImage(String assetPath) async {
    final ByteData img = await rootBundle.load(assetPath);
    final Completer<ui.Image> completer = new Completer();
    ui.decodeImageFromList(new Uint8List.view(img.buffer), (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }
}

// DEBUG NEW
class QlBluetoothPrintHappyMothersDay extends StatefulWidget {
  QlBluetoothPrintHappyMothersDay({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _QlBluetoothPrintHappyMothersDayState createState() =>
      _QlBluetoothPrintHappyMothersDayState();
}

class _QlBluetoothPrintHappyMothersDayState
    extends State<QlBluetoothPrintHappyMothersDay> {
  bool _error = false;
  var _belated = "";
  var _mdAddress = "";
  var _mdDate = "Mother's day";
  var _assetImage = 'assets/blank.png';
  GlobalKey _globalKey = GlobalKey();
  Uint8List pngBytes;
  var mother_label_image = "";

  /*
  Future<void> _capturePng() async {
    RenderRepaintBoundary boundary =
        globalKey.currentContext.findRenderObject();
    ui.Image image = await boundary.toImage();
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData.buffer.asUint8List();
    print(pngBytes);
  }
  */

  Future<void> _capturePng() async {
    try {
      final RenderRepaintBoundary boundary =
          _globalKey.currentContext.findRenderObject();
      final image = await boundary.toImage(pixelRatio: 2.0); // image quality
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      pngBytes = byteData.buffer.asUint8List();

//      final directory = (await getApplicationDocumentsDirectory()).path;
//      File imgFile = new File('$directory/mother_label.png');
//      mother_label_image = '$directory/mother_label.png';
//      imgFile.writeAsBytes(pngBytes);
    } catch (e) {
      print(e);
    }
  }

  void print(BuildContext context) async {
    var printer = new Printer();
    var printInfo = PrinterInfo();
    printInfo.printerModel = Model.QL_1110NWB;
    printInfo.printMode = PrintMode.FIT_TO_PAGE;
    printInfo.isAutoCut = true;
    printInfo.port = Port.BLUETOOTH;
    // Set the label type.
    printInfo.labelNameIndex = QL1100.ordinalFromID(QL1100.W103.getId());

    // Set the printer info so we can use the SDK to get the printers.
    await printer.setPrinterInfo(printInfo);

    // Get a list of printers with my model available in the network.
    List<BluetoothPrinter> printers =
        await printer.getBluetoothPrinters([Model.QL_1110NWB.getName()]);

    if (printers.isEmpty) {
      // Show a message if no printers are found.
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("No paired printers found on your device."),
        ),
      ));

      return;
    }
    // Get the IP Address from the first printer found.
    printInfo.macAddress = printers.single.macAddress;

    printer.setPrinterInfo(printInfo);
//    printer.printImage(await loadImage('assets/brother_hack.png'));
    await _capturePng();
    printer.printImage(await loadImageFromUint8List(pngBytes));
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "How will you\naddress your Mother?",
                  textAlign: TextAlign.right,
                ),
              ),
              SizedBox(
                width: 125.0,
                child: ElevatedButton(
                  child: Text('Randomize'),
                  onPressed: () {
                    setState(() {
                      var phrases = [
                        "Dearest mother",
                        "Yo! Mama",
                        "Dear Grandma",
                        "дорогая мама",
                        "Dear BrotherMother",
                      ];
                      var rng = new Random();
                      _mdAddress = phrases[rng.nextInt(phrases.length)];
                    });
                  },
                ),
              ),
              Padding(padding: const EdgeInsets.all(8.0)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "What year are\nyou celebrating?",
                  textAlign: TextAlign.right,
                ),
              ),
              SizedBox(
                width: 125.0,
                child: TextFormField(
                    maxLength: 4,
                    initialValue: "2021",
                    decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Enter the year'),
                    onChanged: (x) {
                      setState(() {
                        try {
                          var year = int.parse(x);
                          if (year >= 2000 && year <= 2050) {
                            int day = 1;

                            do {
                              var dayDatetime = DateTime(year, 5, day);
                              if (dayDatetime.weekday == DateTime.sunday) break;
                              day += 1;
                            } while (true);

                            _mdDate = "May " + (day + 7).toString() + ", " + x;
                            _belated = (year < 2021) ? " belated" : "";
                          }
                        } on FormatException {}
                      });
                    }),
              ),
              Padding(padding: const EdgeInsets.all(8.0)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "What design do\nyou want?",
                  textAlign: TextAlign.right,
                ),
              ),
              SizedBox(
                width: 125.0,
                child: ElevatedButton(
                  child: Text('Randomize'),
                  onPressed: () {
                    setState(() {
                      var images = [
                        "blank.png",
                        "brother_hack.png",
                        "flower.png",
                        "flower2.png",
                        "dolphin.png",
                        "mother_lover.png"
                      ];

                      var rng = new Random();
                      _assetImage =
                          "assets/" + images[rng.nextInt(images.length)];
                    });
                  },
                ),
              ),
              Padding(padding: const EdgeInsets.all(8.0)),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              //"Do not forget to grant permissions to your app in Settings.",
              "\n",
              textAlign: TextAlign.center,
            ),
          ),
          new Container(
            key: _globalKey,
            margin: const EdgeInsets.all(15.0),
            padding: const EdgeInsets.all(3.0),
            decoration:
                BoxDecoration(border: Border.all(color: Colors.blueAccent)),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image(width: 50.0, image: AssetImage(_assetImage)),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "$_mdAddress,\n" +
                          "Happy$_belated mother's day!\n" +
                          (_belated == " belated"
                              ? ""
                              : "Do not open until $_mdDate"),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Image(width: 50.0, image: AssetImage(_assetImage))
                ]),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => print(context),
        tooltip: 'Print',
        child: Icon(Icons.print),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<ui.Image> loadImage(String assetPath) async {
    final ByteData img = await rootBundle.load(assetPath);
    final Completer<ui.Image> completer = new Completer();
    ui.decodeImageFromList(new Uint8List.view(img.buffer), (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }

  Future<ui.Image> loadImageFromUint8List(Uint8List encoded_image) async {
    final Completer<ui.Image> completer = new Completer();
    ui.decodeImageFromList(encoded_image, (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }
}
