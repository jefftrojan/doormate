import 'package:mobile_client_flutter/services/api_client.dart';

class PreferencesService {
  final ApiClient _apiClient;
  
  PreferencesService(this._apiClient);
  
  Future<Map<String, dynamic>> getPreferences() async {
    try {
      final response = await _apiClient.get('/preferences');
      print('Preferences response: $response');
      return response;
    } catch (e) {
      print('Error getting preferences: $e');
      rethrow;
    }
  }
  
  Future<void> saveLifestylePreferences({
    required int cleanlinessLevel,
    required double noiseTolerance,
    required String studyHabits,
    required String socialLevel,
    required String wakeUpTime,
    required String sleepTime,
  }) async {
    try {
      // Convert noise tolerance to 0-100 scale as expected by backend
      final noisePercentage = (noiseTolerance / 10) * 100;
      
      final requestBody = {
        'cleanliness': cleanlinessLevel,
        'noiseLevel': noisePercentage,
        'studyHabits': studyHabits,
        'socialLevel': socialLevel,
        'wakeUpTime': wakeUpTime,
        'sleepTime': sleepTime,
      };
      
      print('Sending lifestyle preferences: $requestBody');
      await _apiClient.post('/preferences/lifestyle', requestBody);
    } catch (e) {
      print('Error saving lifestyle preferences: $e');
      rethrow;
    }
  }
  
  Future<void> saveLocationPreferences({
    required String preferredArea,
    required double maxDistance,
    required double budget,
    required bool hasTransport,
  }) async {
    try {
      final requestBody = {
        'preferredArea': preferredArea,
        'maxDistance': maxDistance,
        'budget': budget,
        'hasTransportation': hasTransport,
      };
      
      print('Sending location preferences: $requestBody');
      await _apiClient.post('/preferences/location', requestBody);
    } catch (e) {
      print('Error saving location preferences: $e');
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>> updateAllPreferences({
    required Map<String, dynamic> lifestyle,
    required Map<String, dynamic> location,
  }) async {
    try {
      final requestBody = {
        'lifestyle': lifestyle,
        'location': location,
      };
      
      print('Sending all preferences: $requestBody');
      final response = await _apiClient.post('/preferences', requestBody);
      return response;
    } catch (e) {
      print('Error updating all preferences: $e');
      rethrow;
    }
  }
}