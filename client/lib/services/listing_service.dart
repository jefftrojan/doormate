import 'package:mobile_client_flutter/models/listing.dart';
import 'package:mobile_client_flutter/services/api_client.dart';
import 'package:mobile_client_flutter/services/storage_service.dart';
import 'dart:developer' as developer;



class ListingService {
  final ApiClient _apiClient;
  final StorageService _storage = StorageService();
  
  ListingService(this._apiClient);

  Future<List<Listing>> getListings({Map<String, dynamic>? filters}) async {
    try {
      developer.log('Fetching listings with filters: $filters', name: 'LISTING');
      
      // Ensure token is set in API client
      await _apiClient.ensureTokenIsSet();

      // Format the query parameters correctly
      final Map<String, dynamic> queryParams = {};
      if (filters != null) {
        filters.forEach((key, value) {
          // Convert numeric values to strings
          if (value is double || value is int) {
            queryParams[key] = value.toString();
          } else if (value != null) {
            queryParams[key] = value;
          }
        });
      }
      
      developer.log('Formatted query parameters: $queryParams', name: 'LISTING');
      
      try {
        // Use endpoint with trailing slash to avoid redirect
        final response = await _apiClient.get('/listings/', queryParameters: queryParams);
        
        // Log the response for debugging
        developer.log('API response type: ${response.runtimeType}', name: 'LISTING');
        developer.log('API response: $response', name: 'LISTING');
        
        List<dynamic> listingsJson = [];
        
        // Enhanced handling of different response formats
        if (response == null) {
          developer.log('API response is null', name: 'LISTING');
          throw Exception('API response is null');
        } else if (response is Map<String, dynamic>) {
          // Handle response as a Map
          developer.log('Response is a Map', name: 'LISTING');
          
          if (response.containsKey('listings')) {
            var listingsData = response['listings'];
            if (listingsData is List) {
              listingsJson = listingsData;
              developer.log('Found listings key with List in response', name: 'LISTING');
            } else {
              developer.log('listings key does not contain a List: ${listingsData.runtimeType}', name: 'LISTING');
              throw Exception('Invalid listings format');
            }
          } else if (response.containsKey('data')) {
            var dataValue = response['data'];
            if (dataValue is List) {
              listingsJson = dataValue;
              developer.log('Found data key with List in response', name: 'LISTING');
            } else {
              developer.log('data key does not contain a List: ${dataValue.runtimeType}', name: 'LISTING');
              throw Exception('Invalid data format');
            }
          } else {
            // Check if the map itself should be treated as a single listing
            if (response.containsKey('id') || response.containsKey('_id')) {
              listingsJson = [response]; // Treat single listing object as a list with one item
              developer.log('Treating single listing object as a list', name: 'LISTING');
            } else {
              developer.log('Unexpected Map format without listings or data keys: $response', name: 'LISTING');
              throw Exception('Could not find listings data in response');
            }
          }
        } else if (response is List) {
          // Response is already a list
          listingsJson = response as List;
          developer.log('Response is directly a List', name: 'LISTING');
        } else {
          // Unknown response type
          developer.log('Unexpected API response type: ${response.runtimeType}', name: 'LISTING');
          throw Exception('Invalid response type: ${response.runtimeType}');
        }
        
        // If we got an empty list and the API client is in mock mode, use mock data
        if (listingsJson.isEmpty) {
          developer.log('Empty listings from API', name: 'LISTING');
          if (_apiClient.useMockData) {
            developer.log('Using mock data instead of empty response', name: 'LISTING');
            return await getListingsMock(filters: filters);
          }
          return []; // Return empty list if no mock data is used
        }
        
        // Log the first listing for debugging
        if (listingsJson.isNotEmpty) {
          developer.log('First listing: ${listingsJson[0]}', name: 'LISTING');
        }
        
        // Process each listing with better error handling
        final listings = <Listing>[];
        for (var json in listingsJson) {
          try {
            final listing = Listing.fromJson(json);
            listings.add(listing);
          } catch (e) {
            developer.log('Error parsing listing: $e', name: 'LISTING');
            developer.log('Problematic JSON: $json', name: 'LISTING');
            // Skip the problematic item instead of failing the whole list
            continue;
          }
        }
        
        developer.log('Successfully fetched ${listings.length} listings', name: 'LISTING');
        return listings;
      } catch (e) {
        // If the API returns an error and mock mode is enabled, use mock data
        developer.log('Error with API call: $e', name: 'LISTING');
        if (_apiClient.useMockData) {
          developer.log('Error with API call, using mock data: $e', name: 'LISTING');
          return await getListingsMock(filters: filters);
        }
        rethrow;
      }
    } catch (e) {
      developer.log('Error fetching listings: $e', name: 'LISTING');
      
      // Return mock data in mock mode
      if (_apiClient.useMockData) {
        developer.log('Using mock listing data', name: 'LISTING');
        return await getListingsMock(filters: filters);
      }
      
      // Re-throw the error in production
      rethrow;
    }
  }

