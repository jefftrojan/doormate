import 'package:mobile_client_flutter/models/roommate_match.dart';
import 'package:mobile_client_flutter/services/api_client.dart';
import 'package:mobile_client_flutter/services/storage_service.dart';
import 'dart:developer' as developer;

class MatchService {
  final ApiClient _apiClient;
  final StorageService _storage = StorageService();
  
  MatchService(this._apiClient);

  // Original methods
  Future<List<RoommateMatch>> getMatches() async {
    try {
      developer.log('Fetching matches', name: 'MATCH_SERVICE');
      
      // Ensure token is set in API client
      await _apiClient.ensureTokenIsSet();

      final response = await _apiClient.get('/matching/matches');
      
      developer.log('API response: $response', name: 'MATCH_SERVICE');
      
      List<dynamic> matchesJson = [];
      
      // Handle different response formats
      if (response.containsKey('matches')) {
        matchesJson = response['matches'] as List<dynamic>;
      } else if (response.containsKey('data') && response['data'] is List) {
        matchesJson = response['data'] as List<dynamic>;
      } else if (response is List) {
        matchesJson = response as List;
      } else {
        developer.log('Unexpected API response format: $response', name: 'MATCH_SERVICE');
        throw Exception('Invalid response format');
      }
      
      final matches = matchesJson.map((json) => RoommateMatch.fromJson(json)).toList();
      developer.log('Successfully fetched ${matches.length} matches', name: 'MATCH_SERVICE');
      return matches;
    } catch (e) {
      developer.log('Error fetching matches: $e', name: 'MATCH_SERVICE');
      
      // Return mock data in mock mode
      if (_apiClient.useMockData) {
        developer.log('Using mock match data', name: 'MATCH_SERVICE');
        return getMockMatches();
      }
      
      rethrow;
    }
  }

  Future<RoommateMatch> getMatchById(String id) async {
    try {
      developer.log('Fetching match with ID: $id', name: 'MATCH_SERVICE');
      
      // Ensure token is set in API client
      await _apiClient.ensureTokenIsSet();

      final response = await _apiClient.get('/matches/$id');
      
      developer.log('API response: $response', name: 'MATCH_SERVICE');
      
      Map<String, dynamic> matchJson = {};
      
      // Handle different response formats
      if (response.containsKey('match')) {
        matchJson = response['match'] as Map<String, dynamic>;
      } else if (response.containsKey('data') && response['data'] is Map) {
        matchJson = response['data'] as Map<String, dynamic>;
      } else if (response is Map && !response.containsKey('match') && !response.containsKey('data')) {
        matchJson = response as Map<String, dynamic>;
      } else {
        developer.log('Unexpected API response format: $response', name: 'MATCH_SERVICE');
        throw Exception('Invalid response format');
      }
      
      final match = RoommateMatch.fromJson(matchJson);
      developer.log('Successfully fetched match with ID: $id', name: 'MATCH_SERVICE');
      return match;
    } catch (e) {
      developer.log('Error fetching match by ID: $e', name: 'MATCH_SERVICE');
      
      // Return mock data in mock mode
      if (_apiClient.useMockData) {
        developer.log('Using mock match data for ID: $id', name: 'MATCH_SERVICE');
        return getMockMatchById(id);
      }
      
      rethrow;
    }
  }

  Future<dynamic> confirmMatch(String matchId) async {
    try {
      developer.log('Confirming match with ID: $matchId', name: 'MATCH_SERVICE');
      
      // Ensure token is set in API client
      await _apiClient.ensureTokenIsSet();

      final response = await _apiClient.post('/matching/matches/$matchId/confirm', {});
      
      developer.log('API response: $response', name: 'MATCH_SERVICE');
      
      // Return the raw response to let the provider handle various formats
      return response;
    } catch (e) {
      developer.log('Error confirming match: $e', name: 'MATCH_SERVICE');
      
      // Return mock response in mock mode
      if (_apiClient.useMockData) {
        return {
          'success': true,
          'mutual_match': matchId.hashCode % 2 == 0, // Random for demo
          'message': matchId.hashCode % 2 == 0 ? "It's a match!" : "Match confirmed"
        };
      }
      
      rethrow;
    }
  }

