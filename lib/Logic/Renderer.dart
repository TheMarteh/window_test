import 'dart:math';

import 'package:flutter/material.dart';

class Renderer {
  Vec3D multiplyMatrixVector(Vec3D i, Vec3D o, Mat4x4 m) {
    // print("Before multiplication: " + i.x.toString());
    double x = i.x.toDouble();
    double y = i.y.toDouble();
    double z = i.z.toDouble();

    o.x = (i.x * m.m[0][0]) + (i.y * m.m[1][0]) + (i.z * m.m[2][0]) + m.m[3][0];
    // print("After o.x: " + i.x.toString());

    o.y = (i.x * m.m[0][1]) + (i.y * m.m[1][1]) + (i.z * m.m[2][1]) + m.m[3][1];
    o.z = (i.x * m.m[0][2]) + (i.y * m.m[1][2]) + (i.z * m.m[2][2]) + m.m[3][2];

    // print("After multiplication: " + i.x.toString());
    // print("After testing: " + i.x.toString());

    double w =
        (i.x * m.m[0][3]) + (i.y * m.m[1][3]) + (i.z * m.m[2][3]) + m.m[3][3];
    if (w != 0.0) {
      o.x /= w;
      o.y /= w;
      o.z /= w;
    }
    return Vec3D(x, y, z);
  }

  List<ProjectedTriangle> project(Mesh mesh, double time) {
    List<ProjectedTriangle> trisToDraw = [];
    Mat4x4 matProj = Mat4x4();
    double fNear = 0.1;
    double fFar = 1000.0;
    double fFov = 90.0;
    double fAspectRatio = (300.toDouble() - 30) / 300.toDouble();
    double fFovRad = 1.0 / tan(fFov * 0.5 / 180.0 * 3.14159265);

    matProj.m[0][0] = fAspectRatio * fFovRad;
    matProj.m[1][1] = fFovRad;
    matProj.m[2][2] = fFar / (fFar - fNear);
    matProj.m[3][2] = (-fFar * fNear) / (fFar - fNear);
    matProj.m[2][3] = 1.0;
    matProj.m[3][3] = 0.0;

    Mat4x4 matRotZ = Mat4x4();
    Mat4x4 matRotX = Mat4x4();

    double fTheta = 1.0 * time;

    // Rotation Z
    matRotZ.m[0][0] = cos(fTheta);
    matRotZ.m[0][1] = sin(fTheta);
    matRotZ.m[1][0] = -sin(fTheta);
    matRotZ.m[1][1] = cos(fTheta);
    matRotZ.m[2][2] = 1;
    matRotZ.m[3][3] = 1;

    // Rotation X
    matRotX.m[0][0] = 1;
    matRotX.m[1][1] = cos(fTheta * 0.5);
    matRotX.m[1][2] = sin(fTheta * 0.5);
    matRotX.m[2][1] = -sin(fTheta * 0.5);
    matRotX.m[2][2] = cos(fTheta * 0.5);
    matRotX.m[3][3] = 1;

    for (Triangle tri in mesh.tris) {
      Triangle triToWorkWith = tri;
      Triangle triProjected = Triangle(
          Vec3D(0.0, 0.0, 0.0), Vec3D(0.0, 0.0, 0.0), Vec3D(0.0, 0.0, 0.0));
      Triangle triTranslated = Triangle(
          Vec3D(0.0, 0.0, 0.0), Vec3D(0.0, 0.0, 0.0), Vec3D(0.0, 0.0, 0.0));

      Triangle triRotatedZ = Triangle(
          Vec3D(0.0, 0.0, 0.0), Vec3D(0.0, 0.0, 0.0), Vec3D(0.0, 0.0, 0.0));
      Triangle triRotatedZX = Triangle(
          Vec3D(0.0, 0.0, 0.0), Vec3D(0.0, 0.0, 0.0), Vec3D(0.0, 0.0, 0.0));

      // triProjected = triToWorkWith;
      // triRotatedZ = triToWorkWith;

      multiplyMatrixVector(triToWorkWith.arr[0], triRotatedZ.arr[0], matRotZ);
      multiplyMatrixVector(triToWorkWith.arr[1], triRotatedZ.arr[1], matRotZ);
      multiplyMatrixVector(triToWorkWith.arr[2], triRotatedZ.arr[2], matRotZ);

      // triRotatedZX = triRotatedZ;

      multiplyMatrixVector(triRotatedZ.arr[0], triRotatedZX.arr[0], matRotX);
      multiplyMatrixVector(triRotatedZ.arr[1], triRotatedZX.arr[1], matRotX);
      multiplyMatrixVector(triRotatedZ.arr[2], triRotatedZX.arr[2], matRotX);

      triTranslated = triRotatedZX;
      triTranslated.arr[0].z = triRotatedZX.arr[0].z + 3.0;
      triTranslated.arr[1].z = triRotatedZX.arr[1].z + 3.0;
      triTranslated.arr[2].z = triRotatedZX.arr[2].z + 3.0;

      multiplyMatrixVector(triTranslated.arr[0], triProjected.arr[0], matProj);
      multiplyMatrixVector(triTranslated.arr[1], triProjected.arr[1], matProj);
      multiplyMatrixVector(triTranslated.arr[2], triProjected.arr[2], matProj);

      triProjected.arr[0].y += 1.0;
      triProjected.arr[1].x += 1.0;
      triProjected.arr[1].y += 1.0;
      triProjected.arr[2].x += 1.0;
      triProjected.arr[0].x += 1.0;
      triProjected.arr[2].y += 1.0;

      triProjected.arr[0].x *= 0.5 * 800.toDouble();
      triProjected.arr[0].y *= 0.5 * 800.toDouble() - 30;
      triProjected.arr[1].x *= 0.5 * 800.toDouble();
      triProjected.arr[1].y *= 0.5 * 800.toDouble() - 30;
      triProjected.arr[2].x *= 0.5 * 800.toDouble();
      triProjected.arr[2].y *= 0.5 * 800.toDouble() - 30;

      trisToDraw.add(ProjectedTriangle(
          triProjected.arr[0].x,
          triProjected.arr[0].y,
          triProjected.arr[1].x,
          triProjected.arr[1].y,
          triProjected.arr[2].x,
          triProjected.arr[2].y));
    }
    return trisToDraw;
  }

