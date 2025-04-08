import 'package:flutter/foundation.dart';
import 'package:mobile_client_flutter/services/preferences_service.dart';

class PreferencesProvider extends ChangeNotifier {
  final PreferencesService _preferencesService;
  
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _preferences;
  Map<String, dynamic>? _lifestylePreferences;
  Map<String, dynamic>? _locationPreferences;
  
  PreferencesProvider(this._preferencesService);
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get preferences => _preferences;
  Map<String, dynamic>? get lifestylePreferences => _lifestylePreferences;
  Map<String, dynamic>? get locationPreferences => _locationPreferences;
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  Future<void> loadPreferences() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final response = await _preferencesService.getPreferences();
      _preferences = response;
      
      // Extract lifestyle and location preferences if they exist
      if (response.containsKey('lifestyle')) {
        _lifestylePreferences = response['lifestyle'];
      }
      
      if (response.containsKey('location')) {
        _locationPreferences = response['location'];
      }
      
    } catch (e) {
      print('Error in loadPreferences: $e');
      _error = 'Failed to load preferences: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
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
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await _preferencesService.saveLifestylePreferences(
        cleanlinessLevel: cleanlinessLevel,
        noiseTolerance: noiseTolerance,
        studyHabits: studyHabits,
        socialLevel: socialLevel,
        wakeUpTime: wakeUpTime,
        sleepTime: sleepTime,
      );
      
      // Update local state
      _lifestylePreferences = {
        'cleanliness': cleanlinessLevel,
        'noiseLevel': (noiseTolerance / 10) * 100,
        'studyHabits': studyHabits,
        'socialLevel': socialLevel,
        'wakeUpTime': wakeUpTime,
        'sleepTime': sleepTime,
      };
      
      // Refresh entire preferences object
      await loadPreferences();
      
    } catch (e) {
      print('Error in saveLifestylePreferences: $e');
      _error = 'Failed to save lifestyle preferences: ${e.toString()}';
      notifyListeners();
    }
  }
  
  Future<void> saveLocationPreferences({
    required String preferredArea,
    required double maxDistance,
    required double budget,
    required bool hasTransport,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await _preferencesService.saveLocationPreferences(
        preferredArea: preferredArea,
        maxDistance: maxDistance,
        budget: budget,
        hasTransport: hasTransport,
      );
      
      // Update local state
      _locationPreferences = {
        'preferredArea': preferredArea,
        'maxDistance': maxDistance,
        'budget': budget,
        'hasTransportation': hasTransport,
      };
      
      // Refresh entire preferences object
      await loadPreferences();
      
    } catch (e) {
      print('Error in saveLocationPreferences: $e');
      _error = 'Failed to save location preferences: ${e.toString()}';
      notifyListeners();
    }
  }
  
  Future<void> saveAllPreferences({
    required int cleanlinessLevel,
    required double noiseTolerance,
    required String studyHabits,
    required String socialLevel,
    required String wakeUpTime,
    required String sleepTime,
    required String preferredArea,
    required double maxDistance,
    required double budget,
    required bool hasTransport,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      // Create the lifestyle preferences map
      final lifestyle = {
        'cleanliness': cleanlinessLevel,
        'noiseLevel': (noiseTolerance / 10) * 100,
        'studyHabits': studyHabits,
        'socialLevel': socialLevel,
        'wakeUpTime': wakeUpTime,
        'sleepTime': sleepTime,
      };
      
      // Create the location preferences map
      final location = {
        'preferredArea': preferredArea,
        'maxDistance': maxDistance,
        'budget': budget,
        'hasTransportation': hasTransport,
      };
      
      // Update both at once
      await _preferencesService.updateAllPreferences(
        lifestyle: lifestyle,
        location: location,
      );
      
      // Update local state
      _lifestylePreferences = lifestyle;
      _locationPreferences = location;
      
      // Refresh entire preferences object
      await loadPreferences();
      
    } catch (e) {
      print('Error in saveAllPreferences: $e');
      _error = 'Failed to save preferences: ${e.toString()}';
      notifyListeners();
    }
  }
}