  Future<bool> rejectMatch(String matchId) async {
    try {
      developer.log('Rejecting match with ID: $matchId', name: 'MATCH_SERVICE');
      
      // Ensure token is set in API client
      await _apiClient.ensureTokenIsSet();

      await _apiClient.delete('/matching/matches/$matchId');
      
      developer.log('Successfully rejected match with ID: $matchId', name: 'MATCH_SERVICE');
      
      return true;
    } catch (e) {
      developer.log('Error rejecting match: $e', name: 'MATCH_SERVICE');
      
      // Return success in mock mode
      if (_apiClient.useMockData) {
        return true;
      }
      
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>> provideFeedback(String matchId, Map<String, dynamic> feedback) async {
    try {
      developer.log('Providing feedback for match with ID: $matchId', name: 'MATCH_SERVICE');
      
      // Ensure token is set in API client
      await _apiClient.ensureTokenIsSet();

      final response = await _apiClient.post('/matches/$matchId/feedback', feedback);
      
      developer.log('API response: $response', name: 'MATCH_SERVICE');
      
      return response as Map<String, dynamic>;
    } catch (e) {
      developer.log('Error providing feedback: $e', name: 'MATCH_SERVICE');
      
      // Return mock response in mock mode
      if (_apiClient.useMockData) {
        return {"success": true, "message": "Feedback submitted successfully"};
      }
      
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>> getMatchStatistics() async {
    try {
      developer.log('Fetching match statistics', name: 'MATCH_SERVICE');
      
      // Ensure token is set in API client
      await _apiClient.ensureTokenIsSet();

      final response = await _apiClient.get('/matches/statistics');
      
      developer.log('API response: $response', name: 'MATCH_SERVICE');
      
      return response as Map<String, dynamic>;
    } catch (e) {
      developer.log('Error fetching match statistics: $e', name: 'MATCH_SERVICE');
      
      // Return mock statistics in mock mode
      if (_apiClient.useMockData) {
        return {
          "total_matches": 12,
          "confirmed_matches": 5,
          "pending_matches": 7,
          "compatibility_stats": {
            "average_score": 0.75,
            "highest_score": 0.95,
            "lowest_score": 0.55
          }
        };
      }
      
      rethrow;
    }
  }

  // New methods for roommate matching

  Future<List<RoommateMatch>> getPotentialMatches() async {
    try {
      developer.log('Fetching potential roommate matches', name: 'MATCH_SERVICE');
      
      // Ensure token is set in API client
      await _apiClient.ensureTokenIsSet();

      final response = await _apiClient.get('/matching/matches');
      
      // Log the response for debugging
      developer.log('API response: $response', name: 'MATCH_SERVICE');
      
      List<dynamic> matchesJson = [];
      
      // Handle different response formats
      if (response.containsKey('matches')) {
        matchesJson = response['matches'] as List<dynamic>;
      } else if (response.containsKey('data') && response['data'] is List) {
        matchesJson = response['data'] as List<dynamic>;
      } else if (response is List) {
        matchesJson = response as List;
      } else {
        developer.log('Unexpected API response format: $response', name: 'MATCH_SERVICE');
        throw Exception('Invalid response format');
      }
      
      // Parse matches
      final matches = matchesJson.map((json) {
        return RoommateMatch.fromJson(json);
      }).toList();
      
      developer.log('Successfully fetched ${matches.length} potential matches', name: 'MATCH_SERVICE');
      return matches;
    } catch (e) {
      developer.log('Error fetching potential matches: $e', name: 'MATCH_SERVICE');
      
      // If in mock mode, return mock data
      if (_apiClient.useMockData) {
        return getMockPotentialMatches();
      }
      
      rethrow;
    }
  }

  Future<List<RoommateMatch>> getMutualMatches() async {
    try {
      developer.log('Fetching mutual matches', name: 'MATCH_SERVICE');
      
      // Ensure token is set in API client
      await _apiClient.ensureTokenIsSet();

      final response = await _apiClient.get('/matching/matches/mutual');
      
      // Log the response for debugging
      developer.log('API response: $response', name: 'MATCH_SERVICE');
      
      List<dynamic> matchesJson = [];
      
      // Handle different response formats
      if (response.containsKey('matches')) {
        matchesJson = response['matches'] as List<dynamic>;
      } else if (response.containsKey('data') && response['data'] is List) {
        matchesJson = response['data'] as List<dynamic>;
      } else if (response is List) {
        matchesJson = response as List;
      } else {
        developer.log('Unexpected API response format: $response', name: 'MATCH_SERVICE');
        throw Exception('Invalid response format');
      }
      
      // Parse matches
      final matches = matchesJson.map((json) {
        return RoommateMatch.fromJson(json);
      }).toList();
      
      developer.log('Successfully fetched ${matches.length} mutual matches', name: 'MATCH_SERVICE');
      return matches;
    } catch (e) {
      developer.log('Error fetching mutual matches: $e', name: 'MATCH_SERVICE');
      
      // If in mock mode, return mock data
      if (_apiClient.useMockData) {
        return getMockMutualMatches();
      }
      
      rethrow;
    }
  }

  // Mock data methods
  List<RoommateMatch> getMockMatches() {
    return List.generate(5, (index) {
      final id = (index + 1).toString();
      final isConfirmed = index % 2 == 0;
      
      return RoommateMatch(
        id: id,
        userId: "current-user-id",
        matchedUserId: "matched-user-$id",
        name: 'Match $id',
        matchScore: 0.7 + (index * 0.05),
        isConfirmed: isConfirmed,
        compatibilityFactors: {
          'Cleanliness': 0.8,
          'Noise Tolerance': 0.7,
          'Study Habits': 0.9,
          'Budget': 0.75,
        },
        profileImage: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        bio: 'A potential roommate match with compatible lifestyle preferences.',
      );
    });
  }

  RoommateMatch getMockMatchById(String id) {
    return RoommateMatch(
      id: id,
      userId: "current-user-id",
      matchedUserId: "matched-user-$id",
      name: 'Match $id',
      matchScore: 0.85,
      isConfirmed: id.hashCode % 2 == 0,
      compatibilityFactors: {
        'Cleanliness': 0.8,
        'Noise Tolerance': 0.7,
        'Study Habits': 0.9,
        'Budget': 0.75,
      },
      profileImage: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
      bio: 'A potential roommate match with compatible lifestyle preferences.',
    );
  }

  List<RoommateMatch> getMockPotentialMatches() {
    return List.generate(5, (index) {
      final id = (index + 1).toString();
      final matchScore = 0.5 + (index * 0.1);
      
      return RoommateMatch(
        id: id,
        userId: "current-user-id",
        matchedUserId: "potential-match-$id",
        name: 'Potential Match $id',
        bio: 'A potential roommate match with similar preferences.',
        profileImage: 'https://images.unsplash.com/photo-1580489944761-15a19d654956?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        matchScore: matchScore > 1.0 ? 1.0 : matchScore,
        isConfirmed: false,
        compatibilityFactors: {
          'Cleanliness': 0.7 + (index * 0.05),
          'Noise Tolerance': 0.6 + (index * 0.05),
          'Study Habits': 0.8 - (index * 0.05),
          'Budget': 0.9 - (index * 0.05),
        },
      );
    });
  }

  List<RoommateMatch> getMockMutualMatches() {
    return List.generate(2, (index) {
      final id = (index + 10).toString();
      
      return RoommateMatch(
        id: id,
        userId: "current-user-id",
        matchedUserId: "mutual-match-$id",
        name: 'Mutual Match $id',
        bio: 'You both matched with each other!',
        profileImage: 'https://images.unsplash.com/photo-1557555187-23d685287bc3?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        matchScore: 0.9,
        isConfirmed: true,
        compatibilityFactors: {
          'Cleanliness': 0.9,
          'Noise Tolerance': 0.85,
          'Study Habits': 0.95,
          'Budget': 0.8,
        },
      );
    });
  }
}