  Future<Listing> getListingById(String listing_id) async {
    try {
      developer.log('Fetching listing with ID: $listing_id', name: 'LISTING');
      
      // Ensure token is set in API client
      await _apiClient.ensureTokenIsSet();

      final response = await _apiClient.get('/listings/${listing_id}/');
      
      // Log the response for debugging
      developer.log('API response: $response', name: 'LISTING');
      
      Map<String, dynamic> listingJson = {};
      
      // Handle different response formats
      if (response.containsKey('listing')) {
        listingJson = response['listing'] as Map<String, dynamic>;
      } else if (response.containsKey('data') && response['data'] is Map) {
        listingJson = response['data'] as Map<String, dynamic>;
      } else if (response is Map && !response.containsKey('listing') && !response.containsKey('data')) {
        listingJson = response as Map<String, dynamic>;
      } else {
        developer.log('Unexpected API response format: $response', name: 'LISTING');
        throw Exception('Invalid response format');
      }
      
      final listing = Listing.fromJson(listingJson);
      developer.log('Successfully fetched listing with ID: $listing_id', name: 'LISTING');
      return listing;
    } catch (e) {
      developer.log('Error fetching listing by ID: $e', name: 'LISTING');
      
      // Return mock data in mock mode
      if (_apiClient.useMockData) {
        developer.log('Using mock listing data for ID: $listing_id', name: 'LISTING');
        return await getListingByIdMock(listing_id);
      }
      
      // Re-throw the error in production
      rethrow;
    }
  }

  Future<List<Listing>> getUserListings() async {
    try {
      developer.log('Fetching user listings', name: 'LISTING');
      
      // Ensure token is set in API client
      await _apiClient.ensureTokenIsSet();

      final response = await _apiClient.get('/listings/my-listings/');
      
      // Log the response for debugging
      developer.log('API response: $response', name: 'LISTING');
      
      List<dynamic> listingsJson = [];
      
      // Handle different response formats
      if (response.containsKey('listings')) {
        listingsJson = response['listings'] as List<dynamic>;
      } else if (response.containsKey('data') && response['data'] is List) {
        listingsJson = response['data'] as List<dynamic>;
      } else if (response is List) {
        listingsJson = response as List<dynamic>;
      } else {
        developer.log('Unexpected API response format: $response', name: 'LISTING');
        throw Exception('Invalid response format');
      }
      
      // If we got an empty list and the API client is in mock mode, use mock data
      if (listingsJson.isEmpty && _apiClient.useMockData) {
        developer.log('Empty user listings from API, using mock data', name: 'LISTING');
        return await getUserListingsMock();
      }
      
      final listings = listingsJson.map((json) => Listing.fromJson(json)).toList();
      developer.log('Successfully fetched ${listings.length} user listings', name: 'LISTING');
      return listings;
    } catch (e) {
      developer.log('Error fetching user listings: $e', name: 'LISTING');
      
      // Return mock data in mock mode
      if (_apiClient.useMockData) {
        developer.log('Using mock user listing data', name: 'LISTING');
        return await getUserListingsMock();
      }
      
      // Re-throw the error in production
      rethrow;
    }
  }

