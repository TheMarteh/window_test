import 'package:flutter/material.dart';
import 'package:window_test/globals.dart';
import 'dart:math';

import 'package:window_test/widgets/controlPad.dart';

class Renderer {
  double zOffSet = 30;

  // camera placeholder
  Vec3D vCamera = Vec3D(0.0, 0.0, 0.0);
  Vec3D vLookDirection = Vec3D(0, 0, 1);

  Mat4x4 matProj = Renderer.Matrix_MakeProjection(
      90,
      (Globals.screenHeight.toDouble()) / Globals.screenWidth.toDouble(),
      0.1,
      1000);

  Vec3D Matrix_MultiplyVector(Mat4x4 m, Vec3D i) {
    Vec3D v = Vec3D(0, 0, 0);

    v.x = (i.x * m.m[0][0]) +
        (i.y * m.m[1][0]) +
        (i.z * m.m[2][0]) +
        (i.w * m.m[3][0]);
    v.y = (i.x * m.m[0][1]) +
        (i.y * m.m[1][1]) +
        (i.z * m.m[2][1]) +
        (i.w * m.m[3][1]);
    v.z = (i.x * m.m[0][2]) +
        (i.y * m.m[1][2]) +
        (i.z * m.m[2][2]) +
        (i.w * m.m[3][2]);
    v.w = (i.x * m.m[0][3]) +
        (i.y * m.m[1][3]) +
        (i.z * m.m[2][3]) +
        (i.w * m.m[3][3]);
    return v;

    // print("After multiplication: " + i.x.toString());
    // print("After testing: " + i.x.toString());

    // double w =
    //     (i.x * m.m[0][3]) + (i.y * m.m[1][3]) + (i.z * m.m[2][3]) + m.m[3][3];
    // if (w != 0.0) {
    //   o.x /= w;
    //   o.y /= w;
    //   o.z /= w;
    // }
    // return Vec3D(o.x, o.y, o.z);
  }

  Mat4x4 Matrix_MakeIdentity() {
    Mat4x4 matrix = Mat4x4();
    matrix.m[0][0] = 1.0;
    matrix.m[1][1] = 1.0;
    matrix.m[2][2] = 1.0;
    matrix.m[3][3] = 1.0;
    return matrix;
  }

  Mat4x4 Matrix_MakeRotationX(double angleRad) {
    Mat4x4 matrix = Mat4x4();
    matrix.m[0][0] = 1.0;
    matrix.m[1][1] = cos(angleRad);
    matrix.m[1][2] = sin(angleRad);
    matrix.m[2][1] = -sin(angleRad);
    matrix.m[2][2] = cos(angleRad);
    matrix.m[3][3] = 1.0;
    return matrix;
  }

  Mat4x4 Matrix_MakeRotationY(double angleRad) {
    Mat4x4 matrix = Mat4x4();
    matrix.m[0][0] = cos(angleRad);
    matrix.m[0][2] = sin(angleRad);
    matrix.m[2][0] = -sin(angleRad);
    matrix.m[1][1] = 1.0;
    matrix.m[2][2] = cos(angleRad);
    matrix.m[3][3] = 1.0;
    return matrix;
  }

  Mat4x4 Matrix_MakeRotationZ(double angleRad) {
    Mat4x4 matrix = Mat4x4();
    matrix.m[0][0] = cos(angleRad);
    matrix.m[0][1] = sin(angleRad);
    matrix.m[1][0] = -sin(angleRad);
    matrix.m[1][1] = cos(angleRad);
    matrix.m[2][2] = 1.0;
    matrix.m[3][3] = 1.0;
    return matrix;
  }

  Mat4x4 Matrix_MakeTranslation(double x, double y, double z) {
    Mat4x4 matrix = Mat4x4();
    matrix.m[0][0] = 1.0;
    matrix.m[1][1] = 1.0;
    matrix.m[2][2] = 1.0;
    matrix.m[3][3] = 1.0;
    matrix.m[3][0] = x;
    matrix.m[3][1] = y;
    matrix.m[3][2] = z;
    return matrix;
  }

  static Mat4x4 Matrix_MakeProjection(
      double fovDegrees, double aspectRatio, double near, double far) {
    double fovRad = 1.0 / tan(fovDegrees * 0.5 / 180.0 * 3.14159265);
    Mat4x4 matrix = Mat4x4();
    matrix.m[0][0] = aspectRatio * fovRad;
    matrix.m[1][1] = fovRad;
    matrix.m[2][2] = far / (far - near);
    matrix.m[3][2] = (-far * near) / (far - near);
    matrix.m[2][3] = 1.0;
    matrix.m[3][3] = 0.0;
    return matrix;
  }

