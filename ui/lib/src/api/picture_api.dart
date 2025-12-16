import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'api_client.dart';

class PictureApi {
  // reference to BaseClient object
  final ApiClient _client = ApiClient();

  final String postUrl = '/post_pp';
  final String getUrl = '/get_pp';

  Future<Uint8List?> get_picture() async {
    final response = await _client.get(getUrl);

    if (response.statusCode == 200) {
      Uint8List imageData = base64.decode(response.body);
      return imageData;
    } else {
      throw Exception('Failed to load picture');
    }
  }

  Future<bool> post_picture(String filename, XFile image) async {
    try {
      Map<String, dynamic> jsonBody = {
        'filename': '$filename.jpg',
        'content_type': 'image/jpeg',
        'base64_data': base64Encode(await image.readAsBytes()),
      };

      final response = await _client.post(postUrl, jsonBody);
      if (response.statusCode == 200) {
        //Register Successfull
        final Map<String, dynamic> responseBody = json.decode(response.body);
        // Todo: add additional checks
        //if (responseBody.containsKey('something')) {
        //}
        return true;
      } else if (response.statusCode == 422) {
        //Register Unsucessfull
        return false;
      }
    } catch (e) {}
    return false;
  }
}