  Future<Listing> createListing(Map<String, dynamic> listingData) async {
  try {
    developer.log('Creating new listing with data: $listingData', name: 'LISTING');
    
    // Ensure token is set in API client
    await _apiClient.ensureTokenIsSet();

    final response = await _apiClient.post('/listings/', listingData);
    
    // Log the raw response for debugging
    developer.log('Create listing response: $response', name: 'LISTING');
    
    // Enhanced response handling
    Map<String, dynamic> listingJson;
    
    if (response is Map<String, dynamic>) {
      if (response.containsKey('listing')) {
        listingJson = response['listing'] as Map<String, dynamic>;
        developer.log('Found listing key in response', name: 'LISTING');
      } else if (response.containsKey('data') && response['data'] is Map) {
        listingJson = response['data'] as Map<String, dynamic>;
        developer.log('Found data key with Map in response', name: 'LISTING');
      } else if (response.containsKey('id') || response.containsKey('_id')) {
        // The response itself might be the listing
        listingJson = response;
        developer.log('Response itself appears to be the listing', name: 'LISTING');
      } else {
        developer.log('Response keys: ${response.keys.join(", ")}', name: 'LISTING');
        
        // Try to create a listing from the response as is
        try {
          final listing = Listing.fromJson(response);
          developer.log('Successfully created listing from direct response', name: 'LISTING');
          return listing;
        } catch (e) {
          developer.log('Failed to create listing from direct response: $e', name: 'LISTING');
          
          // If that didn't work, and we're in mock mode, use mock data
          if (_apiClient.useMockData) {
            developer.log('Using mock data for created listing', name: 'LISTING');
            return await createListingMock(listingData);
          }
          
          throw Exception('Invalid response format: could not find listing data');
        }
      }
    } else {
      developer.log('Unexpected response type: ${response.runtimeType}', name: 'LISTING');
      throw Exception('Invalid response type: ${response.runtimeType}');
    }
    
    try {
      final listing = Listing.fromJson(listingJson);
      developer.log('Successfully created listing with ID: ${listing.id}', name: 'LISTING');
      return listing;
    } catch (e) {
      developer.log('Error creating Listing from JSON: $e', name: 'LISTING');
      developer.log('Problematic JSON: $listingJson', name: 'LISTING');
      
      // If we're in mock mode, use mock data
      if (_apiClient.useMockData) {
        developer.log('Using mock data for created listing', name: 'LISTING');
        return await createListingMock(listingData);
      }
      
      rethrow;
    }
  } catch (e) {
    developer.log('Error creating listing: $e', name: 'LISTING');
    
    // Return mock data in mock mode
    if (_apiClient.useMockData) {
      developer.log('Using mock data for created listing', name: 'LISTING');
      return await createListingMock(listingData);
    }
    
    // Re-throw the error in production
    rethrow;
  }
}

  Future<Listing> updateListing(String id, Map<String, dynamic> listingData) async {
    try {
      developer.log('Updating listing with ID: $id', name: 'LISTING');
      
      // Ensure token is set in API client
      await _apiClient.ensureTokenIsSet();

      final response = await _apiClient.put('/listings/$id/', listingData);
      
      if (response.containsKey('listing')) {
        final listingJson = response['listing'];
        final listing = Listing.fromJson(listingJson);
        developer.log('Successfully updated listing with ID: $id', name: 'LISTING');
        return listing;
      } else {
        developer.log('API response did not contain listing key', name: 'LISTING');
        throw Exception('Invalid response format');
      }
    } catch (e) {
      developer.log('Error updating listing: $e', name: 'LISTING');
      
      // Return mock data in mock mode
      if (_apiClient.useMockData) {
        developer.log('Using mock data for updated listing', name: 'LISTING');
        return await updateListingMock(id, listingData);
      }
      
      // Re-throw the error in production
      rethrow;
    }
  }

  Future<void> deleteListing(String id) async {
    try {
      developer.log('Deleting listing with ID: $id', name: 'LISTING');
      
      // Ensure token is set in API client
      await _apiClient.ensureTokenIsSet();

      await _apiClient.delete('/listings/$id/');
      
      developer.log('Successfully deleted listing with ID: $id', name: 'LISTING');
    } catch (e) {
      developer.log('Error deleting listing: $e', name: 'LISTING');
      
      // In mock mode, just log the error
      if (_apiClient.useMockData) {
        developer.log('Mock deletion of listing with ID: $id', name: 'LISTING');
        return;
      }
      
      // Re-throw the error in production
      rethrow;
    }
  }
  
  Future<void> saveListing(String id) async {
    try {
      developer.log('Saving listing with ID: $id', name: 'LISTING');
      
      // Ensure token is set in API client
      await _apiClient.ensureTokenIsSet();

      await _apiClient.post('/listings/$id/save/', {});
      
      developer.log('Successfully saved listing with ID: $id', name: 'LISTING');
    } catch (e) {
      developer.log('Error saving listing: $e', name: 'LISTING');
      
      // In mock mode, just log the error
      if (_apiClient.useMockData) {
        developer.log('Mock saving of listing with ID: $id', name: 'LISTING');
        return;
      }
      
      // Re-throw the error in production
      rethrow;
    }
  }
  
