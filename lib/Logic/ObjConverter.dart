import 'package:universal_io/io.dart';
import 'package:window_test/logic/renderer.dart';

class ObjConverter {
  late String fileName;
  ObjConverter(this.fileName);

  void getMesh() async {
    List<Triangle> tris = [];
    String fileAsString = "";
    List<String> lines = File(fileName).readAsLinesSync();
    // var request = await html.HttpRequest.getString("lib\\assets\\teapot.obj")
    //     .then((String value) => fileAsString);
    // List<String> lines = request.split("\n");

    for (String line in lines) {
      // Triangle tri = Triangle(p1, p2, p3)
      print("Test" + line);
    }

    return;

    // Mesh mesh = Mesh(tris);
    // return Mesh mesh;
  }
}
