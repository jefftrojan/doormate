import 'package:flutter/foundation.dart';
import 'package:mobile_client_flutter/models/roommate_match.dart';
import 'package:mobile_client_flutter/services/match_service.dart';
import 'dart:developer' as developer;

class MatchProvider extends ChangeNotifier {
  final MatchService _matchService;
  bool _isLoading = false;
  String? _error;
  List<RoommateMatch> _matches = [];
  RoommateMatch? _currentMatch;
  Map<String, dynamic>? _matchStatistics;

  MatchProvider(this._matchService);

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<RoommateMatch> get matches => _matches;
  RoommateMatch? get currentMatch => _currentMatch;
  Map<String, dynamic>? get matchStatistics => _matchStatistics;
  
  // Getters for filtered matches
  List<RoommateMatch> get confirmedMatches => _matches.where((match) => match.isConfirmed).toList();
  List<RoommateMatch> get pendingMatches => _matches.where((match) => !match.isConfirmed).toList();
  
  // Getter for match count
  int get matchCount => _matches.length;
  int get confirmedMatchCount => confirmedMatches.length;
  int get pendingMatchCount => pendingMatches.length;

  Future<void> fetchMatches() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      developer.log('Fetching matches', name: 'MATCH_PROVIDER');
      
      try {
        // Try to get real data from the backend
        _matches = await _matchService.getMatches();
        developer.log('Successfully fetched ${_matches.length} matches from backend', name: 'MATCH_PROVIDER');
      } catch (e) {
        developer.log('Error fetching matches from backend: $e', name: 'MATCH_PROVIDER');
        // If there's an error, throw it to be caught by the outer try-catch
        rethrow;
      }
    } catch (e) {
      developer.log('Error in fetchMatches: $e', name: 'MATCH_PROVIDER');
      _error = 'Failed to load matches. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMatchById(String id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      developer.log('Fetching match with ID: $id', name: 'MATCH_PROVIDER');
      
      // First try to find the match in the existing list for efficiency
      final existingMatch = _matches.firstWhere(
        (match) => match.id == id,
        orElse: () => null as RoommateMatch,
      );
      
      if (existingMatch != null) {
        developer.log('Found match in existing list', name: 'MATCH_PROVIDER');
        _currentMatch = existingMatch;
      } else {
        // If not found in the list, fetch from the backend
        try {
          _currentMatch = await _matchService.getMatchById(id);
          developer.log('Successfully fetched match from backend', name: 'MATCH_PROVIDER');
        } catch (e) {
          developer.log('Error fetching match from backend: $e', name: 'MATCH_PROVIDER');
          // If there's an error, throw it to be caught by the outer try-catch
          rethrow;
        }
      }
    } catch (e) {
      developer.log('Error in fetchMatchById: $e', name: 'MATCH_PROVIDER');
      _error = 'Failed to load match details. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> confirmMatch(String matchId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      developer.log('Confirming match with ID: $matchId', name: 'MATCH_PROVIDER');
      
      try {
        // Confirm the match on the backend
        await _matchService.confirmMatch(matchId);
        developer.log('Successfully confirmed match on backend', name: 'MATCH_PROVIDER');
        
        // Update the match in the local list
        final index = _matches.indexWhere((match) => match.id == matchId);
        if (index != -1) {
          final updatedMatch = RoommateMatch(
            id: _matches[index].id,
            userId: _matches[index].userId,
            matchedUserId: _matches[index].matchedUserId,
            compatibilityScore: _matches[index].compatibilityScore,
            compatibilityBreakdown: _matches[index].compatibilityBreakdown,
            createdAt: _matches[index].createdAt,
            isConfirmed: true,
            matchedUser: _matches[index].matchedUser,
            listingDetails: _matches[index].listingDetails,
          );
          
          _matches[index] = updatedMatch;
          
          if (_currentMatch?.id == matchId) {
            _currentMatch = updatedMatch;
          }
        }
        
        return true;
      } catch (e) {
        developer.log('Error confirming match on backend: $e', name: 'MATCH_PROVIDER');
        // If there's an error, throw it to be caught by the outer try-catch
        rethrow;
      }
    } catch (e) {
      developer.log('Error in confirmMatch: $e', name: 'MATCH_PROVIDER');
      _error = 'Failed to confirm match. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> rejectMatch(String matchId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      developer.log('Rejecting match with ID: $matchId', name: 'MATCH_PROVIDER');
      
      try {
        // Reject the match on the backend
        await _matchService.rejectMatch(matchId);
        developer.log('Successfully rejected match on backend', name: 'MATCH_PROVIDER');
        
        // Remove the match from the local list
        _matches.removeWhere((match) => match.id == matchId);
        
        if (_currentMatch?.id == matchId) {
          _currentMatch = null;
        }
        
        return true;
      } catch (e) {
        developer.log('Error rejecting match on backend: $e', name: 'MATCH_PROVIDER');
        // If there's an error, throw it to be caught by the outer try-catch
        rethrow;
      }
    } catch (e) {
      developer.log('Error in rejectMatch: $e', name: 'MATCH_PROVIDER');
      _error = 'Failed to reject match. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> provideFeedback(String matchId, Map<String, dynamic> feedback) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      developer.log('Providing feedback for match with ID: $matchId', name: 'MATCH_PROVIDER');
      
      try {
        // Send feedback to the backend
        await _matchService.provideFeedback(matchId, feedback);
        developer.log('Successfully provided feedback', name: 'MATCH_PROVIDER');
        return true;
      } catch (e) {
        developer.log('Error providing feedback: $e', name: 'MATCH_PROVIDER');
        // If there's an error, throw it to be caught by the outer try-catch
        rethrow;
      }
    } catch (e) {
      developer.log('Error in provideFeedback: $e', name: 'MATCH_PROVIDER');
      _error = 'Failed to submit feedback. Please try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> fetchMatchStatistics() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      developer.log('Fetching match statistics', name: 'MATCH_PROVIDER');
      
      try {
        // Get match statistics from the backend
        _matchStatistics = await _matchService.getMatchStatistics();
        developer.log('Successfully fetched match statistics', name: 'MATCH_PROVIDER');
      } catch (e) {
        developer.log('Error fetching match statistics: $e', name: 'MATCH_PROVIDER');
        // If there's an error, throw it to be caught by the outer try-catch
        rethrow;
      }
    } catch (e) {
      developer.log('Error in fetchMatchStatistics: $e', name: 'MATCH_PROVIDER');
      _error = 'Failed to load match statistics. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> refreshMatches() async {
    _error = null;
    await fetchMatches();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  void clearCurrentMatch() {
    _currentMatch = null;
    notifyListeners();
  }
} 