  // void _drawTriangle(double x1, y1, x2, y2, x3, y3) {
  //   trisToDraw.add(ProjectedTriangle(x1, y1, x2, y2, x3, y3));
  // }
}

class Vec3D {
  late double x;
  late double y;
  late double z;
  Vec3D(double x, double y, double z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }
}

class Triangle {
  List<Vec3D> arr = [];
  Triangle(Vec3D p1, Vec3D p2, Vec3D p3) {
    arr.add(p1);
    arr.add(p2);
    arr.add(p3);
  }
  Triangle.from(Triangle t) {
    arr.add(t.arr[0]);
    arr.add(t.arr[1]);
    arr.add(t.arr[2]);
  }
}

class Mesh {
  List<Triangle> tris;
  Mesh(this.tris);
}

class Mat4x4 {
  late List<List<double>> m;
  Mat4x4() {
    m = [
      [0.0, 0.0, 0.0, 0.0],
      [0.0, 0.0, 0.0, 0.0],
      [0.0, 0.0, 0.0, 0.0],
      [0.0, 0.0, 0.0, 0.0]
    ];
    // m = List<List<double>>.filled(4, List<double>.filled(4, 0));
  }
}

class ProjectedTriangle {
  List<Offset> offsets = List<Offset>.filled(3, Offset(0.0, 0.0));
  List<double> doubles = [];
  ProjectedTriangle(
      double x1, double y1, double x2, double y2, double x3, double y3) {
    offsets[0] = Offset(x1, y1);
    offsets[1] = Offset(x2, y2);
    offsets[2] = Offset(x3, y3);
    doubles.add(x1);
    doubles.add(y1);
    doubles.add(x2);
    doubles.add(y2);
    doubles.add(x3);
    doubles.add(y3);
  }
}

class TrisPainter extends CustomPainter {
  //         <-- CustomPainter class
  final List<ProjectedTriangle> trisToDraw;
  TrisPainter(this.trisToDraw);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2;

    for (ProjectedTriangle tri in trisToDraw) {
      canvas.drawLine(Offset(tri.doubles[0], tri.doubles[1]),
          Offset(tri.doubles[2], tri.doubles[3]), paint);
      canvas.drawLine(Offset(tri.doubles[2], tri.doubles[3]),
          Offset(tri.doubles[4], tri.doubles[5]), paint);
      canvas.drawLine(Offset(tri.doubles[0], tri.doubles[1]),
          Offset(tri.doubles[4], tri.doubles[5]), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return false;
  }
}
