import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:window_test/globals.dart';
import 'dart:math';

import 'package:window_test/widgets/controlPad.dart';

class Renderer {
  double zOffSet = 400;

  // Camera start and looking direction vectors
  Vec3D vCamera = Vec3D(0.0, 1.0, 0.0);
  Vec3D vLookDirection = Vec3D(0, 0, 1);

  // Initializing yaw and pitch angles for the camera. Starting at 0
  double yaw = 0;
  double pitch = 0;

  // Rotation multiplier, used for rotating objects around their origin axis
  double theta = 0.0;

  // Multiply a Matrix with a Vector
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
  }

  // Constructor for an identity matrix
  Mat4x4 Matrix_MakeIdentity() {
    Mat4x4 matrix = Mat4x4();
    matrix.m[0][0] = 1.0;
    matrix.m[1][1] = 1.0;
    matrix.m[2][2] = 1.0;
    matrix.m[3][3] = 1.0;
    return matrix;
  }

  // Constructor for a Rotation matrix over the X-Axis
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

  // Constructor for a Rotation matrix over the Y-Axis
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

  // Constructor for a Rotation matrix over the Z-Axis
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

  // Constructor for a Translation matrix to offset to x, y and z coordinates
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

  // The projection matrix, used to convert from 3D to 2D space
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

  // Multiply a matrix with another matrix
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

  // Add a matrix to another matrix
  Mat4x4 Matrix_AddMatrix(Mat4x4 m1, Mat4x4 m2) {
    Mat4x4 matrix = Mat4x4();
    for (int c = 0; c < 4; c++) {
      for (int r = 0; r < 4; r++) {
        matrix.m[r][c] = m1.m[r][c] * m2.m[r][c];
      }
    }
    return matrix;
  }

  Mat4x4 Matrix_PointAt(Vec3D pos, Vec3D target, Vec3D up) {
    // Calculate the new forward direction using our current position and a vector that points to our target
    Vec3D newForward = Vector_Sub(target, pos);
    newForward = Vector_Normalize(newForward);

    // Calculate the new up direction, as we can also pitch
    Vec3D a = Vector_Mul(newForward, Vector_DotProduct(up, newForward));
    Vec3D newUp = Vector_Sub(up, a);
    newUp = Vector_Normalize(newUp);

    // New right is the cross product of the two other matrices
    Vec3D newRight = Vector_CrossProduct(newUp, newForward);

    // The final Dimensioning and Translation matrix
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

  Vec3D Vector_IntersectPlane(
      Vec3D plane_p, Vec3D plane_n, Vec3D lineStart, Vec3D lineEnd) {
    plane_n = Vector_Normalize(plane_n);
    double plane_d = -(Vector_DotProduct(plane_n, plane_p));
    double ad = Vector_DotProduct(lineStart, plane_n);
    double bd = Vector_DotProduct(lineEnd, plane_n);
    double t = (-1 * plane_d - ad) / (bd - ad);
    Vec3D lineStartToEnd = Vector_Sub(lineEnd, lineStart);
    Vec3D lineToIntersect = Vector_Mul(lineStartToEnd, t);
    return Vector_Add(lineStart, lineToIntersect);
  }

  List<Triangle> Triangle_ClipAgainstPlane(Vec3D plane_p, Vec3D plane_n,
      Triangle in_tri, Triangle out_tri1, Triangle out_tri2) {
    // Make sure plane is normal
    plane_n = Vector_Normalize(plane_n);

    // Returns the shortest distance from a point to a plane.
    dist(Vec3D p) {
      Vec3D n = Vector_Normalize(p);
      return (plane_n.x * p.x +
          plane_n.y * p.y +
          plane_n.z * p.z -
          Vector_DotProduct(plane_n, plane_p));
    }

    // Temporary storage for inside and outside points.
    List<Vec3D> inside_points = List<Vec3D>.filled(3, Vec3D(0, 0, 0));
    int nInsidePointCount = 0;
    List<Vec3D> outside_points = List<Vec3D>.filled(3, Vec3D(0, 0, 0));
    int nOutsidePointCount = 0;

    // get the distance of each point to the near plane
    double d0 = dist(in_tri.arr[0]);
    double d1 = dist(in_tri.arr[1]);
    double d2 = dist(in_tri.arr[2]);

    if (d0 >= 0) {
      inside_points[nInsidePointCount++] = in_tri.arr[0];
    } else {
      outside_points[nOutsidePointCount++] = in_tri.arr[0];
    }
    if (d1 >= 0) {
      inside_points[nInsidePointCount++] = in_tri.arr[1];
    } else {
      outside_points[nOutsidePointCount++] = in_tri.arr[1];
    }
    if (d2 >= 0) {
      inside_points[nInsidePointCount++] = in_tri.arr[2];
    } else {
      outside_points[nOutsidePointCount++] = in_tri.arr[2];
    }

    // Break the input triangles up into smaller triangles.
    // Four possible outcomes; the Triangle has all points outside of the view plane:
    // No triangles will be rendered at all,
    // The triangle has all points in the view plane: Nothing will be clipped
    // The triangle has one point in the view plane: The triangle needs to be cut off
    // The triangle has two points in the view plane: Make a quad and triangulate.
    if (nInsidePointCount == 0) {
      return [];
    }

    if (nInsidePointCount == 3) {
      out_tri1 = in_tri;
      return [out_tri1];
    }

    if (nInsidePointCount == 1 && nOutsidePointCount == 2) {
      // copy original colour
      out_tri1.col = in_tri.col;

      // Tri uses the inside point and the two intersect points as new
      // points
      out_tri1.arr[2] = inside_points[0];
      out_tri1.arr[1] = Vector_IntersectPlane(
          plane_p, plane_n, inside_points[0], outside_points[0]);
      out_tri1.arr[0] = Vector_IntersectPlane(
          plane_p, plane_n, inside_points[0], outside_points[1]);

      return [out_tri1];
    }

    if (nInsidePointCount == 2 && nOutsidePointCount == 1) {
      // Copy original colour
      out_tri1.col = in_tri.col;
      out_tri2.col = in_tri.col;

      // The first Triangle uses the two inside points and the intersect of the plane with a line to an outside point.
      out_tri1.arr[0] = inside_points[0];
      out_tri1.arr[1] = inside_points[1];
      out_tri1.arr[2] = Vector_IntersectPlane(
          plane_p, plane_n, inside_points[0], outside_points[0]);

      // The second triangle uses the second inside point, the clipped point from above
      // and the intersect of the other line.
      out_tri2.arr[0] = inside_points[1];
      out_tri2.arr[1] = out_tri1.arr[2];
      out_tri2.arr[2] = Vector_IntersectPlane(
          plane_p, plane_n, inside_points[1], outside_points[0]);

      return [out_tri2, out_tri1];
    }
    return [];
  }

  Color calculateColor(double lum) {
    // // Tried my hand at using a smoother scale.
    //
    // Color baseColor = Color.fromARGB(255, 209, 255, 84);
    // int range = 125;
    // int scalenum = (125 * lum).round();
    // Color newColor = Color.fromARGB(baseColor.alpha, baseColor.red - scalenum,
    //     baseColor.green - scalenum, baseColor.blue - scalenum);

    // With material gradients, this means we only have a small amount of colours.
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

    return gradientColor;
  }

  List<Triangle> project(Mesh mesh, double time, ControlPadInputs inputs,
      {required double width, required double height}) {
    // Initialize the Projection Matrix. This does not change, so I want to move this out of this function.
    Mat4x4 matProj =
        Renderer.Matrix_MakeProjection(90, (height) / width, 0.1, 1000);

    // Save all tris to a list, to sort and clip them later
    List<Triangle> trisToRaster = [];

    // Calculate new forward vector based on the time since last frame render.
    // Basically normalising the speed to disconnect from FPS
    Vec3D vForward = Vector_Mul(vLookDirection, Globals.speed * time);

    if (inputs.moveUpwardButton == 1) {
      // move up
      vCamera.y += Globals.speed * time;
    }

    if (inputs.moveDownwardButton == 1) {
      // move down
      vCamera.y -= Globals.speed * time;
    }

    if (inputs.strafeLeftButton == 1) {
      // strafe left
      // As we only need to move across the X-Z plane we set Y to zero.
      vCamera = Vector_Add(vCamera, Vec3D(vForward.z, 0, -vForward.x));
    }

    if (inputs.strafeRightButton == 1) {
      // strafe right
      // As we only need to move across the X-Z plane we set Y to zero.
      vCamera = Vector_Sub(vCamera, Vec3D(vForward.z, 0, -vForward.x));
    }

    if (inputs.moveForwardButton == 1) {
      vCamera = Vector_Add(vCamera, vForward);
    }

    if (inputs.moveBackwardButton == 1) {
      vCamera = Vector_Sub(vCamera, vForward);
    }
    if (inputs.turnLeftButton == 1) {
      yaw -= 0.8 * time;
    }

    if (inputs.turnRightButton == 1) {
      yaw += 0.8 * time;
    }

    if (inputs.turnUpButton == 1) {
      pitch -= 0.8 * time;
    }

    if (inputs.turnDownButton == 1) {
      pitch += 0.8 * time;
    }

    // Theta will also be normalized by the time
    theta += 0.5 * time;

    // Setting up the rotation matrices for rotating an object around their origin.
    // Normalized with the Theta and given weights in the form of a double.
    Mat4x4 matRotZ = Matrix_MakeRotationZ(theta * 0.0);
    Mat4x4 matRotX = Matrix_MakeRotationX(theta * 0.0);
    Mat4x4 matRotY = Matrix_MakeRotationY(theta * 0.0);

    // Translating the object to fit in the initial view of the camera.
    Mat4x4 matTrans = Matrix_MakeTranslation(0.0, 2.0, zOffSet);

    // Set up the total world translation matrix
    Mat4x4 matWorld = Matrix_MakeIdentity();
    matWorld = Matrix_MultiplyMatrix(matRotZ, matRotX);
    matWorld = Matrix_MultiplyMatrix(matWorld, matRotY);
    matWorld = Matrix_MultiplyMatrix(matWorld, matTrans);

    // up is always up
    Vec3D vUp = Vec3D(0, 1, 0);
    Vec3D vTarget = Vec3D(0, 0, 1);

    // First we rotate in X axis, then we rotate in Y axis.
    Mat4x4 matCameraRot = Matrix_MultiplyMatrix(
        Matrix_MakeRotationX(pitch), Matrix_MakeRotationY(yaw));

    // Calculate new look
    vLookDirection = Matrix_MultiplyVector(matCameraRot, vTarget);
    vTarget = Vector_Add(vCamera, vLookDirection);

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
        Vec3D light_direction = Vec3D(0.4, 1, -0.2);

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

        // Clip viewed Triangle against near plane, this could form two more triangles
        // int nClippedTriangles = 0;
        //  = List<Triangle>.filled(2, Triangle.empty());
        List<Triangle> clipped = Triangle_ClipAgainstPlane(Vec3D(0, 0, 0.1),
            Vec3D(0, 0, 1), triViewed, Triangle.empty(), Triangle.empty());

        for (int n = 0; n < clipped.length; n++) {
          // Project the 3d-Triangles to a 2d space
          triProjected.arr[0] =
              Matrix_MultiplyVector(matProj, clipped[n].arr[0]);
          triProjected.arr[1] =
              Matrix_MultiplyVector(matProj, clipped[n].arr[1]);
          triProjected.arr[2] =
              Matrix_MultiplyVector(matProj, clipped[n].arr[2]);
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
          triProjected.arr[0].x *= 0.5 * width;
          triProjected.arr[0].y *= 0.5 * height;
          triProjected.arr[1].x *= 0.5 * width;
          triProjected.arr[1].y *= 0.5 * height;
          triProjected.arr[2].x *= 0.5 * width;
          triProjected.arr[2].y *= 0.5 * height;
          triProjected.col = col;

          Triangle triToSave =
              Triangle.from(triProjected, col: triProjected.col);

          trisToRaster.add(triToSave);
        }
      }
    }

    trisToRaster.sort((t1, t2) {
      double z1 = (t1.arr[0].z + t1.arr[1].z + t1.arr[2].z) / 3.0;
      double z2 = (t2.arr[0].z + t2.arr[1].z + t2.arr[2].z) / 3.0;
      return z2.compareTo(z1);
    });

    List<Triangle> finalTris = [];

    for (Triangle triToRaster in trisToRaster) {
      List<Triangle> clipped = List<Triangle>.filled(2, Triangle.empty());
      List<Triangle> listTriangles = [];
      listTriangles.add(triToRaster);
      int nNewTriangles = 1;

      for (int p = 0; p < 4; p++) {
        int nTrisToAdd = 0;
        while (nNewTriangles > 0) {
          Triangle test = listTriangles.first;
          listTriangles.removeAt(0);
          nNewTriangles--;

          switch (p) {
            case 0:
              List<Triangle> l = Triangle_ClipAgainstPlane(Vec3D(0, 0, 0),
                  Vec3D(0, 1, 0), test, Triangle.empty(), Triangle.empty());
              nTrisToAdd = l.length;
              for (int w = 0; w < nTrisToAdd; w++) {
                listTriangles.add(l[w]);
              }
              break;
            case 1:
              List<Triangle> l = Triangle_ClipAgainstPlane(
                  Vec3D(0, height - 1, 0),
                  Vec3D(0, -1, 0),
                  test,
                  Triangle.empty(),
                  Triangle.empty());
              nTrisToAdd = l.length;
              for (int w = 0; w < nTrisToAdd; w++) {
                listTriangles.add(l[w]);
              }
              break;

            case 2:
              List<Triangle> l = Triangle_ClipAgainstPlane(Vec3D(0, 0, 0),
                  Vec3D(1, 0, 0), test, Triangle.empty(), Triangle.empty());
              nTrisToAdd = l.length;
              for (int w = 0; w < nTrisToAdd; w++) {
                listTriangles.add(l[w]);
              }
              break;

            case 3:
              List<Triangle> l = Triangle_ClipAgainstPlane(
                  Vec3D(width - 1, 0, 0),
                  Vec3D(-1, 0, 0),
                  test,
                  Triangle.empty(),
                  Triangle.empty());
              nTrisToAdd = l.length;
              for (int w = 0; w < nTrisToAdd; w++) {
                listTriangles.add(l[w]);
              }
              break;
            default:
          }
        }
        nNewTriangles = listTriangles.length;
      }
      for (Triangle tri in listTriangles) {
        finalTris.add(tri);
      }
    }
    if (kDebugMode) {
      print("Rendering ${finalTris.length.toString()} tri's");
    }

    return finalTris;
  }
}

class Vec3D {
  double x;
  double y;
  double z;
  double w = 1;
  Vec3D(this.x, this.y, this.z);

  @override
  String toString() {
    String s = "($x, $y, $z)";
    return s;
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
  TrisPainter(
    this.trisToRaster, {
    this.wireframing = true,
  });
  // : super(repaint: DrawingController());
  @override
  void paint(Canvas canvas, Size size) {
    final wireframePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 0.2;

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