  Mat4x4 Matrix_MultiplyMatrix(Mat4x4 m1, Mat4x4 m2) {
    Mat4x4 matrix = Mat4x4();
    for (int c = 0; c < 4; c++) {
      for (int r = 0; r < 4; r++) {
        matrix.m[r][c] = m1.m[r][0] * m2.m[0][c] +
            m1.m[r][1] * m2.m[1][c] +
            m1.m[r][2] * m2.m[2][c] +
            m1.m[r][3] * m2.m[3][c];
      }
    }
    return matrix;
  }

  Mat4x4 Matrix_PointAt(Vec3D pos, Vec3D target, Vec3D up) {
    Vec3D newForward = Vector_Sub(target, pos);
    newForward = Vector_Normalize(newForward);

    Vec3D a = Vector_Mul(newForward, Vector_DotProduct(up, newForward));
    Vec3D newUp = Vector_Sub(up, a);
    newUp = Vector_Normalize(newUp);

    Vec3D newRight = Vector_CrossProduct(newUp, newForward);

    Mat4x4 matrix = Mat4x4();
    matrix.m[0][0] = newRight.x;
    matrix.m[0][1] = newRight.y;
    matrix.m[0][2] = newRight.z;
    matrix.m[0][3] = 0.0;
    matrix.m[1][0] = newUp.x;
    matrix.m[1][1] = newUp.y;
    matrix.m[1][2] = newUp.z;
    matrix.m[1][3] = 0.0;
    matrix.m[2][0] = newForward.x;
    matrix.m[2][1] = newForward.y;
    matrix.m[2][2] = newForward.z;
    matrix.m[2][3] = 0.0;
    matrix.m[3][0] = pos.x;
    matrix.m[3][1] = pos.y;
    matrix.m[3][2] = pos.z;
    matrix.m[3][3] = 1.0;
    return matrix;
  }

  Mat4x4 Matrix_QuickInverse(Mat4x4 m) // Only for Rotation/Translation Matrices
  {
    Mat4x4 matrix = Mat4x4();
    matrix.m[0][0] = m.m[0][0];
    matrix.m[0][1] = m.m[1][0];
    matrix.m[0][2] = m.m[2][0];
    matrix.m[0][3] = 0.0;
    matrix.m[1][0] = m.m[0][1];
    matrix.m[1][1] = m.m[1][1];
    matrix.m[1][2] = m.m[2][1];
    matrix.m[1][3] = 0.0;
    matrix.m[2][0] = m.m[0][2];
    matrix.m[2][1] = m.m[1][2];
    matrix.m[2][2] = m.m[2][2];
    matrix.m[2][3] = 0.0;
    matrix.m[3][0] = -(m.m[3][0] * matrix.m[0][0] +
        m.m[3][1] * matrix.m[1][0] +
        m.m[3][2] * matrix.m[2][0]);
    matrix.m[3][1] = -(m.m[3][0] * matrix.m[0][1] +
        m.m[3][1] * matrix.m[1][1] +
        m.m[3][2] * matrix.m[2][1]);
    matrix.m[3][2] = -(m.m[3][0] * matrix.m[0][2] +
        m.m[3][1] * matrix.m[1][2] +
        m.m[3][2] * matrix.m[2][2]);
    matrix.m[3][3] = 1.0;
    return matrix;
  }

  Vec3D Vector_Add(Vec3D v1, Vec3D v2) {
    return Vec3D(v1.x + v2.x, v1.y + v2.y, v1.z + v2.z);
  }

  Vec3D Vector_Sub(Vec3D v1, Vec3D v2) {
    return Vec3D(v1.x - v2.x, v1.y - v2.y, v1.z - v2.z);
  }

  Vec3D Vector_Mul(Vec3D v1, double k) {
    return Vec3D(v1.x * k, v1.y * k, v1.z * k);
  }

  Vec3D Vector_Div(Vec3D v1, double k) {
    return Vec3D(v1.x / k, v1.y / k, v1.z / k);
  }

  double Vector_DotProduct(Vec3D v1, Vec3D v2) {
    return v1.x * v2.x + v1.y * v2.y + v1.z * v2.z;
  }

