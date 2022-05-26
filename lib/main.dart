import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'View Demo',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey
      ),
      home: const MyHomePage(title: 'View Demo Home Page'),
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
  List<Polygon> polys = [];

  void _addTriangle() {
    setState(() {
      polys.add(Polygon(
        Point(Random.secure().nextDouble() * window.physicalSize.width,Random.secure().nextDouble() * window.physicalSize.height), 
        Point(Random.secure().nextDouble() * window.physicalSize.width,Random.secure().nextDouble() * window.physicalSize.height),
        Point(Random.secure().nextDouble() * window.physicalSize.width,Random.secure().nextDouble() * window.physicalSize.height), 
        Colors.black45));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Stack(
          children: polys,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTriangle,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
  
}

class PolygonPath extends CustomClipper<Path> {
  Point p1, p2, p3;
  PolygonPath(Point p1, Point p2, Point p3) : p1 = p1, p2 = p2, p3 = p3;

  @override
  Path getClip(Size size) {
    Path path = Path();
    path.addPolygon([
      Offset(p1.x, p1.y),
      Offset(p2.x, p2.y),
      Offset(p3.x, p3.y),
    ], true);
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

class Point {
  double x, y;
  Point(double x, double y) : x = x, y = y;
}

class Polygon extends ClipPath{
  Polygon(Point p1, Point p2, Point p3, Color color, {Key? key}) : super(key: key, 
    clipper: PolygonPath(p1, p2, p3),
    child: Container(
              color: color,
              width: window.physicalSize.width,
              height: window.physicalSize.width,
            ),
    );
}