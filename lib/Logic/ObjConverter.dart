import 'dart:convert';
import 'dart:io';

import 'package:window_test/Logic/Renderer.dart';

class ObjConverter {
  late String fileName;
  ObjConverter(this.fileName);

  void getMesh() {
    List<Triangle> tris = [];
    List<String> lines = File(fileName).readAsLinesSync();
    for (String line in lines) {
      // Triangle tri = Triangle(p1, p2, p3)
      print(line);
    }

    return;

    // Mesh mesh = Mesh(tris);
    // return Mesh mesh;
  }
}
