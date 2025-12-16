import 'package:aic_ui/src/exercise/exercise.dart';
import 'dart:convert';
import 'api_client.dart';

class ProfileApi {
  // reference to BaseClient object
  final ApiClient _client = ApiClient();

  final String getUrl = '/get_profile';

  Future<Exercises> get_profile() async {
    final response = await _client.get(getUrl);

    if (response.statusCode == 200) {
      return Exercises.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load exercises');
    }
  }
}
