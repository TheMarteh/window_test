import 'package:flutter/material.dart';
import 'package:window_test/globals.dart';
import 'dart:math';
import 'dart:ui';


class Renderer {
  Vec3D multiplyMatrixVector(final Vec3D i, Vec3D o, Mat4x4 m) {
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

  Color calculateColor(double lum) {
    Color baseColor = Color.fromARGB(255, 209, 255, 84);
    int range = 125;
    int scalenum = (125 * lum).round();

    // with material gradients
    int gradientnum = (lum.abs() * 9).round();
    List<Color> colors = [
      Colors.blue.shade900,
      Colors.blue.shade800,
      Colors.blue.shade700,
      Colors.blue.shade600,
      Colors.blue.shade500,
      Colors.blue.shade400,
      Colors.blue.shade300,
      Colors.blue.shade200,
      Colors.blue.shade100,
      Colors.blue.shade50,
    ];
    Color gradientColor = colors[gradientnum];
    Color newColor = Color.fromARGB(baseColor.alpha, baseColor.red - scalenum,
        baseColor.green - scalenum, baseColor.blue - scalenum);

    return gradientColor;
  }

  List<Triangle> project(Mesh mesh, double time) {
    // List<ProjectedTriangle> trisToDraw = [];
    List<Triangle> trisToRaster = [];
    Mat4x4 matProj = Mat4x4();

    // camera placeholder
    Vec3D vCamera = Vec3D(0.0, 0.0, 0.0);
    Vec3D light_direction = Vec3D(0.0, 0.0, -1.0);

    double fNear = 0.1;
    double fFar = 1000.0;
    double fFov = 90.0;
    double fAspectRatio = (Globals.screenHeight.toDouble()) /
        Globals.screenWidth.toDouble();
    double fFovRad = 1.0 / tan(fFov * 0.5 / 180.0 * 3.14159265);

    // Projection Matrix for projecting the 3d Vertices to a 2d canvas
    matProj.m[0][0] = fAspectRatio * fFovRad;
    matProj.m[1][1] = fFovRad;
    matProj.m[2][2] = fFar / (fFar - fNear);
    matProj.m[3][2] = (-fFar * fNear) / (fFar - fNear);
    matProj.m[2][3] = 1.0;
    matProj.m[3][3] = 0.0;

    Mat4x4 matRotZ = Mat4x4();
    Mat4x4 matRotX = Mat4x4();

    double fTheta = 1.0 * time;

    // Rotation Matrix for Z axis
    matRotZ.m[0][0] = cos(fTheta);
    matRotZ.m[0][1] = sin(fTheta);
    matRotZ.m[1][0] = -sin(fTheta);
    matRotZ.m[1][1] = cos(fTheta);
    matRotZ.m[2][2] = 1;
    matRotZ.m[3][3] = 1;

    // Rotation Matrix for X axis
    matRotX.m[0][0] = 1;
    matRotX.m[1][1] = cos(fTheta * 0.5);
    matRotX.m[1][2] = sin(fTheta * 0.5);
    matRotX.m[2][1] = -sin(fTheta * 0.5);
    matRotX.m[2][2] = cos(fTheta * 0.5);
    matRotX.m[3][3] = 1;

    for (Triangle tri in mesh.tris) {
      // initialize Triangles to work with
      Triangle triToWorkWith = tri;
      Triangle triProjected = Triangle.empty();
      Triangle triTranslated = Triangle.empty();
      Triangle triRotatedZ = Triangle.empty();
      Triangle triRotatedZX = Triangle.empty();

      // Rotate in z axis
      multiplyMatrixVector(triToWorkWith.arr[0], triRotatedZ.arr[0], matRotZ);
      multiplyMatrixVector(triToWorkWith.arr[1], triRotatedZ.arr[1], matRotZ);
      multiplyMatrixVector(triToWorkWith.arr[2], triRotatedZ.arr[2], matRotZ);

      // Rotate in X axis
      multiplyMatrixVector(triRotatedZ.arr[0], triRotatedZX.arr[0], matRotX);
      multiplyMatrixVector(triRotatedZ.arr[1], triRotatedZX.arr[1], matRotX);
      multiplyMatrixVector(triRotatedZ.arr[2], triRotatedZX.arr[2], matRotX);

      // Move in Z-axis to render the cube in front of the camera
      triTranslated = triRotatedZX;
      triTranslated.arr[0].z = triRotatedZX.arr[0].z + 8.0;
      triTranslated.arr[1].z = triRotatedZX.arr[1].z + 8.0;
      triTranslated.arr[2].z = triRotatedZX.arr[2].z + 8.0;

      Vec3D normal = Vec3D(0.0, 0.0, 0.0);
      Vec3D line1 = Vec3D(0.0, 0.0, 0.0);
      Vec3D line2 = Vec3D(0.0, 0.0, 0.0);

      // calculate the normal
      line1.x = triTranslated.arr[1].x - triTranslated.arr[0].x;
      line1.y = triTranslated.arr[1].y - triTranslated.arr[0].y;
      line1.z = triTranslated.arr[1].z - triTranslated.arr[0].z;

      line2.x = triTranslated.arr[2].x - triTranslated.arr[0].x;
      line2.y = triTranslated.arr[2].y - triTranslated.arr[0].y;
      line2.z = triTranslated.arr[2].z - triTranslated.arr[0].z;

      normal.x = line1.y * line2.z - line1.z * line2.y;
      normal.y = line1.z * line2.x - line1.x * line2.z;
      normal.z = line1.x * line2.y - line1.y * line2.x;

      double l =
          sqrt(normal.x * normal.x + normal.y * normal.y + normal.z * normal.z);
      normal.x /= l;
      normal.y /= l;
      normal.z /= l;

      // The normal is used to check if the triangle is actually facing the
      // camera or not
      if (normal.x * (triTranslated.arr[0].x - vCamera.x) +
              normal.y * (triTranslated.arr[0].y - vCamera.y) +
              normal.z * (triTranslated.arr[0].z - vCamera.z) <
          0.0) {
        // illumination
        double l = sqrt(light_direction.x * light_direction.x +
            light_direction.y * light_direction.y +
            light_direction.z * light_direction.z);
        light_direction.x /= l;
        light_direction.y /= l;
        light_direction.z /= l;

        double dp = normal.x * light_direction.x +
            normal.y * light_direction.y +
            normal.z * light_direction.z;

        Color col = calculateColor(dp);

        // Project the 3d-Triangles to a 2d space
        multiplyMatrixVector(
            triTranslated.arr[0], triProjected.arr[0], matProj);
        multiplyMatrixVector(
            triTranslated.arr[1], triProjected.arr[1], matProj);
        multiplyMatrixVector(
            triTranslated.arr[2], triProjected.arr[2], matProj);

        // Move into screen
        triProjected.arr[0].x += 1.0;
        triProjected.arr[0].y += 1.0;
        triProjected.arr[1].x += 1.0;
        triProjected.arr[1].y += 1.0;
        triProjected.arr[2].x += 1.0;
        triProjected.arr[2].y += 1.0;

        // Scale into view
        triProjected.arr[0].x *= 0.5 * Globals.screenWidth.toDouble();
        triProjected.arr[0].y *=
            0.5 * Globals.screenHeight.toDouble();
        triProjected.arr[1].x *= 0.5 * Globals.screenWidth.toDouble();
        triProjected.arr[1].y *=
            0.5 * Globals.screenHeight.toDouble();
        triProjected.arr[2].x *= 0.5 * Globals.screenWidth.toDouble();
        triProjected.arr[2].y *= 0.5 * Globals.screenHeight.toDouble();
        triProjected.col = col;

        trisToRaster.add(triProjected);

        // // Draw Triangles
        // trisToDraw.add(ProjectedTriangle(
        //     triProjected.arr[0].x,
        //     triProjected.arr[0].y,
        //     triProjected.arr[1].x,
        //     triProjected.arr[1].y,
        //     triProjected.arr[2].x,
        //     triProjected.arr[2].y,
        //     col));
      }
    }
    return trisToRaster;
  }
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
  Color col;
  Triangle(Vec3D p1, Vec3D p2, Vec3D p3, {this.col = Colors.green}) {
    arr.add(p1);
    arr.add(p2);
    arr.add(p3);
  }
  Triangle.from(Triangle t, {this.col = Colors.green}) {
    arr.add(t.arr[0]);
    arr.add(t.arr[1]);
    arr.add(t.arr[2]);
  }
  Triangle.empty({this.col = Colors.green}) {
    arr = [Vec3D(0.0, 0.0, 0.0), Vec3D(0.0, 0.0, 0.0), Vec3D(0.0, 0.0, 0.0)];
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
  Color color;
  ProjectedTriangle(double x1, double y1, double x2, double y2, double x3,
      double y3, this.color) {
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
  // final List<ProjectedTriangle> trisToDraw;
  final List<Triangle> trisToRaster;
  bool wireframing;
  TrisPainter(this.trisToRaster, {this.wireframing = false})
      : super(repaint: DrawingController());
  @override
  void paint(Canvas canvas, Size size) {
    final wireframePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 1;

    trisToRaster.sort((t1, t2) {
      double z1 = (t1.arr[0].z + t1.arr[1].z + t1.arr[2].z) / 3.0;
      double z2 = (t2.arr[0].z + t2.arr[1].z + t2.arr[2].z) / 3.0;
      return z1.compareTo(z2);
    });

    for (Triangle tri in trisToRaster) {
      final paint = Paint()
        ..color = tri.col
        ..strokeWidth = 1;
      Path path = Path()
        ..moveTo(tri.arr[0].x, tri.arr[0].y)
        ..lineTo(tri.arr[1].x, tri.arr[1].y)
        ..lineTo(tri.arr[2].x, tri.arr[2].y)
        ..close();

      canvas.drawPath(path, paint);

      // Wireframe painting
      if (this.wireframing == true) {
        canvas.drawLine(Offset(tri.arr[0].x, tri.arr[0].y),
            Offset(tri.arr[1].x, tri.arr[1].y), wireframePaint);
        canvas.drawLine(Offset(tri.arr[1].x, tri.arr[1].y),
            Offset(tri.arr[2].x, tri.arr[2].y), wireframePaint);
        canvas.drawLine(Offset(tri.arr[2].x, tri.arr[2].y),
            Offset(tri.arr[0].x, tri.arr[0].y), wireframePaint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return true;
  }
}

class DrawingController extends ChangeNotifier {
  double time = 0.0;

  void add() {
    time += 1.0;
    notifyListeners();
  }
}