  double Vector_Length(Vec3D v) {
    return sqrt(Vector_DotProduct(v, v));
  }

  Vec3D Vector_Normalize(Vec3D v) {
    double l = Vector_Length(v);
    return Vec3D(v.x / l, v.y / l, v.z / l);
  }

  Vec3D Vector_CrossProduct(Vec3D v1, Vec3D v2) {
    Vec3D v = Vec3D(0, 0, 0);
    v.x = v1.y * v2.z - v1.z * v2.y;
    v.y = v1.z * v2.x - v1.x * v2.z;
    v.z = v1.x * v2.y - v1.y * v2.x;
    return v;
  }

  Color calculateColor(double lum) {
    Color baseColor = Color.fromARGB(255, 209, 255, 84);
    int range = 125;
    int scalenum = (125 * lum).round();

    // with material gradients
    int gradientnum = (lum.abs() * 9).round();
    List<Color> colors = [
      Colors.green.shade900,
      Colors.green.shade800,
      Colors.green.shade700,
      Colors.green.shade600,
      Colors.green.shade500,
      Colors.green.shade400,
      Colors.green.shade300,
      Colors.green.shade200,
      Colors.green.shade100,
      Colors.green.shade50,
    ];
    Color gradientColor = colors[gradientnum];
    Color newColor = Color.fromARGB(baseColor.alpha, baseColor.red - scalenum,
        baseColor.green - scalenum, baseColor.blue - scalenum);

    return gradientColor;
  }

  List<Triangle> project(Mesh mesh, double time, ControlPadInputs inputs) {
    // print(keyPress);

    // List<ProjectedTriangle> trisToDraw = [];
    List<Triangle> trisToRaster = [];

    if (inputs.forwardButton == 1) {
      print("Forward is pressed");
      // move up
      vCamera.y += 2.0;
    }

    if (inputs.backwardButton == 1) {
      print("Backward is pressed");
      // move down
      vCamera.y -= 2.0;
    }

    if (inputs.leftButton == 1) {
      // strafe left
      vCamera.x -= 2.0;
    }

    if (inputs.rightButton == 1) {
      // strafe right
      vCamera.x += 2.0;
    }

    // double theta = 0.0 * time;
    double theta = 0.0;

    Mat4x4 matRotZ = Matrix_MakeRotationZ(theta * 1.0);
    Mat4x4 matRotX = Matrix_MakeRotationX(theta * 0.5);
    Mat4x4 matRotY = Matrix_MakeRotationY(pi);

    Mat4x4 matTrans = Matrix_MakeTranslation(0.0, 0.0, zOffSet);

    Mat4x4 matWorld = Matrix_MakeIdentity();
    matWorld = Matrix_MultiplyMatrix(matRotZ, matRotX);
    matWorld = Matrix_MultiplyMatrix(matWorld, matRotY);
    matWorld = Matrix_MultiplyMatrix(matWorld, matTrans);

    Vec3D vUp = Vec3D(0, 1, 0);
    Vec3D vTarget = Vector_Add(vCamera, vLookDirection);

    Mat4x4 matCamera = Matrix_PointAt(vCamera, vTarget, vUp);

    Mat4x4 matView = Matrix_QuickInverse(matCamera);

    for (Triangle tri in mesh.tris) {
      // initialize Triangles to work with
      Triangle triToWorkWith = tri;
      Triangle triProjected = Triangle.empty();
      Triangle triTransformed = Triangle.empty();
      Triangle triViewed = Triangle.empty();

      triTransformed.arr[0] = Matrix_MultiplyVector(matWorld, tri.arr[0]);
      triTransformed.arr[1] = Matrix_MultiplyVector(matWorld, tri.arr[1]);
      triTransformed.arr[2] = Matrix_MultiplyVector(matWorld, tri.arr[2]);

      Vec3D line1 = Vector_Sub(triTransformed.arr[1], triTransformed.arr[0]);
      Vec3D line2 = Vector_Sub(triTransformed.arr[2], triTransformed.arr[0]);
      Vec3D normal = Vector_CrossProduct(line1, line2);
      normal = Vector_Normalize(normal);

      // The normal is used to check if the triangle is actually facing the
      // camera or not
      Vec3D vCameraRay = Vector_Sub(triTransformed.arr[0], vCamera);

      if (Vector_DotProduct(normal, vCameraRay) < 0.0) {
        // illumination
        Vec3D light_direction = Vec3D(0.0, 1.0, -1.0);

        double dp =
            min(max(0.1, Vector_DotProduct(light_direction, normal)), 1.0);

        Color col = calculateColor(dp);
        triTransformed.col = col;

        // Convert World space into view space
        triViewed.arr[0] =
            Matrix_MultiplyVector(matView, triTransformed.arr[0]);
        triViewed.arr[1] =
            Matrix_MultiplyVector(matView, triTransformed.arr[1]);
        triViewed.arr[2] =
            Matrix_MultiplyVector(matView, triTransformed.arr[2]);

        // Project the 3d-Triangles to a 2d space
        triProjected.arr[0] = Matrix_MultiplyVector(matProj, triViewed.arr[0]);
        triProjected.arr[1] = Matrix_MultiplyVector(matProj, triViewed.arr[1]);
        triProjected.arr[2] = Matrix_MultiplyVector(matProj, triViewed.arr[2]);
        triProjected.col = triTransformed.col;

        triProjected.arr[0] =
            Vector_Div(triProjected.arr[0], triProjected.arr[0].w);
        triProjected.arr[1] =
            Vector_Div(triProjected.arr[1], triProjected.arr[1].w);
        triProjected.arr[2] =
            Vector_Div(triProjected.arr[2], triProjected.arr[2].w);

        triProjected.arr[0].x *= -1.0;
        triProjected.arr[1].x *= -1.0;
        triProjected.arr[2].x *= -1.0;
        triProjected.arr[0].y *= -1.0;
        triProjected.arr[1].y *= -1.0;
        triProjected.arr[2].y *= -1.0;

        Vec3D vOffsetView = Vec3D(1, 1, 0);
        triProjected.arr[0] = Vector_Add(triProjected.arr[0], vOffsetView);
        triProjected.arr[1] = Vector_Add(triProjected.arr[1], vOffsetView);
        triProjected.arr[2] = Vector_Add(triProjected.arr[2], vOffsetView);

        // Scale into view
        triProjected.arr[0].x *= 0.5 * Globals.screenWidth.toDouble();
        triProjected.arr[0].y *= 0.5 * Globals.screenHeight.toDouble();
        triProjected.arr[1].x *= 0.5 * Globals.screenWidth.toDouble();
        triProjected.arr[1].y *= 0.5 * Globals.screenHeight.toDouble();
        triProjected.arr[2].x *= 0.5 * Globals.screenWidth.toDouble();
        triProjected.arr[2].y *= 0.5 * Globals.screenHeight.toDouble();
        triProjected.col = col;

        trisToRaster.add(triProjected);
      }
    }
    return trisToRaster;
  }
}

