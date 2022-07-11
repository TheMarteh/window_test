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
  late List<ProjectedTriangle> trisToDraw = Renderer().project(Cube.MeshCube);

  @override
  void initState() {
    super.initState();
    // projection matrix

    // List<ProjectedTriangle> trisToDraw = Renderer().project(Cube.MeshCube);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: CustomPaint(
        size: Size(900, 900),
        painter: TrisPainter(trisToDraw),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {},
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class Point {
  double x, y;
  Point(this.x, this.y) {}
}

// NEW STYLE


