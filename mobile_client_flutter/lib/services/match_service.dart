import 'package:mobile_client_flutter/models/roommate_match.dart';
import 'package:mobile_client_flutter/services/api_client.dart';
import 'package:mobile_client_flutter/services/storage_service.dart';
import 'dart:developer' as developer;

class MatchService {
  final ApiClient _apiClient;
  final StorageService _storage = StorageService();

  MatchService(this._apiClient);

  Future<List<RoommateMatch>> getMatches() async {
    try {
      developer.log('Fetching matches', name: 'MATCH');
      await _apiClient.ensureTokenIsSet();

      final response = await _apiClient.get('/matches/');
      
      if (response.containsKey('matches')) {
        final List<dynamic> matchesJson = response['matches'];
        return matchesJson.map((json) => RoommateMatch.fromJson(json)).toList();
      } else {
        throw Exception('Invalid response format from server');
      }
    } catch (e) {
      developer.log('Error fetching matches: $e', name: 'MATCH');
      throw Exception('Failed to fetch matches: $e');
    }
  }

  Future<RoommateMatch> getMatchById(String id) async {
    try {
      final response = await _apiClient.get('/matches/$id');
      return RoommateMatch.fromJson(response);
    } catch (e) {
      developer.log('Error fetching match by ID: $e', name: 'MATCH');
      throw Exception('Failed to fetch match: $e');
    }
  }

  Future<void> confirmMatch(String matchId) async {
    try {
      await _apiClient.post('/matches/$matchId/confirm', {});
    } catch (e) {
      developer.log('Error confirming match: $e', name: 'MATCH');
      throw Exception('Failed to confirm match: $e');
    }
  }

  Future<void> rejectMatch(String matchId) async {
    try {
      await _apiClient.post('/matches/$matchId/reject', {});
    } catch (e) {
      developer.log('Error rejecting match: $e', name: 'MATCH');
      throw Exception('Failed to reject match: $e');
    }
  }

  Future<void> provideFeedback(String matchId, Map<String, dynamic> feedback) async {
    try {
      await _apiClient.post('/matches/$matchId/feedback', feedback);
    } catch (e) {
      developer.log('Error providing feedback: $e', name: 'MATCH');
      throw Exception('Failed to provide feedback: $e');
    }
  }

  Future<Map<String, dynamic>> getMatchStatistics() async {
    try {
      final response = await _apiClient.get('/matches/statistics');
      return response;
    } catch (e) {
      developer.log('Error fetching match statistics: $e', name: 'MATCH');
      throw Exception('Failed to fetch match statistics: $e');
    }
  }
}