class Vec3D {
  double x;
  double y;
  double z;
  double w = 1;
  Vec3D(this.x, this.y, this.z);
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

// class ProjectedTriangle {
//   List<Offset> offsets = List<Offset>.filled(3, Offset(0.0, 0.0));
//   List<double> doubles = [];
//   Color color;
//   ProjectedTriangle(double x1, double y1, double x2, double y2, double x3,
//       double y3, this.color) {
//     offsets[0] = Offset(x1, y1);
//     offsets[1] = Offset(x2, y2);
//     offsets[2] = Offset(x3, y3);
//     doubles.add(x1);
//     doubles.add(y1);
//     doubles.add(x2);
//     doubles.add(y2);
//     doubles.add(x3);
//     doubles.add(y3);
//   }
// }

class TrisPainter extends CustomPainter {
  //         <-- CustomPainter class
  // final List<ProjectedTriangle> trisToDraw;
  final List<Triangle> trisToRaster;
  bool wireframing;
  TrisPainter(this.trisToRaster, {this.wireframing = true});
  // : super(repaint: DrawingController());
  @override
  void paint(Canvas canvas, Size size) {
    final wireframePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 0.2;

    trisToRaster.sort((t1, t2) {
      double z1 = (t1.arr[0].z + t1.arr[1].z + t1.arr[2].z) / 3.0;
      double z2 = (t2.arr[0].z + t2.arr[1].z + t2.arr[2].z) / 3.0;
      return z2.compareTo(z1);
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
      if (wireframing == true) {
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
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class DrawingController extends ChangeNotifier {
  void add() {
    notifyListeners();
  }
}
