import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:developer' as developer;
import 'dart:convert';

class HousingDataService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  final String _baseUrl = 'localhost:8001';
  
  // Constructor
  HousingDataService();
  
  // Get authentication token
  Future<String?> _getAuthToken() async {
    try {
      return await _secureStorage.read(key: 'auth_token');
    } catch (e) {
      developer.log('Error getting auth token: $e', name: 'HOUSING_DATA');
      return null;
    }
  }
  
  // Get available properties in a neighborhood
  Future<Map<String, dynamic>> getPropertiesByNeighborhood(String neighborhood) async {
    try {
      final token = await _getAuthToken();
      final response = await _dio.get(
        '$_baseUrl/properties',
        queryParameters: {'neighborhood': neighborhood},
        options: Options(
          headers: token != null ? {'Authorization': 'Bearer $token'} : null,
        ),
      );
      
      if (response.statusCode == 200) {
        developer.log('Successfully fetched properties in $neighborhood', name: 'HOUSING_DATA');
        return {
          'success': true,
          'data': response.data,
          'count': response.data.length,
        };
      } else {
        developer.log('Error fetching properties: ${response.statusCode}', name: 'HOUSING_DATA');
        return {
          'success': false,
          'error': 'Failed to fetch properties',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      developer.log('Exception fetching properties: $e', name: 'HOUSING_DATA');
      
      // Return mock data for testing if API is not available
      return {
        'success': true,
        'data': _getMockPropertiesForNeighborhood(neighborhood),
        'count': _getMockPropertiesForNeighborhood(neighborhood).length,
        'isMock': true,
      };
    }
  }
  
  // Get price ranges for a neighborhood
  Future<Map<String, dynamic>> getPriceRangeByNeighborhood(String neighborhood) async {
    try {
      final token = await _getAuthToken();
      final response = await _dio.get(
        '$_baseUrl/price-ranges',
        queryParameters: {'neighborhood': neighborhood},
        options: Options(
          headers: token != null ? {'Authorization': 'Bearer $token'} : null,
        ),
      );
      
      if (response.statusCode == 200) {
        developer.log('Successfully fetched price ranges in $neighborhood', name: 'HOUSING_DATA');
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        developer.log('Error fetching price ranges: ${response.statusCode}', name: 'HOUSING_DATA');
        return {
          'success': false,
          'error': 'Failed to fetch price ranges',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      developer.log('Exception fetching price ranges: $e', name: 'HOUSING_DATA');
      
      // Return mock data for testing if API is not available
      return {
        'success': true,
        'data': _getMockPriceRangeForNeighborhood(neighborhood),
        'isMock': true,
      };
    }
  }
  
  // Get roommate matches based on preferences
  Future<Map<String, dynamic>> getRoommateMatches(Map<String, dynamic> preferences) async {
    try {
      final token = await _getAuthToken();
      final response = await _dio.post(
        '$_baseUrl/roommate-matches',
        data: preferences,
        options: Options(
          headers: token != null ? {'Authorization': 'Bearer $token'} : null,
        ),
      );
      
      if (response.statusCode == 200) {
        developer.log('Successfully fetched roommate matches', name: 'HOUSING_DATA');
        return {
          'success': true,
          'data': response.data,
          'count': response.data.length,
        };
      } else {
        developer.log('Error fetching roommate matches: ${response.statusCode}', name: 'HOUSING_DATA');
        return {
          'success': false,
          'error': 'Failed to fetch roommate matches',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      developer.log('Exception fetching roommate matches: $e', name: 'HOUSING_DATA');
      
      // Return mock data for testing if API is not available
      return {
        'success': true,
        'data': _getMockRoommateMatches(preferences),
        'count': _getMockRoommateMatches(preferences).length,
        'isMock': true,
      };
    }
  }
  
  // Get all neighborhoods
  Future<Map<String, dynamic>> getAllNeighborhoods() async {
    try {
      final token = await _getAuthToken();
      final response = await _dio.get(
        '$_baseUrl/neighborhoods',
        options: Options(
          headers: token != null ? {'Authorization': 'Bearer $token'} : null,
        ),
      );
      
      if (response.statusCode == 200) {
        developer.log('Successfully fetched neighborhoods', name: 'HOUSING_DATA');
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        developer.log('Error fetching neighborhoods: ${response.statusCode}', name: 'HOUSING_DATA');
        return {
          'success': false,
          'error': 'Failed to fetch neighborhoods',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      developer.log('Exception fetching neighborhoods: $e', name: 'HOUSING_DATA');
      
      // Return mock data for testing if API is not available
      return {
        'success': true,
        'data': _getMockNeighborhoods(),
        'isMock': true,
      };
    }
  }
  
  // Get amenities for a property type
  Future<Map<String, dynamic>> getAmenitiesByPropertyType(String propertyType) async {
    try {
      final token = await _getAuthToken();
      final response = await _dio.get(
        '$_baseUrl/amenities',
        queryParameters: {'propertyType': propertyType},
        options: Options(
          headers: token != null ? {'Authorization': 'Bearer $token'} : null,
        ),
      );
      
      if (response.statusCode == 200) {
        developer.log('Successfully fetched amenities for $propertyType', name: 'HOUSING_DATA');
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        developer.log('Error fetching amenities: ${response.statusCode}', name: 'HOUSING_DATA');
        return {
          'success': false,
          'error': 'Failed to fetch amenities',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      developer.log('Exception fetching amenities: $e', name: 'HOUSING_DATA');
      
      // Return mock data for testing if API is not available
      return {
        'success': true,
        'data': _getMockAmenitiesForPropertyType(propertyType),
        'isMock': true,
      };
    }
  }
  
  // Get user's saved properties
  Future<Map<String, dynamic>> getUserSavedProperties() async {
    try {
      final token = await _getAuthToken();
      
      if (token == null) {
        return {
          'success': false,
          'error': 'User not authenticated',
        };
      }
      
      final response = await _dio.get(
        '$_baseUrl/user/saved-properties',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      
      if (response.statusCode == 200) {
        developer.log('Successfully fetched user saved properties', name: 'HOUSING_DATA');
        return {
          'success': true,
          'data': response.data,
          'count': response.data.length,
        };
      } else {
        developer.log('Error fetching user saved properties: ${response.statusCode}', name: 'HOUSING_DATA');
        return {
          'success': false,
          'error': 'Failed to fetch user saved properties',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      developer.log('Exception fetching user saved properties: $e', name: 'HOUSING_DATA');
      
      // Return mock data for testing if API is not available
      return {
        'success': true,
        'data': _getMockUserSavedProperties(),
        'count': _getMockUserSavedProperties().length,
        'isMock': true,
      };
    }
  }
  
  // Search properties by criteria
  Future<Map<String, dynamic>> searchProperties(Map<String, dynamic> criteria) async {
    try {
      final token = await _getAuthToken();
      final response = await _dio.post(
        '$_baseUrl/properties/search',
        data: criteria,
        options: Options(
          headers: token != null ? {'Authorization': 'Bearer $token'} : null,
        ),
      );
      
      if (response.statusCode == 200) {
        developer.log('Successfully searched properties', name: 'HOUSING_DATA');
        return {
          'success': true,
          'data': response.data,
          'count': response.data.length,
        };
      } else {
        developer.log('Error searching properties: ${response.statusCode}', name: 'HOUSING_DATA');
        return {
          'success': false,
          'error': 'Failed to search properties',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      developer.log('Exception searching properties: $e', name: 'HOUSING_DATA');
      
      // Return mock data for testing if API is not available
      return {
        'success': true,
        'data': _getMockSearchResults(criteria),
        'count': _getMockSearchResults(criteria).length,
        'isMock': true,
      };
    }
  }
  
  // MOCK DATA METHODS
  // These methods provide mock data for testing when the API is not available
  
  List<Map<String, dynamic>> _getMockPropertiesForNeighborhood(String neighborhood) {
    final neighborhoods = {
      'kacyiru': [
        {
          'id': 'prop1',
          'title': 'Modern Apartment in Kacyiru',
          'type': 'apartment',
          'bedrooms': 2,
          'bathrooms': 1,
          'price': 450,
          'currency': 'USD',
          'furnished': true,
          'description': 'A beautiful modern apartment in the heart of Kacyiru, close to embassies and offices.',
          'amenities': ['WiFi', 'Security', 'Water Tank', 'Parking'],
        },
        {
          'id': 'prop2',
          'title': 'Shared House in Kacyiru',
          'type': 'shared',
          'bedrooms': 1,
          'bathrooms': 1,
          'price': 250,
          'currency': 'USD',
          'furnished': true,
          'description': 'A room in a shared house with other students, perfect for those studying in Kacyiru.',
          'amenities': ['WiFi', 'Shared Kitchen', 'Laundry'],
        },
      ],
      'kimihurura': [
        {
          'id': 'prop3',
          'title': 'Luxury Apartment in Kimihurura',
          'type': 'apartment',
          'bedrooms': 3,
          'bathrooms': 2,
          'price': 600,
          'currency': 'USD',
          'furnished': true,
          'description': 'A spacious luxury apartment in the upscale Kimihurura neighborhood.',
          'amenities': ['WiFi', 'Security', 'Generator', 'Parking', 'Swimming Pool'],
        },
        {
          'id': 'prop4',
          'title': 'Studio Apartment in Kimihurura',
          'type': 'studio',
          'bedrooms': 1,
          'bathrooms': 1,
          'price': 350,
          'currency': 'USD',
          'furnished': true,
          'description': 'A cozy studio apartment perfect for singles or couples in Kimihurura.',
          'amenities': ['WiFi', 'Security', 'Water Tank'],
        },
      ],
      'remera': [
        {
          'id': 'prop5',
          'title': 'Family House in Remera',
          'type': 'house',
          'bedrooms': 4,
          'bathrooms': 2,
          'price': 500,
          'currency': 'USD',
          'furnished': false,
          'description': 'A spacious family house in Remera, close to schools and markets.',
          'amenities': ['Garden', 'Parking', 'Security'],
        },
        {
          'id': 'prop6',
          'title': 'Student Accommodation in Remera',
          'type': 'shared',
          'bedrooms': 1,
          'bathrooms': 1,
          'price': 180,
          'currency': 'USD',
          'furnished': true,
          'description': 'Affordable student accommodation in Remera, close to universities.',
          'amenities': ['WiFi', 'Shared Kitchen', 'Study Area'],
        },
      ],
      'nyamirambo': [
        {
          'id': 'prop7',
          'title': 'Traditional House in Nyamirambo',
          'type': 'house',
          'bedrooms': 3,
          'bathrooms': 1,
          'price': 300,
          'currency': 'USD',
          'furnished': false,
          'description': 'A traditional house in the vibrant neighborhood of Nyamirambo.',
          'amenities': ['Garden', 'Parking'],
        },
      ],
      'gikondo': [
        {
          'id': 'prop8',
          'title': 'Modern House in Gikondo',
          'type': 'house',
          'bedrooms': 3,
          'bathrooms': 2,
          'price': 400,
          'currency': 'USD',
          'furnished': true,
          'description': 'A modern house in Gikondo with a beautiful view of the city.',
          'amenities': ['WiFi', 'Security', 'Garden', 'Parking'],
        },
      ],
      'kicukiro': [
        {
          'id': 'prop9',
          'title': 'Apartment Complex in Kicukiro',
          'type': 'apartment',
          'bedrooms': 2,
          'bathrooms': 1,
          'price': 350,
          'currency': 'USD',
          'furnished': true,
          'description': 'A modern apartment in a new complex in Kicukiro.',
          'amenities': ['WiFi', 'Security', 'Gym', 'Parking'],
        },
      ],
      'gisozi': [
        {
          'id': 'prop10',
          'title': 'Affordable House in Gisozi',
          'type': 'house',
          'bedrooms': 2,
          'bathrooms': 1,
          'price': 250,
          'currency': 'USD',
          'furnished': false,
          'description': 'An affordable house in Gisozi, perfect for small families.',
          'amenities': ['Garden', 'Parking'],
        },
      ],
    };
    
    final lowerNeighborhood = neighborhood.toLowerCase();
    return neighborhoods[lowerNeighborhood] ?? [];
  }
  
  Map<String, dynamic> _getMockPriceRangeForNeighborhood(String neighborhood) {
    final priceRanges = {
      'kacyiru': {
        'apartment': {'min': 350, 'max': 600, 'currency': 'USD'},
        'house': {'min': 450, 'max': 800, 'currency': 'USD'},
        'shared': {'min': 200, 'max': 300, 'currency': 'USD'},
        'studio': {'min': 250, 'max': 400, 'currency': 'USD'},
      },
      'kimihurura': {
        'apartment': {'min': 400, 'max': 700, 'currency': 'USD'},
        'house': {'min': 500, 'max': 1000, 'currency': 'USD'},
        'shared': {'min': 250, 'max': 350, 'currency': 'USD'},
        'studio': {'min': 300, 'max': 450, 'currency': 'USD'},
      },
      'remera': {
        'apartment': {'min': 300, 'max': 500, 'currency': 'USD'},
        'house': {'min': 400, 'max': 700, 'currency': 'USD'},
        'shared': {'min': 150, 'max': 250, 'currency': 'USD'},
        'studio': {'min': 200, 'max': 350, 'currency': 'USD'},
      },
      'nyamirambo': {
        'apartment': {'min': 250, 'max': 400, 'currency': 'USD'},
        'house': {'min': 300, 'max': 500, 'currency': 'USD'},
        'shared': {'min': 120, 'max': 200, 'currency': 'USD'},
        'studio': {'min': 180, 'max': 300, 'currency': 'USD'},
      },
      'gikondo': {
        'apartment': {'min': 300, 'max': 450, 'currency': 'USD'},
        'house': {'min': 350, 'max': 600, 'currency': 'USD'},
        'shared': {'min': 150, 'max': 250, 'currency': 'USD'},
        'studio': {'min': 200, 'max': 350, 'currency': 'USD'},
      },
      'kicukiro': {
        'apartment': {'min': 300, 'max': 500, 'currency': 'USD'},
        'house': {'min': 350, 'max': 650, 'currency': 'USD'},
        'shared': {'min': 150, 'max': 250, 'currency': 'USD'},
        'studio': {'min': 200, 'max': 350, 'currency': 'USD'},
      },
      'gisozi': {
        'apartment': {'min': 250, 'max': 400, 'currency': 'USD'},
        'house': {'min': 300, 'max': 500, 'currency': 'USD'},
        'shared': {'min': 120, 'max': 200, 'currency': 'USD'},
        'studio': {'min': 180, 'max': 300, 'currency': 'USD'},
      },
    };
    
    final lowerNeighborhood = neighborhood.toLowerCase();
    return priceRanges[lowerNeighborhood] ?? {
      'apartment': {'min': 300, 'max': 500, 'currency': 'USD'},
      'house': {'min': 350, 'max': 650, 'currency': 'USD'},
      'shared': {'min': 150, 'max': 250, 'currency': 'USD'},
      'studio': {'min': 200, 'max': 350, 'currency': 'USD'},
    };
  }
  
  List<Map<String, dynamic>> _getMockRoommateMatches(Map<String, dynamic> preferences) {
    // Default roommate matches
    final defaultMatches = [
      {
        'id': 'user1',
        'name': 'John Doe',
        'age': 22,
        'gender': 'Male',
        'occupation': 'Student',
        'university': 'University of Rwanda',
        'budget': 200,
        'currency': 'USD',
        'moveInDate': '2023-09-01',
        'interests': ['Reading', 'Sports', 'Music'],
        'compatibility': 85,
      },
      {
        'id': 'user2',
        'name': 'Jane Smith',
        'age': 24,
        'gender': 'Female',
        'occupation': 'Professional',
        'workplace': 'Tech Company',
        'budget': 250,
        'currency': 'USD',
        'moveInDate': '2023-08-15',
        'interests': ['Travel', 'Cooking', 'Movies'],
        'compatibility': 78,
      },
      {
        'id': 'user3',
        'name': 'Michael Johnson',
        'age': 23,
        'gender': 'Male',
        'occupation': 'Student',
        'university': 'African Leadership University',
        'budget': 180,
        'currency': 'USD',
        'moveInDate': '2023-09-15',
        'interests': ['Gaming', 'Technology', 'Sports'],
        'compatibility': 72,
      },
    ];
    
    // Filter based on preferences if provided
    if (preferences.isEmpty) {
      return defaultMatches;
    }
    
    // Apply filters based on preferences
    return defaultMatches.where((match) {
      bool isMatch = true;
      
      if (preferences.containsKey('gender') && preferences['gender'] != null) {
        isMatch = isMatch && match['gender'] == preferences['gender'];
      }
      
      if (preferences.containsKey('minBudget') && preferences['minBudget'] != null) {
        final matchBudget = match['budget'] as int?;
        final minBudget = preferences['minBudget'] as int?;
        isMatch = isMatch && (matchBudget != null && minBudget != null && matchBudget >= minBudget);
      }
      
      if (preferences.containsKey('maxBudget') && preferences['maxBudget'] != null) {
        final matchBudget = match['budget'] as int?;
        final maxBudget = preferences['maxBudget'] as int?;
        isMatch = isMatch && (matchBudget != null && maxBudget != null && matchBudget <= maxBudget);
      }
      
      if (preferences.containsKey('occupation') && preferences['occupation'] != null) {
        isMatch = isMatch && match['occupation'] == preferences['occupation'];
      }
      
      return isMatch;
    }).toList();
  }
  
  List<String> _getMockNeighborhoods() {
    return [
      'Kacyiru',
      'Kimihurura',
      'Nyamirambo',
      'Remera',
      'Kicukiro',
      'Gikondo',
      'Gisozi',
      'Nyarutarama',
      'Kibagabaga',
      'Kiyovu',
    ];
  }
  
  List<String> _getMockAmenitiesForPropertyType(String propertyType) {
    final amenities = {
      'apartment': [
        'WiFi',
        'Security',
        'Water Tank',
        'Backup Generator',
        'Parking',
        'Elevator',
        'Gym',
        'Swimming Pool',
        'Balcony',
        'Air Conditioning',
      ],
      'house': [
        'Garden',
        'Parking',
        'Security',
        'Water Tank',
        'Backup Generator',
        'Outdoor Space',
        'Garage',
        'WiFi',
      ],
      'shared': [
        'WiFi',
        'Shared Kitchen',
        'Laundry',
        'Study Area',
        'Common Room',
        'Security',
        'Water Tank',
      ],
      'studio': [
        'WiFi',
        'Security',
        'Water Tank',
        'Kitchenette',
        'Laundry',
        'Air Conditioning',
      ],
    };
    
    return amenities[propertyType.toLowerCase()] ?? [];
  }
  
  List<Map<String, dynamic>> _getMockUserSavedProperties() {
    return [
      {
        'id': 'prop1',
        'title': 'Modern Apartment in Kacyiru',
        'type': 'apartment',
        'bedrooms': 2,
        'bathrooms': 1,
        'price': 450,
        'currency': 'USD',
        'neighborhood': 'Kacyiru',
        'savedDate': '2023-07-15',
      },
      {
        'id': 'prop4',
        'title': 'Studio Apartment in Kimihurura',
        'type': 'studio',
        'bedrooms': 1,
        'bathrooms': 1,
        'price': 350,
        'currency': 'USD',
        'neighborhood': 'Kimihurura',
        'savedDate': '2023-07-20',
      },
    ];
  }
  
  List<Map<String, dynamic>> _getMockSearchResults(Map<String, dynamic> criteria) {
    // Combine all properties from all neighborhoods
    List<Map<String, dynamic>> allProperties = [];
    
    for (final neighborhood in _getMockNeighborhoods()) {
      allProperties.addAll(_getMockPropertiesForNeighborhood(neighborhood));
    }
    
    // Filter based on criteria
    return allProperties.where((property) {
      bool isMatch = true;
      
      if (criteria.containsKey('neighborhood') && criteria['neighborhood'] != null) {
        isMatch = isMatch && property['neighborhood']?.toLowerCase() == criteria['neighborhood'].toLowerCase();
      }
      
      if (criteria.containsKey('propertyType') && criteria['propertyType'] != null) {
        isMatch = isMatch && property['type']?.toLowerCase() == criteria['propertyType'].toLowerCase();
      }
      
      if (criteria.containsKey('minPrice') && criteria['minPrice'] != null) {
        final propertyPrice = property['price'] as int?;
        final minPrice = criteria['minPrice'] as int?;
        isMatch = isMatch && (propertyPrice != null && minPrice != null && propertyPrice >= minPrice);
      }
      
      if (criteria.containsKey('maxPrice') && criteria['maxPrice'] != null) {
        final propertyPrice = property['price'] as int?;
        final maxPrice = criteria['maxPrice'] as int?;
        isMatch = isMatch && (propertyPrice != null && maxPrice != null && propertyPrice <= maxPrice);
      }
      
      if (criteria.containsKey('bedrooms') && criteria['bedrooms'] != null) {
        final propertyBedrooms = property['bedrooms'] as int?;
        final criteriaBedroooms = criteria['bedrooms'] as int?;
        isMatch = isMatch && (propertyBedrooms != null && criteriaBedroooms != null && propertyBedrooms >= criteriaBedroooms);
      }
      
      if (criteria.containsKey('bathrooms') && criteria['bathrooms'] != null) {
        final propertyBathrooms = property['bathrooms'] as int?;
        final criteriaBathrooms = criteria['bathrooms'] as int?;
        isMatch = isMatch && (propertyBathrooms != null && criteriaBathrooms != null && propertyBathrooms >= criteriaBathrooms);
      }
      
      if (criteria.containsKey('furnished') && criteria['furnished'] != null) {
        isMatch = isMatch && property['furnished'] == criteria['furnished'];
      }
      
      return isMatch;
    }).toList();
  }
} 