  Future<void> unsaveListing(String id) async {
    try {
      developer.log('Unsaving listing with ID: $id', name: 'LISTING');
      
      // Ensure token is set in API client
      await _apiClient.ensureTokenIsSet();

      await _apiClient.delete('/listings/$id/save/');
      
      developer.log('Successfully unsaved listing with ID: $id', name: 'LISTING');
    } catch (e) {
      developer.log('Error unsaving listing: $e', name: 'LISTING');
      
      // In mock mode, just log the error
      if (_apiClient.useMockData) {
        developer.log('Mock unsaving of listing with ID: $id', name: 'LISTING');
        return;
      }
      
      // Re-throw the error in production
      rethrow;
    }
  }
  
  Future<List<Listing>> getSavedListings() async {
    try {
      developer.log('Fetching saved listings', name: 'LISTING');
      
      // Ensure token is set in API client
      await _apiClient.ensureTokenIsSet();

      final response = await _apiClient.get('/listings/saved/');
      
      // Log the response for debugging
      developer.log('API response: $response', name: 'LISTING');
      
      List<dynamic> listingsJson = [];
      
      // Handle different response formats
      if (response.containsKey('listings')) {
        listingsJson = response['listings'] as List<dynamic>;
      } else if (response.containsKey('data') && response['data'] is List) {
        listingsJson = response['data'] as List<dynamic>;
      } else if (response is List) {
        listingsJson = response as List<dynamic>;
      } else {
        developer.log('Unexpected API response format: $response', name: 'LISTING');
        throw Exception('Invalid response format');
      }
      
      // If we got an empty list and the API client is in mock mode, use mock data
      if (listingsJson.isEmpty && _apiClient.useMockData) {
        developer.log('Empty saved listings from API, using mock data', name: 'LISTING');
        return await getSavedListingsMock();
      }
      
      final listings = listingsJson.map((json) => Listing.fromJson(json)).toList();
      developer.log('Successfully fetched ${listings.length} saved listings', name: 'LISTING');
      return listings;
    } catch (e) {
      developer.log('Error fetching saved listings: $e', name: 'LISTING');
      
      // Return mock data in mock mode
      if (_apiClient.useMockData) {
        developer.log('Using mock saved listing data', name: 'LISTING');
        return await getSavedListingsMock();
      }
      
      // Re-throw the error in production
      rethrow;
    }
  }

