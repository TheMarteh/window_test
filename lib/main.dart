import 'package:flutter/material.dart';
import 'package:window_test/globals.dart';
import 'package:window_test/logic/Cube.dart';
import 'package:window_test/logic/ObjConverter.dart';
import 'package:window_test/logic/Renderer.dart';
import "package:universal_html/html.dart" as html;
import 'package:window_test/globals.dart';

import 'dart:async';

import 'package:window_test/widgets/controlPad.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '3D engine Demo',
      theme: ThemeData(primarySwatch: Colors.blueGrey),
      home: const MyHomePage(title: '3D engine demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // List<Polygon> polys = [];
  List<Offset> pointsToDraw = [];
  double time = 0.0;
  Mesh object = Cube().MeshCube;
  late Timer _timer;
  bool paused = false;
  final int msBetweenTicks = 1000 ~/ Globals.targetTickRate;
  late ControlPadInputs inputs;
  late Renderer renderer;
  List<String> assetLocationStrings = [
    'assets/teddybear.obj',
    'assets/teapot.obj',
    'assets/cow.obj',
    'assets/axis.obj',
  ];
  ObjConverter o = ObjConverter('assets/testfile.obj');

  Stopwatch s = Stopwatch();

  // late List<ProjectedTriangle> trisToDraw = Renderer().project(Cube.MeshCube);

  @override
  void initState() {
    s.start();
    _timer = Timer.periodic(Duration(milliseconds: msBetweenTicks), (Timer t) {
      if (!paused) {
        tick();
      }
    });

    o.getMesh().then((Mesh obj) {
      object = obj;
      print("obj should be loaded");
    });
    inputs = ControlPadInputs();
    renderer = Renderer();

    html.document.body!
        .addEventListener('contextmenu', (event) => event.preventDefault());
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    s.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.title} - Polygons: ${object.tris.length}"),
      ),
      body: Stack(
        children: [
          // TODO: Add a 'window' around the renderer
          CustomPaint(
            size: Size(Globals.screenWidth, Globals.screenHeight),
            painter: TrisPainter(renderer.project(object, time / 1000, inputs,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height)),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                inputs.widget(),
                Container(
                  height: 60,
                )
              ],
            ),
          ),
          Positioned(
            top: 15,
            left: 15,
            child: FloatingActionButton(
              child: Icon(Icons.sync_outlined),
              onPressed: () {
                assetLocationStrings.shuffle();
                String string = assetLocationStrings.first;
                o = ObjConverter(string);
                o.getMesh().then((Mesh obj) {
                  object = obj;
                  print("obj should be loaded");
                });
                print("hello!");
              },
              tooltip: "Hello",
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pausePlay,
        tooltip: 'Play/Pause',
        child: paused ? const Icon(Icons.play_arrow) : const Icon(Icons.pause),
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  void tick() {
    // print("Tick");
    setState(() {
      time = s.elapsedMilliseconds.toDouble();
      s.reset();
    });
  }

  void _pausePlay() {
    setState(() {
      paused = !paused;
    });
    if (paused) {
      s.stop();
    } else {
      s.start();
    }
  }
}

class Point {
  double x, y;
  Point(this.x, this.y);
}

// NEW STYLE


