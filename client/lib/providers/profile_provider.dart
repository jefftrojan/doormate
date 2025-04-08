import 'package:flutter/foundation.dart';
import 'package:mobile_client_flutter/services/auth_service.dart';
import 'dart:developer' as developer;

class ProfileProvider extends ChangeNotifier {
  final AuthService _authService;
  bool _isLoading = false;
  String? _error;
  bool _isLoggedIn = false;
  Map<String, dynamic>? _userData;
  bool _isProfileComplete = false;

  ProfileProvider(this._authService) {
    // Check if user is already logged in
    _checkLoginStatus();
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _isLoggedIn;
  Map<String, dynamic>? get userData => _userData;
  bool get isProfileComplete => _isProfileComplete;

  // Getters for specific user data
  String get fullName => _userData?['fullName'] ?? '${_userData?['first_name'] ?? ''} ${_userData?['last_name'] ?? ''}';
  String get email => _userData?['email'] ?? '';
  String get university => _userData?['university'] ?? '';
  String get yearOfStudy => _userData?['yearOfStudy']?.toString() ?? '';
  String get studentId => _userData?['studentId'] ?? '';
  String? get profileImageUrl => _userData?['profile_image'];
  String? get bio => _userData?['bio'];
  List<String> get interests => _userData?['interests'] != null 
      ? List<String>.from(_userData?['interests']) 
      : [];

  Future<void> _checkLoginStatus() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      _isLoggedIn = await _authService.isLoggedIn();
      
      if (_isLoggedIn) {
        await _fetchUserData();
      }
    } catch (e) {
      developer.log('Error checking login status: $e', name: 'PROFILE');
      _error = 'Failed to check login status';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> _fetchUserData() async {
    try {
      final userData = await _authService.getCurrentUser();
      if (userData != null) {
        _userData = userData;
        _checkProfileCompleteness();
        developer.log('User data fetched successfully', name: 'PROFILE');
      } else {
        developer.log('No user data available', name: 'PROFILE');
      }
    } catch (e) {
      developer.log('Error fetching user data: $e', name: 'PROFILE');
    }
  }
  
  void _checkProfileCompleteness() {
    // Define what constitutes a complete profile
    final requiredFields = [
      'first_name', 
      'last_name', 
      'email', 
      'university', 
      'yearOfStudy', 
      'studentId'
    ];
    
    bool isComplete = true;
    for (final field in requiredFields) {
      if (_userData == null || _userData![field] == null || _userData![field].toString().isEmpty) {
        isComplete = false;
        break;
      }
    }
    
    _isProfileComplete = isComplete;
  }

  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _authService.login(email, password);
      _isLoggedIn = true;
      _userData = response['user'];
      _checkProfileCompleteness();
      developer.log('User logged in successfully', name: 'PROFILE');
      return true;
    } catch (e) {
      developer.log('Login error: $e', name: 'PROFILE');
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.logout();
      _isLoggedIn = false;
      _userData = null;
      _isProfileComplete = false;
      developer.log('User logged out successfully', name: 'PROFILE');
    } catch (e) {
      developer.log('Logout error: $e', name: 'PROFILE');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> profileData) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _authService.updateProfile(profileData);
      _userData = response['user'];
      _checkProfileCompleteness();
      developer.log('Profile updated successfully', name: 'PROFILE');
      return true;
    } catch (e) {
      developer.log('Profile update error: $e', name: 'PROFILE');
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> updatePassword(String currentPassword, String newPassword) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authService.updatePassword(currentPassword, newPassword);
      developer.log('Password updated successfully', name: 'PROFILE');
      return true;
    } catch (e) {
      developer.log('Password update error: $e', name: 'PROFILE');
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> setInitialPassword(String newPassword) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authService.setInitialPassword(newPassword);
      developer.log('Initial password set successfully', name: 'PROFILE');
      return true;
    } catch (e) {
      developer.log('Setting initial password error: $e', name: 'PROFILE');
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> requestPasswordReset(String email) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authService.requestPasswordReset(email);
      developer.log('Password reset requested successfully', name: 'PROFILE');
      return true;
    } catch (e) {
      developer.log('Password reset request error: $e', name: 'PROFILE');
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> resetPassword(String email, String code, String newPassword) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authService.resetPassword(email, code, newPassword);
      developer.log('Password reset successfully', name: 'PROFILE');
      return true;
    } catch (e) {
      developer.log('Password reset error: $e', name: 'PROFILE');
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<bool> deleteAccount() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _authService.deleteAccount();
      _isLoggedIn = false;
      _userData = null;
      _isProfileComplete = false;
      developer.log('Account deleted successfully', name: 'PROFILE');
      return true;
    } catch (e) {
      developer.log('Account deletion error: $e', name: 'PROFILE');
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> refreshUserData() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await _fetchUserData();
      developer.log('User data refreshed successfully', name: 'PROFILE');
    } catch (e) {
      developer.log('Error refreshing user data: $e', name: 'PROFILE');
      _error = 'Failed to refresh user data';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}