  // For demo purposes, we'll implement mock methods that don't require the backend
  Future<List<Listing>> getListingsMock({Map<String, dynamic>? filters}) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Generate mock listings
    return List.generate(10, (index) {
      final id = (index + 1).toString();
      final price = 300.0 + (index * 50);
      
      return Listing(
        id: id,
        title: 'Apartment near campus #$id',
        description: 'A cozy apartment near the university campus. Perfect for students.',
        price: price,
        location: 'Kigali, Rwanda',
        images: [
          'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8YXBhcnRtZW50fGVufDB8fDB8fHww&auto=format&fit=crop&w=500&q=60',
          'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTB8fGFwYXJ0bWVudHxlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=500&q=60',
        ],
        bedrooms: (index % 3) + 1,
        bathrooms: (index % 2) + 1,
        amenities: [
          'WiFi',
          'Furnished',
          'Kitchen',
          if (index % 2 == 0) 'Parking',
          if (index % 3 == 0) 'Security',
        ],
        availableFrom: DateTime.now().add(Duration(days: index * 5)),
        createdAt: DateTime.now().subtract(Duration(days: index)),
        userId: 'user-${(index % 3) + 1}',
        isSaved: index % 4 == 0,
        roommates: index % 2 == 0 ? (index % 3) + 1 : 0,
        totalRooms: (index % 3) + 1,
      );
    });
  }

  Future<List<Listing>> getUserListingsMock() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Generate mock user listings (fewer than all listings)
    return List.generate(3, (index) {
      final id = (index + 1).toString();
      final price = 300.0 + (index * 50);
      
      return Listing(
        id: id,
        title: 'My Apartment #$id',
        description: 'A cozy apartment that I own near the university campus.',
        price: price,
        location: 'Kigali, Rwanda',
        images: [
          'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8YXBhcnRtZW50fGVufDB8fDB8fHww&auto=format&fit=crop&w=500&q=60',
        ],
        bedrooms: (index % 3) + 1,
        bathrooms: (index % 2) + 1,
        amenities: [
          'WiFi',
          'Furnished',
          'Kitchen',
        ],
        availableFrom: DateTime.now().add(Duration(days: index * 5)),
        createdAt: DateTime.now().subtract(Duration(days: index)),
        userId: 'current-user-id',
        isSaved: false,
        roommates: index % 2 == 0 ? (index % 3) + 1 : 0,
        totalRooms: (index % 3) + 1,
      );
    });
  }

  Future<List<Listing>> getSavedListingsMock() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Generate mock saved listings (subset of all listings)
    return List.generate(4, (index) {
      final id = (index + 5).toString(); // Different IDs from user listings
      final price = 350.0 + (index * 50);
      
      return Listing(
        id: id,
        title: 'Saved Apartment #$id',
        description: 'A cozy apartment that I saved for later consideration.',
        price: price,
        location: 'Kigali, Rwanda',
        images: [
          'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTB8fGFwYXJ0bWVudHxlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=500&q=60',
        ],
        bedrooms: (index % 3) + 1,
        bathrooms: (index % 2) + 1,
        amenities: [
          'WiFi',
          'Furnished',
          'Kitchen',
          'Parking',
        ],
        availableFrom: DateTime.now().add(Duration(days: index * 5)),
        createdAt: DateTime.now().subtract(Duration(days: index + 10)),
        userId: 'user-${(index % 3) + 2}',
        isSaved: true,
        roommates: index % 2 == 0 ? (index % 3) + 1 : 0,
        totalRooms: (index % 3) + 1,
      );
    });
  }

  // Mock methods for development
  Future<Listing> getListingByIdMock(String id) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Generate a mock listing with the given ID
    final mockListings = await getListingsMock();
    return mockListings.firstWhere(
      (listing) => listing.id == id,
      orElse: () => mockListings.first,
    );
  }
  
  Future<Listing> createListingMock(Map<String, dynamic> listingData) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Generate a mock listing with the provided data
    return Listing(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: listingData['title'] ?? 'New Listing',
      description: listingData['description'] ?? 'A new listing description',
      price: listingData['price'] != null ? double.parse(listingData['price'].toString()) : 500.0,
      location: listingData['location'] ?? 'Kigali, Rwanda',
      images: listingData['images'] != null ? List<String>.from(listingData['images']) : [
        'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8YXBhcnRtZW50fGVufDB8fDB8fHww&auto=format&fit=crop&w=500&q=60',
      ],
      bedrooms: listingData['bedrooms'] != null ? int.parse(listingData['bedrooms'].toString()) : 2,
      bathrooms: listingData['bathrooms'] != null ? int.parse(listingData['bathrooms'].toString()) : 1,
      amenities: listingData['amenities'] != null ? List<String>.from(listingData['amenities']) : ['WiFi', 'Furnished'],
      availableFrom: listingData['available_from'] != null ? DateTime.parse(listingData['available_from'].toString()) : DateTime.now(),
      availableUntil: listingData['available_until'] != null ? DateTime.parse(listingData['available_until'].toString()) : null,
      userId: listingData['user_id'] ?? 'user-1',
      isSaved: false,
      roommates: listingData['roommates'] != null ? int.parse(listingData['roommates'].toString()) : 0,
      totalRooms: listingData['total_rooms'] != null ? int.parse(listingData['total_rooms'].toString()) : 2,
      createdAt: DateTime.now(),
    );
  }
  
  Future<Listing> updateListingMock(String id, Map<String, dynamic> listingData) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));
    
    // Get the existing mock listing
    final existingListing = await getListingByIdMock(id);
    
    // Update with new data
    return Listing(
      id: existingListing.id,
      title: listingData['title'] ?? existingListing.title,
      description: listingData['description'] ?? existingListing.description,
      price: listingData['price'] != null ? double.parse(listingData['price'].toString()) : existingListing.price,
      location: listingData['location'] ?? existingListing.location,
      images: listingData['images'] != null ? List<String>.from(listingData['images']) : existingListing.images,
      bedrooms: listingData['bedrooms'] != null ? int.parse(listingData['bedrooms'].toString()) : existingListing.bedrooms,
      bathrooms: listingData['bathrooms'] != null ? int.parse(listingData['bathrooms'].toString()) : existingListing.bathrooms,
      amenities: listingData['amenities'] != null ? List<String>.from(listingData['amenities']) : existingListing.amenities,
      availableFrom: listingData['available_from'] != null ? DateTime.parse(listingData['available_from'].toString()) : existingListing.availableFrom,
      availableUntil: listingData['available_until'] != null ? DateTime.parse(listingData['available_until'].toString()) : existingListing.availableUntil,
      userId: existingListing.userId,
      isSaved: existingListing.isSaved,
      roommates: listingData['roommates'] != null ? int.parse(listingData['roommates'].toString()) : existingListing.roommates,
      totalRooms: listingData['total_rooms'] != null ? int.parse(listingData['total_rooms'].toString()) : existingListing.totalRooms,
      createdAt: existingListing.createdAt,
    );
  }
} 