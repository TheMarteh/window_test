import 'dart:convert';
import 'dart:html';


import 'package:window_test/Logic/Renderer.dart';

class ObjConverter {
  late String fileName;
  ObjConverter(this.fileName);

  void getMesh() async {
    List<Triangle> tris = [];
    var request = await HttpRequest.request(fileName);
    String response = request.response;
    List<String> lines = response.split("\n");
    for (String line in lines) {
      // Triangle tri = Triangle(p1, p2, p3)
      print(line);
    }

    return;

    // Mesh mesh = Mesh(tris);
    // return Mesh mesh;
  }
}
