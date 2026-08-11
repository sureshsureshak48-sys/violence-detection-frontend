import 'package:http/http.dart' as http;
import 'api_service.dart';

class MediaApi {
  Future<String> uploadImage(String filePath) async {
    return _upload(filePath);
  }


  Future<String> uploadVideo(String filePath) async {
    return _upload(filePath);
  }

  Future<String> _upload(String filePath) async {

    var request = http.MultipartRequest(
      "POST",
      Uri.parse(ApiService.upload),
    );

    request.files.add(
      await http.MultipartFile.fromPath(
        "file",
        filePath,
      ),
    );

    var response = await request.send();

    String result =
    await response.stream.bytesToString();

    print("UPLOAD RESULT: $result");

    return result;
  }

  Future<String> uploadAudio(String filePath) async {
    var request = http.MultipartRequest(
      "POST",
      Uri.parse(ApiService.detectAudio),
    );

    request.files.add(
      await http.MultipartFile.fromPath("file", filePath),
    );

    var response = await request.send();
    String result = await response.stream.bytesToString();

    print("AUDIO RESULT: $result");
    return result;
  }

}