import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:window_test/Logic/Cube.dart';
import 'package:window_test/Logic/Renderer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'View Demo',
      theme: ThemeData(primarySwatch: Colors.blueGrey),
      home: MyHomePage(title: 'View Demo Home Page'),
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

  // Stopwatch s = Stopwatch();

  // late List<ProjectedTriangle> trisToDraw = Renderer().project(Cube.MeshCube);

  @override
  void initState() {
    super.initState();
    // projection matrix
    // s.start();
    // List<ProjectedTriangle> trisToDraw = Renderer().project(Cube.MeshCube);

    Timer _timer = Timer.periodic(Duration(milliseconds: 16), (Timer t) {
      tick();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: CustomPaint(
        size: Size(900, 900),
        painter: TrisPainter(Renderer().project(Cube().MeshCube, time / 20)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: tick,
        tooltip: 'Loop',
        child: const Icon(Icons.add),
      ),
    );
  }

  void tick() {
    print("Tick");
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


