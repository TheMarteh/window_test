import 'package:window_test/logic/renderer.dart';

class Cube {
  Mesh MeshCube = Mesh([
    // South
    Triangle(Vec3D(0.0, 0.0, 0.0), Vec3D(0.0, 1.0, 0.0), Vec3D(1.0, 1.0, 0.0)),
    Triangle(Vec3D(0.0, 0.0, 0.0), Vec3D(1.0, 1.0, 0.0), Vec3D(1.0, 0.0, 0.0)),

    // EAST
    Triangle(Vec3D(1.0, 0.0, 0.0), Vec3D(1.0, 1.0, 0.0), Vec3D(1.0, 1.0, 1.0)),
    Triangle(Vec3D(1.0, 0.0, 0.0), Vec3D(1.0, 1.0, 1.0), Vec3D(1.0, 0.0, 1.0)),

    // NORTH
    Triangle(Vec3D(1.0, 0.0, 1.0), Vec3D(1.0, 1.0, 1.0), Vec3D(1.0, 1.0, 1.0)),
    Triangle(Vec3D(1.0, 0.0, 1.0), Vec3D(0.0, 1.0, 1.0), Vec3D(0.0, 0.0, 1.0)),

    // WEST
    Triangle(Vec3D(0.0, 0.0, 1.0), Vec3D(0.0, 1.0, 1.0), Vec3D(0.0, 1.0, 0.0)),
    Triangle(Vec3D(0.0, 0.0, 1.0), Vec3D(0.0, 1.0, 0.0), Vec3D(0.0, 0.0, 0.0)),

    // TOP
    Triangle(Vec3D(0.0, 1.0, 0.0), Vec3D(0.0, 1.0, 1.0), Vec3D(1.0, 1.0, 1.0)),
    Triangle(Vec3D(0.0, 1.0, 0.0), Vec3D(1.0, 1.0, 1.0), Vec3D(1.0, 1.0, 0.0)),

    // BOTTOM
    Triangle(Vec3D(1.0, 0.0, 1.0), Vec3D(0.0, 0.0, 1.0), Vec3D(0.0, 0.0, 0.0)),
    Triangle(Vec3D(1.0, 0.0, 1.0), Vec3D(0.0, 0.0, 0.0), Vec3D(1.0, 0.0, 0.0)),
  ]);
}
