import 'package:flutter/material.dart';
import 'package:window_test/globals.dart';
import 'package:window_test/logic/Cube.dart';
import 'package:window_test/logic/ObjConverter.dart';
import 'package:window_test/logic/Renderer.dart';

import 'dart:async';
import 'dart:ui';

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
      home: MyHomePage(title: '3D engine demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // List<Polygon> polys = [];
  List<Offset> pointsToDraw = [];
  double time = 100.0;
  Mesh object = Cube().MeshCube;
  late Timer _timer;
  bool paused = false;
  ObjConverter o = ObjConverter('assets/teddybear.obj');

  // Stopwatch s = Stopwatch();

  // late List<ProjectedTriangle> trisToDraw = Renderer().project(Cube.MeshCube);

  @override
  void initState() {
    // projection matrix
    // s.start();
    // List<ProjectedTriangle> trisToDraw = Renderer().project(Cube.MeshCube);

    _timer = Timer.periodic(Duration(milliseconds: 33), (Timer t) {
      if (!paused) {
        tick();
      }
    });

    o.getMesh().then((Mesh obj) {
      object = obj;
      print("obj should be loaded");
    });
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.title + " - Polygons: " + object.tris.length.toString()),
      ),
      body: CustomPaint(
        size: Size(Globals.screenWidth, Globals.screenHeight),
        painter: TrisPainter(Renderer().project(object, time / 20)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => paused = !paused,
        tooltip: 'Play/Pause',
        child: paused ? const Icon(Icons.play_arrow) : const Icon(Icons.pause),
      ),
    );
  }

  void tick() {
    // print("Tick");
    setState(() {
      time++;
    });
  }
}

class Point {
  double x, y;
  Point(this.x, this.y) {}
}

// NEW STYLE


