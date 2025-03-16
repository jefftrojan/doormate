import 'package:flutter/foundation.dart';
import 'package:mobile_client_flutter/models/listing.dart';
import 'package:mobile_client_flutter/services/listing_service.dart';
import 'dart:developer' as developer;

class ListingProvider extends ChangeNotifier {
  final ListingService _listingService;
  bool _isLoading = false;
  String? _error;
  List<Listing> _listings = [];
  List<Listing> _savedListings = [];
  List<Listing> _userListings = [];
  Listing? _currentListing;

  ListingProvider(this._listingService);

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Listing> get listings => _listings;
  List<Listing> get savedListings => _savedListings;
  List<Listing> get userListings => _userListings;
  Listing? get currentListing => _currentListing;

  Future<void> fetchListings({
    String? university,
    double? minPrice,
    double? maxPrice,
    String? location,
    String? roomType,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      developer.log('Fetching listings with filters', name: 'LISTING_PROVIDER');
      
      // Build query parameters
      final filters = <String, dynamic>{};
      if (university != null) filters['university'] = university;
      if (minPrice != null) filters['min_price'] = minPrice;
      if (maxPrice != null) filters['max_price'] = maxPrice;
      if (location != null) filters['location'] = location;
      if (roomType != null) filters['room_type'] = roomType;
      
      _listings = await _listingService.getListings(filters: filters);
      developer.log('Successfully fetched ${_listings.length} listings', name: 'LISTING_PROVIDER');
    } catch (e) {
      developer.log('Error fetching listings: $e', name: 'LISTING_PROVIDER');
      _error = 'Failed to load listings: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUserListings() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      developer.log('Fetching user listings', name: 'LISTING_PROVIDER');
      _userListings = await _listingService.getUserListings();
      developer.log('Successfully fetched ${_userListings.length} user listings', name: 'LISTING_PROVIDER');
    } catch (e) {
      developer.log('Error fetching user listings: $e', name: 'LISTING_PROVIDER');
      _error = 'Failed to load your listings: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> fetchSavedListings() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      developer.log('Fetching saved listings', name: 'LISTING_PROVIDER');
      _savedListings = await _listingService.getSavedListings();
      developer.log('Successfully fetched ${_savedListings.length} saved listings', name: 'LISTING_PROVIDER');
    } catch (e) {
      developer.log('Error fetching saved listings: $e', name: 'LISTING_PROVIDER');
      _error = 'Failed to load saved listings: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchListingById(String id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      developer.log('Fetching listing with ID: $id', name: 'LISTING_PROVIDER');
      
      // First try to find the listing in the existing lists for efficiency
      Listing? existingListing = _listings.firstWhere(
        (listing) => listing.id == id,
        orElse: () => _userListings.firstWhere(
          (listing) => listing.id == id,
          orElse: () => _savedListings.firstWhere(
            (listing) => listing.id == id,
            orElse: () => throw Exception('Not found in local cache'),
          ),
        ),
      );
      
      try {
        _currentListing = existingListing;
        developer.log('Found listing in local cache', name: 'LISTING_PROVIDER');
      } catch (e) {
        // If not found in the lists, fetch from the backend
        _currentListing = await _listingService.getListingById(id);
        developer.log('Fetched listing from backend', name: 'LISTING_PROVIDER');
      }
    } catch (e) {
      developer.log('Error fetching listing by ID: $e', name: 'LISTING_PROVIDER');
      _error = 'Failed to load listing details: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createListing(Map<String, dynamic> listingData) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      developer.log('Creating new listing', name: 'LISTING_PROVIDER');
      final createdListing = await _listingService.createListing(listingData);
      _userListings.add(createdListing);
      developer.log('Successfully created listing with ID: ${createdListing.id}', name: 'LISTING_PROVIDER');
      return true;
    } catch (e) {
      developer.log('Error creating listing: $e', name: 'LISTING_PROVIDER');
      _error = 'Failed to create listing: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateListing(String id, Map<String, dynamic> listingData) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      developer.log('Updating listing with ID: $id', name: 'LISTING_PROVIDER');
      final updatedListing = await _listingService.updateListing(id, listingData);
      
      // Update the listing in the lists
      final listingIndex = _listings.indexWhere((l) => l.id == id);
      if (listingIndex != -1) {
        _listings[listingIndex] = updatedListing;
      }
      
      final userListingIndex = _userListings.indexWhere((l) => l.id == id);
      if (userListingIndex != -1) {
        _userListings[userListingIndex] = updatedListing;
      }
      
      final savedListingIndex = _savedListings.indexWhere((l) => l.id == id);
      if (savedListingIndex != -1) {
        _savedListings[savedListingIndex] = updatedListing;
      }
      
      // Update current listing if it's the same
      if (_currentListing?.id == id) {
        _currentListing = updatedListing;
      }
      
      developer.log('Successfully updated listing', name: 'LISTING_PROVIDER');
      return true;
    } catch (e) {
      developer.log('Error updating listing: $e', name: 'LISTING_PROVIDER');
      _error = 'Failed to update listing: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteListing(String id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      developer.log('Deleting listing with ID: $id', name: 'LISTING_PROVIDER');
      await _listingService.deleteListing(id);
      
      // Remove the listing from the lists
      _listings.removeWhere((listing) => listing.id == id);
      _userListings.removeWhere((listing) => listing.id == id);
      _savedListings.removeWhere((listing) => listing.id == id);
      
      // Clear current listing if it's the same
      if (_currentListing?.id == id) {
        _currentListing = null;
      }
      
      developer.log('Successfully deleted listing', name: 'LISTING_PROVIDER');
      return true;
    } catch (e) {
      developer.log('Error deleting listing: $e', name: 'LISTING_PROVIDER');
      _error = 'Failed to delete listing: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> saveListing(String id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      developer.log('Saving listing with ID: $id', name: 'LISTING_PROVIDER');
      await _listingService.saveListing(id);
      
      // Update the isSaved property in the lists
      final listingIndex = _listings.indexWhere((l) => l.id == id);
      if (listingIndex != -1) {
        final updatedListing = Listing(
          id: _listings[listingIndex].id,
          title: _listings[listingIndex].title,
          description: _listings[listingIndex].description,
          price: _listings[listingIndex].price,
          location: _listings[listingIndex].location,
          images: _listings[listingIndex].images,
          amenities: _listings[listingIndex].amenities,
          university: _listings[listingIndex].university,
          roomType: _listings[listingIndex].roomType,
          availableFrom: _listings[listingIndex].availableFrom,
          availableUntil: _listings[listingIndex].availableUntil,
          userId: _listings[listingIndex].userId,
          user: _listings[listingIndex].user,
          isSaved: true,
          bedrooms: _listings[listingIndex].bedrooms,
          bathrooms: _listings[listingIndex].bathrooms,
          roommates: _listings[listingIndex].roommates,
          totalRooms: _listings[listingIndex].totalRooms,
          createdAt: _listings[listingIndex].createdAt,
        );
        _listings[listingIndex] = updatedListing;
        
        // Add to saved listings if not already there
        if (!_savedListings.any((l) => l.id == id)) {
          _savedListings.add(updatedListing);
        }
      }
      
      // Update current listing if it's the same
      if (_currentListing?.id == id) {
        _currentListing = Listing(
          id: _currentListing!.id,
          title: _currentListing!.title,
          description: _currentListing!.description,
          price: _currentListing!.price,
          location: _currentListing!.location,
          images: _currentListing!.images,
          amenities: _currentListing!.amenities,
          university: _currentListing!.university,
          roomType: _currentListing!.roomType,
          availableFrom: _currentListing!.availableFrom,
          availableUntil: _currentListing!.availableUntil,
          userId: _currentListing!.userId,
          user: _currentListing!.user,
          isSaved: true,
          bedrooms: _currentListing!.bedrooms,
          bathrooms: _currentListing!.bathrooms,
          roommates: _currentListing!.roommates,
          totalRooms: _currentListing!.totalRooms,
          createdAt: _currentListing!.createdAt,
        );
      }
      
      developer.log('Successfully saved listing', name: 'LISTING_PROVIDER');
      return true;
    } catch (e) {
      developer.log('Error saving listing: $e', name: 'LISTING_PROVIDER');
      _error = 'Failed to save listing: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> unsaveListing(String id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      developer.log('Unsaving listing with ID: $id', name: 'LISTING_PROVIDER');
      await _listingService.unsaveListing(id);
      
      // Update the isSaved property in the lists
      final listingIndex = _listings.indexWhere((l) => l.id == id);
      if (listingIndex != -1) {
        final updatedListing = Listing(
          id: _listings[listingIndex].id,
          title: _listings[listingIndex].title,
          description: _listings[listingIndex].description,
          price: _listings[listingIndex].price,
          location: _listings[listingIndex].location,
          images: _listings[listingIndex].images,
          amenities: _listings[listingIndex].amenities,
          university: _listings[listingIndex].university,
          roomType: _listings[listingIndex].roomType,
          availableFrom: _listings[listingIndex].availableFrom,
          availableUntil: _listings[listingIndex].availableUntil,
          userId: _listings[listingIndex].userId,
          user: _listings[listingIndex].user,
          isSaved: false,
          bedrooms: _listings[listingIndex].bedrooms,
          bathrooms: _listings[listingIndex].bathrooms,
          roommates: _listings[listingIndex].roommates,
          totalRooms: _listings[listingIndex].totalRooms,
          createdAt: _listings[listingIndex].createdAt,
        );
        _listings[listingIndex] = updatedListing;
      }
      
      // Remove from saved listings
      _savedListings.removeWhere((listing) => listing.id == id);
      
      // Update current listing if it's the same
      if (_currentListing?.id == id) {
        _currentListing = Listing(
          id: _currentListing!.id,
          title: _currentListing!.title,
          description: _currentListing!.description,
          price: _currentListing!.price,
          location: _currentListing!.location,
          images: _currentListing!.images,
          amenities: _currentListing!.amenities,
          university: _currentListing!.university,
          roomType: _currentListing!.roomType,
          availableFrom: _currentListing!.availableFrom,
          availableUntil: _currentListing!.availableUntil,
          userId: _currentListing!.userId,
          user: _currentListing!.user,
          isSaved: false,
          bedrooms: _currentListing!.bedrooms,
          bathrooms: _currentListing!.bathrooms,
          roommates: _currentListing!.roommates,
          totalRooms: _currentListing!.totalRooms,
          createdAt: _currentListing!.createdAt,
        );
      }
      
      developer.log('Successfully unsaved listing', name: 'LISTING_PROVIDER');
      return true;
    } catch (e) {
      developer.log('Error unsaving listing: $e', name: 'LISTING_PROVIDER');
      _error = 'Failed to unsave listing: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  void clearCurrentListing() {
    _currentListing = null;
    notifyListeners();
  }
  
  Future<void> refreshListings() async {
    _error = null;
    await fetchListings();
  }
  
  Future<void> refreshUserListings() async {
    _error = null;
    await fetchUserListings();
  }
  
  Future<void> refreshSavedListings() async {
    _error = null;
    await fetchSavedListings();
  }
} 