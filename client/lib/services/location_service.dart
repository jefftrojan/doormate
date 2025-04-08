// import 'dart:convert';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:http/http.dart' as http;
// import 'dart:developer' as developer;

// class LocationService {
//   static const String _apiKey = 'AIzaSyAOtmq-salDTmnYklFtF7jqHdW-RI16u-k'; // Same key from your index.html
  
//   // Fallback coordinates for common locations in Rwanda
//   static final Map<String, LatLng> _fallbackCoordinates = {
//     'kigali': LatLng(-1.9441, 30.0619),
//     'nyarugenge': LatLng(-1.9437, 30.0594),
//     'kacyiru': LatLng(-1.9367, 30.0921),
//     'kimihurura': LatLng(-1.9500, 30.0861),
//     'gacuriro': LatLng(-1.9183, 30.0936),
//     'gisozi': LatLng(-1.9211, 30.0589),
//     'remera': LatLng(-1.9558, 30.1119),
//     'kibagabaga': LatLng(-1.9310, 30.1182),
//     'kicukiro': LatLng(-1.9766, 30.0878),
//     'nyamirambo': LatLng(-1.9765, 30.0383),
//     'rwanda': LatLng(-1.9403, 29.8739), // Country center
//   };
  
//   // Geocode address to coordinates using Google Maps Geocoding API
//   static Future<LatLng?> geocodeAddress(String address) async {
//     try {
//       final String regionBias = 'rw'; // Rwanda country code
//       final String fullAddress = '$address, Rwanda'; // Append country
      
//       final Uri uri = Uri.https(
//         'maps.googleapis.com',
//         '/maps/api/geocode/json',
//         {
//           'address': fullAddress,
//           'key': _apiKey,
//           'region': regionBias,
//         },
//       );

//       developer.log('Sending geocoding request for: $address', name: 'LOCATION');
//       final response = await http.get(uri);
      
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
        
//         if (data['status'] == 'OK' && data['results'].isNotEmpty) {
//           final location = data['results'][0]['geometry']['location'];
//           developer.log('Geocoded $address to lat: ${location['lat']}, lng: ${location['lng']}', name: 'LOCATION');
//           return LatLng(location['lat'], location['lng']);
//         } else {
//           developer.log('Geocoding failed for $address: ${data['status']}', name: 'LOCATION');
//           // Try fallback method
//           return _getFallbackCoordinates(address);
//         }
//       } else {
//         developer.log('Geocoding request failed with status ${response.statusCode}', name: 'LOCATION');
//         return _getFallbackCoordinates(address);
//       }
//     } catch (e) {
//       developer.log('Geocoding error: $e', name: 'LOCATION');
//       return _getFallbackCoordinates(address);
//     }
//   }

  
  
//   // Fallback method to get coordinates from predefined map
//   static LatLng? _getFallbackCoordinates(String address) {
//     final String normalizedAddress = address.toLowerCase();
    
//     for (var entry in _fallbackCoordinates.entries) {
//       if (normalizedAddress.contains(entry.key)) {
//         developer.log('Using fallback coordinates for $address: ${entry.key}', name: 'LOCATION');
//         return entry.value;
//       }
//     }
    
//     // Default to Kigali city center if no match found
//     developer.log('No fallback coordinates found for $address, using Kigali', name: 'LOCATION');
//     return _fallbackCoordinates['kigali'];
//   }
// }

import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

class LocationService {
  static const String _apiKey = 'AIzaSyAOtmq-salDTmnYklFtF7jqHdW-RI16u-k'; // Same key from your index.html
  
  // Fallback coordinates for common locations in Rwanda
  static final Map<String, LatLng> _fallbackCoordinates = {
    'kigali': LatLng(-1.9441, 30.0619),
    'nyarugenge': LatLng(-1.9437, 30.0594),
    'kacyiru': LatLng(-1.9367, 30.0921),
    'kimihurura': LatLng(-1.9500, 30.0861),
    'gacuriro': LatLng(-1.9183, 30.0936),
    'gisozi': LatLng(-1.9211, 30.0589),
    'remera': LatLng(-1.9558, 30.1119),
    'kibagabaga': LatLng(-1.9310, 30.1182),
    'kicukiro': LatLng(-1.9766, 30.0878),
    'nyamirambo': LatLng(-1.9765, 30.0383),
    'rwanda': LatLng(-1.9403, 29.8739), // Country center
  };
  
  // Geocode address to coordinates using Google Maps Geocoding API
  static Future<LatLng?> geocodeAddress(String address) async {
    try {
      final String regionBias = 'rw'; // Rwanda country code
      final String fullAddress = '$address, Rwanda'; // Append country
      
      final Uri uri = Uri.https(
        'maps.googleapis.com',
        '/maps/api/geocode/json',
        {
          'address': fullAddress,
          'key': _apiKey,
          'region': regionBias,
        },
      );
      
      developer.log('Sending geocoding request for: $address', name: 'LOCATION');
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final location = data['results'][0]['geometry']['location'];
          developer.log('Geocoded $address to lat: ${location['lat']}, lng: ${location['lng']}', name: 'LOCATION');
          return LatLng(location['lat'], location['lng']);
        } else {
          developer.log('Geocoding failed for $address: ${data['status']}', name: 'LOCATION');
          // Try fallback method
          return _getFallbackCoordinates(address);
        }
      } else {
        developer.log('Geocoding request failed with status ${response.statusCode}', name: 'LOCATION');
        return _getFallbackCoordinates(address);
      }
    } catch (e) {
      developer.log('Geocoding error: $e', name: 'LOCATION');
      return _getFallbackCoordinates(address);
    }
  }
  
  // Fallback method to get coordinates from our predefined map
  static LatLng? _getFallbackCoordinates(String address) {
    final String normalizedAddress = address.toLowerCase();
    
    for (var entry in _fallbackCoordinates.entries) {
      if (normalizedAddress.contains(entry.key)) {
        developer.log('Using fallback coordinates for $address: ${entry.key}', name: 'LOCATION');
        return entry.value;
      }
    }
    
    // Default to Kigali city center if no match found
    developer.log('No fallback coordinates found for $address, using Kigali', name: 'LOCATION');
    return _fallbackCoordinates['kigali'];
  }
}