import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:developer' as developer;

class MapWebInitializer {
  static bool isInitialized = false;
  
  static void ensureInitialized() {
    if (kIsWeb && !isInitialized) {
      developer.log('Ensuring Google Maps is initialized for web', name: 'MAP_INIT');
      // Additional initialization logic if needed
      isInitialized = true;
    }
  }
}