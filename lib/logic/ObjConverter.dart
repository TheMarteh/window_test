import 'package:flutter/services.dart';
import 'package:window_test/logic/Renderer.dart';

class ObjConverter {
  late String fileName;
  ObjConverter(this.fileName);

  Future<Mesh> getMesh() async {
    List<Triangle> tris = [];
    List<Vec3D> vertices = [];
    String fileAsString = "";
    String file = await loadFile();
    List<String> lines = file.split("\n");

    // var request = await html.HttpRequest.getString("lib\\assets\\teapot.obj")
    //     .then((String value) => fileAsString);
    // List<String> lines = request.split("\n");

    for (String line in lines) {
      // print(line);
      try {
        if (line[0] == "v") {
          List<String> splitted = line.split(" ");
          Vec3D v = Vec3D(double.parse(splitted[1]), double.parse(splitted[2]),
              double.parse(splitted[3]));
          vertices.add(v);
        }
        if (line[0] == "f") {
          List<String> splitted = line.split(" ");
          List<int> p = [
            int.parse(splitted[1].split("/")[0]),
            int.parse(splitted[2].split("/")[0]),
            int.parse(splitted[3].split("/")[0])
          ];
          tris.add(Triangle(
              vertices[p[0] - 1], vertices[p[1] - 1], vertices[p[2] - 1]));
        }
      } catch (e) {
        print(e);
      }

      // Triangle tri = Triangle(p1, p2, p3)
      // print("Test" + line);
    }

    // return;

    Mesh mesh = Mesh(tris);
    print("obj should be converted");
    return mesh;
  }

  Future<String> loadFile() async {
    Future<String> file = rootBundle.loadString(fileName);
    return file;
  }
}
