import 'package:flutter/foundation.dart';
import 'package:mobile_client_flutter/services/preferences_service.dart';

class PreferencesProvider extends ChangeNotifier {
  final PreferencesService _preferencesService;
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _preferences;

  PreferencesProvider(this._preferencesService);

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get preferences => _preferences;

  Future<void> loadPreferences() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _preferences = await _preferencesService.getPreferences();
      
    } catch (e) {
      _error = e.toString();
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

      await loadPreferences();
    } catch (e) {
      _error = e.toString();
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

      await loadPreferences();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}