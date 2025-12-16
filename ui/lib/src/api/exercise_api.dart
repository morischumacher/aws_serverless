import 'package:aic_ui/src/exercise/exercise.dart';
import 'dart:convert';
import 'api_client.dart';

class ExerciseApi {
  // reference to BaseClient object
  final ApiClient _client = ApiClient();

  final String postUrl = '/post_solution';
  final String getUrl = '/get_exercise';

  Future<Exercise?> get_exercise() async {
    final response = await _client.get(getUrl);

    if (response.statusCode == 200) {
      print(response.body);

      return Exercise.fromJson(json.decode(response.body));
    } else if (response.statusCode != 200) {
      throw Exception(
          'HTTP request failed, statusCode: ${response.statusCode}');
    } else if (response.body.isEmpty) {
      throw Exception('HTTP request failed, body is empty');
    } else {
      throw Exception('HTTP request failed, unknown error');
    }
  }

  Future<bool> post_solution(BaseExercise exercise) async {
    try {
      Map<String, dynamic> jsonBody = exercise.toJson();

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
