import 'package:flutter/foundation.dart';
import 'package:mobile_client_flutter/models/roommate_match.dart';
import 'package:mobile_client_flutter/services/match_service.dart';
import 'dart:developer' as developer;

class MatchProvider extends ChangeNotifier {
  final MatchService _matchService;
  bool _isLoading = false;
  String? _error;
  List<RoommateMatch> _matches = [];
  List<RoommateMatch> _potentialMatches = []; // New: potential roommate matches
  List<RoommateMatch> _mutualMatches = [];    // New: mutual matches
  RoommateMatch? _currentMatch;
  Map<String, dynamic>? _matchStatistics;

  MatchProvider(this._matchService);

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<RoommateMatch> get matches => _matches;
  List<RoommateMatch> get potentialMatches => _potentialMatches; // New getter
  List<RoommateMatch> get mutualMatches => _mutualMatches;       // New getter
  RoommateMatch? get currentMatch => _currentMatch;
  Map<String, dynamic>? get matchStatistics => _matchStatistics;
  
  // Getters for filtered matches
  List<RoommateMatch> get confirmedMatches => _matches.where((match) => match.isConfirmed).toList();
  List<RoommateMatch> get pendingMatches => _matches.where((match) => !match.isConfirmed).toList();
  
  // Getter for match count
  int get matchCount => _matches.length;
  int get confirmedMatchCount => confirmedMatches.length;
  int get pendingMatchCount => pendingMatches.length;
  int get potentialMatchCount => _potentialMatches.length;      // New count
  int get mutualMatchCount => _mutualMatches.length;            // New count

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

  // New method for fetching potential roommate matches
  Future<void> fetchPotentialMatches() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      developer.log('Fetching potential roommate matches', name: 'MATCH_PROVIDER');
      
      try {
        _potentialMatches = await _matchService.getPotentialMatches();
        developer.log('Successfully fetched ${_potentialMatches.length} potential matches', name: 'MATCH_PROVIDER');
      } catch (e) {
        developer.log('Error fetching potential matches: $e', name: 'MATCH_PROVIDER');
        rethrow;
      }
    } catch (e) {
      developer.log('Error in fetchPotentialMatches: $e', name: 'MATCH_PROVIDER');
      _error = 'Failed to load potential roommate matches. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // New method for fetching mutual matches
  Future<void> fetchMutualMatches() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      developer.log('Fetching mutual matches', name: 'MATCH_PROVIDER');
      
      try {
        _mutualMatches = await _matchService.getMutualMatches();
        developer.log('Successfully fetched ${_mutualMatches.length} mutual matches', name: 'MATCH_PROVIDER');
      } catch (e) {
        developer.log('Error fetching mutual matches: $e', name: 'MATCH_PROVIDER');
        rethrow;
      }
    } catch (e) {
      developer.log('Error in fetchMutualMatches: $e', name: 'MATCH_PROVIDER');
      _error = 'Failed to load mutual matches. Please try again.';
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
      
      // First try to find the match in the existing lists for efficiency
      RoommateMatch? existingMatch = _findMatchInAllLists(id);
      
      if (existingMatch != null) {
        developer.log('Found match in existing lists', name: 'MATCH_PROVIDER');
        _currentMatch = existingMatch;
      } else {
        // If not found in the lists, fetch from the backend
        try {
          _currentMatch = await _matchService.getMatchById(id);
          developer.log('Successfully fetched match from backend', name: 'MATCH_PROVIDER');
        } catch (e) {
          developer.log('Error fetching match from backend: $e', name: 'MATCH_PROVIDER');
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

  // Helper method to find a match in all lists
  RoommateMatch? _findMatchInAllLists(String id) {
    // Check in regular matches
    try {
      return _matches.firstWhere((match) => match.id == id);
    } catch (_) {
      // Not found in regular matches, continue
    }
    
    // Check in potential matches
    try {
      return _potentialMatches.firstWhere((match) => match.id == id);
    } catch (_) {
      // Not found in potential matches, continue
    }
    
    // Check in mutual matches
    try {
      return _mutualMatches.firstWhere((match) => match.id == id);
    } catch (_) {
      // Not found in mutual matches
      return null;
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
        final result = await _matchService.confirmMatch(matchId);
        developer.log('Successfully confirmed match on backend: $result', name: 'MATCH_PROVIDER');
        
        // Update the match in the potential matches list
        final index = _potentialMatches.indexWhere((match) => match.id == matchId);
        if (index != -1) {
          // Check if it's a mutual match - handle different result formats
          bool isMutualMatch = false;
          
          if (result is Map<String, dynamic> && result.containsKey('mutual_match')) {
            isMutualMatch = result['mutual_match'] == true;
          } else if (result is bool) {
            isMutualMatch = result;
          }
          
          if (isMutualMatch) {
            // Add to mutual matches
            _mutualMatches.add(_potentialMatches[index]);
            developer.log('Added match to mutual matches', name: 'MATCH_PROVIDER');
          }
          
          // Remove from potential matches
          _potentialMatches.removeAt(index);
        }
        
        // Update traditional matches
        final regularIndex = _matches.indexWhere((match) => match.id == matchId);
        if (regularIndex != -1) {
          final updatedMatch = RoommateMatch(
            id: _matches[regularIndex].id,
            userId: _matches[regularIndex].userId,
            matchedUserId: _matches[regularIndex].matchedUserId,
            name: _matches[regularIndex].name,
            matchScore: _matches[regularIndex].matchScore,
            compatibilityFactors: _matches[regularIndex].compatibilityFactors,
            isConfirmed: true,
            profileImage: _matches[regularIndex].profileImage,
            bio: _matches[regularIndex].bio,
            matchedUser: _matches[regularIndex].matchedUser,
          );
          
          _matches[regularIndex] = updatedMatch;
          
          if (_currentMatch?.id == matchId) {
            _currentMatch = updatedMatch;
          }
        }
        
        return true;
      } catch (e) {
        developer.log('Error confirming match on backend: $e', name: 'MATCH_PROVIDER');
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
        
        // Remove the match from all lists
        _matches.removeWhere((match) => match.id == matchId);
        _potentialMatches.removeWhere((match) => match.id == matchId);
        _mutualMatches.removeWhere((match) => match.id == matchId);
        
        if (_currentMatch?.id == matchId) {
          _currentMatch = null;
        }
        
        return true;
      } catch (e) {
        developer.log('Error rejecting match on backend: $e', name: 'MATCH_PROVIDER');
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
  
  // Refresh methods
  Future<void> refreshMatches() async {
    _error = null;
    await fetchMatches();
  }
  
  Future<void> refreshPotentialMatches() async {
    _error = null;
    await fetchPotentialMatches();
  }
  
  Future<void> refreshMutualMatches() async {
    _error = null;
    await fetchMutualMatches();
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