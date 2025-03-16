import 'package:mobile_client_flutter/services/api_client.dart';

class PreferencesService {
  final ApiClient _apiClient;

  PreferencesService(this._apiClient);

  Future<Map<String, dynamic>> getPreferences() async {
    return await _apiClient.get('/preferences');
  }

  Future<void> saveLifestylePreferences({
    required int cleanlinessLevel,
    required double noiseTolerance,
    required String studyHabits,
    required String socialLevel,
    required String wakeUpTime,
    required String sleepTime,
  }) async {
    await _apiClient.post('/preferences/lifestyle', {
      'cleanliness_level': cleanlinessLevel,
      'noise_tolerance': noiseTolerance,
      'study_habits': studyHabits,
      'social_level': socialLevel,
      'wake_up_time': wakeUpTime,
      'sleep_time': sleepTime,
    });
  }

  Future<void> saveLocationPreferences({
    required String preferredArea,
    required double maxDistance,
    required double budget,
    required bool hasTransport,
  }) async {
    await _apiClient.post('/preferences/location', {
      'preferred_area': preferredArea,
      'max_distance': maxDistance,
      'budget': budget,
      'has_transport': hasTransport,
    });
  }

  Future<Map<String, dynamic>> updatePreferences({
    required Map<String, dynamic> preferences,
  }) async {
    final response = await _apiClient.post('/preferences/update', preferences);
    return {
      'matches': response['potential_matches'],
      'matchDetails': response['match_details'],
    };
  }
}