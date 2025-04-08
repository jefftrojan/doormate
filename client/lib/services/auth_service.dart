import 'package:mobile_client_flutter/services/api_client.dart';
import 'package:mobile_client_flutter/services/storage_service.dart';
import 'dart:developer' as developer;

class AuthService {
  final ApiClient _apiClient;
  final StorageService _storage = StorageService();

  AuthService(this._apiClient);

  static const List<Map<String, dynamic>> rwandanUniversities = [
    {"name": "University of Rwanda", "domains": ["ur.ac.rw"]},
    {"name": "INES Ruhengeri", "domains": ["ines.ac.rw"]},
    {"name": "African Leadership University", "domains": ["alustudent.com"]},
    {"name": "Mount Kenya University Rwanda", "domains": ["mkur.ac.rw"]},
    {"name": "Carnegie Mellon University Africa", "domains": ["africa.cmu.edu"]},
    {"name": "Adventist University of Central Africa", "domains": ["auca.ac.rw"]},
    {"name": "KIM University", "domains": ["kim.ac.rw"]},
    {"name": "University of Kigali", "domains": ["uok.ac.rw"]},
    {"name": "University of Lay Adventists of Kigali", "domains": ["unilak.ac.rw"]},
  ];

  // Add login method
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      developer.log('Attempting login for email: $email', name: 'AUTH');
      
      final response = await _apiClient.post('/auth/login', {
        'email': email,
        'password': password,
      }, requireAuth: false);

      if (response['token'] != null) {
        await _storage.saveToken(response['token']);
        // Set the token in the API client for subsequent requests
        _apiClient.setAuthToken(response['token']);
        if (response['user'] != null) {
          await _storage.saveUserData(response['user']);
          developer.log('User logged in successfully: ${response['user']['email']}', name: 'AUTH');
        }
      } else {
        developer.log('Login response did not contain token', name: 'AUTH');
        throw Exception('Login failed: No authentication token received');
      }

      return response;
    } catch (e) {
      developer.log('Login error: $e', name: 'AUTH');
      if (e.toString().contains('Invalid credentials')) {
        throw 'Invalid email or password. Please try again.';
      }
      rethrow;
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await _storage.getToken();
    final isValid = token != null;
    developer.log('Checking login status: $isValid', name: 'AUTH');
    return isValid;
  }

  // Get current user data
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      // First try to get from local storage
      final localUserData = await _storage.getUserData();
      
      // If we have a token, try to get fresh data from the server
      if (await _storage.getToken() != null) {
        try {
          final response = await _apiClient.get('/users/me');
          if (response['user'] != null) {
            // Update local storage with fresh data
            await _storage.saveUserData(response['user']);
            developer.log('Retrieved fresh user data from server', name: 'AUTH');
            return response['user'];
          }
        } catch (e) {
          developer.log('Error fetching user data from server: $e', name: 'AUTH');
          // If server fetch fails, fall back to local data
        }
      }
      
      return localUserData;
    } catch (e) {
      developer.log('Error in getCurrentUser: $e', name: 'AUTH');
      return null;
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      // Try to notify the server about logout
      try {
        await _apiClient.post('/auth/logout', {});
      } catch (e) {
        developer.log('Error notifying server about logout: $e', name: 'AUTH');
        // Continue with local logout even if server notification fails
      }
      
      await _storage.deleteToken();
      await _storage.deleteUserData();
      _apiClient.clearAuthToken();
      developer.log('User logged out successfully', name: 'AUTH');
    } catch (e) {
      developer.log('Error during logout: $e', name: 'AUTH');
      // Still clear local data even if there was an error
      await _storage.deleteToken();
      await _storage.deleteUserData();
      _apiClient.clearAuthToken();
    }
  }

  Future<void> register(String email) async {
    try {
      developer.log('Attempting to register user with email: $email', name: 'AUTH');
      
      // Create a more complete user profile using the register endpoint
      final response = await _apiClient.post('/auth/register', {
        'email': email,
        'password': 'Temp@123456',
        'first_name': 'New',
        'last_name': 'User',
        'university': getUniversityName(email) ?? 'Unknown University',
        'fullName': 'New User',
        'yearOfStudy': '1',
        'studentId': 'temp' + DateTime.now().millisecondsSinceEpoch.toString().substring(0, 6)
      }, requireAuth: false);
      
      developer.log('Registration response: $response', name: 'AUTH');
      
      // Wait a moment to ensure the user is fully registered in the database
      await Future.delayed(const Duration(seconds: 1));
      
    } catch (e) {
      // If the error contains "already exists", we can ignore it
      if (e.toString().contains('already exists')) {
        developer.log('User already exists, continuing with verification', name: 'AUTH');
        return;
      }
      // Otherwise, rethrow the error
      developer.log('Error during registration: $e', name: 'AUTH');
      rethrow;
    }
  }

  Future<void> verifyEmail(String email) async {
    try {
      developer.log('Attempting to verify email: $email', name: 'AUTH');
      
      // First, ensure the user is registered
      await register(email);
      
      // Use the new mobile-otp endpoint to send OTP
      try {
        final response = await _apiClient.post('/auth/mobile-otp', {
          'email': email,
          'action': 'send'
        }, requireAuth: false);
        
        developer.log('Send OTP response using mobile-otp endpoint: $response', name: 'AUTH');
      } catch (e) {
        // Fall back to the old endpoint if the new one fails
        developer.log('Error with mobile-otp endpoint, falling back to send-otp: $e', name: 'AUTH');
        try {
          final response = await _apiClient.post('/auth/send-otp', {
            'email': email,
          }, requireAuth: false);
          
          developer.log('Send OTP response: $response', name: 'AUTH');
        } catch (e) {
          developer.log('Error sending OTP (may be expected if generated during registration): $e', name: 'AUTH');
          // Continue since OTP might be generated during registration
        }
      }
      
      developer.log('Email verification process completed', name: 'AUTH');
    } catch (e) {
      developer.log('Error during email verification: $e', name: 'AUTH');
      rethrow;
    }
  }

  Future<void> resendVerificationCode(String email) async {
    try {
      developer.log('Attempting to resend verification code for email: $email', name: 'AUTH');
      
      // Try the new mobile-otp endpoint first
      try {
        final response = await _apiClient.post('/auth/mobile-otp', {
          'email': email,
          'action': 'send'
        }, requireAuth: false);
        
        developer.log('Resend OTP response using mobile-otp endpoint: $response', name: 'AUTH');
        return;
      } catch (e) {
        developer.log('Error with mobile-otp endpoint, falling back to resend-otp: $e', name: 'AUTH');
        
        // Try explicit resend endpoint next
        try {
          final response = await _apiClient.post('/auth/resend-otp', {
            'email': email,
          }, requireAuth: false);
          
          developer.log('Resend OTP response: $response', name: 'AUTH');
          return;
        } catch (e) {
          developer.log('Error with resend OTP endpoint: $e', name: 'AUTH');
          // Fall back to registration method if resend endpoint fails
        }
      }
      
      // Since the register endpoint generates an OTP, we'll use it to resend the code
      await register(email);
      developer.log('Verification code resent via registration', name: 'AUTH');
    } catch (e) {
      developer.log('Error resending verification code: $e', name: 'AUTH');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> verifyCode(String email, String code) async {
    try {
      developer.log('Verifying code for email: $email with code: $code', name: 'AUTH');
      
      // Try the new mobile-otp endpoint first
      try {
        final response = await _apiClient.post('/auth/mobile-otp', {
          'email': email,
          'action': 'verify',
          'otp': code
        }, requireAuth: false);
        
        developer.log('OTP verification response using mobile-otp endpoint: $response', name: 'AUTH');
        
        // Save token and user data
        if (response['token'] != null) {
          await _storage.saveToken(response['token']);
          // Set the token in the API client for subsequent requests
          _apiClient.setAuthToken(response['token']);
          if (response['user'] != null) {
            await _storage.saveUserData(response['user']);
          }
          return response;
        } else {
          throw Exception('No token received from server');
        }
      } catch (e) {
        developer.log('Mobile-otp verification failed, falling back to verify endpoint: $e', name: 'AUTH');
        
        // Fall back to the old verify endpoint
        try {
          final response = await _apiClient.post('/auth/verify', {
            'email': email,
            'otp': code,
          }, requireAuth: false);
          
          developer.log('OTP verification response: $response', name: 'AUTH');
          
          // Save token and user data
          if (response['token'] != null) {
            await _storage.saveToken(response['token']);
            // Set the token in the API client for subsequent requests
            _apiClient.setAuthToken(response['token']);
            if (response['user'] != null) {
              await _storage.saveUserData(response['user']);
            }
            return response;
          } else {
            throw Exception('No token received from server');
          }
        } catch (e) {
          developer.log('First verification attempt failed: $e', name: 'AUTH');
          
          // If the error is "User not found", try to create the user and then verify again
          if (e.toString().contains('User not found')) {
            developer.log('User not found, attempting to create user and verify again', name: 'AUTH');
            
            // Try to register the user again
            await register(email);
            
            // Wait a moment to ensure the user is fully registered
            await Future.delayed(const Duration(seconds: 1));
            
            // Try verification again
            final secondResponse = await _apiClient.post('/auth/verify', {
              'email': email,
              'otp': code,
            }, requireAuth: false);
            
            developer.log('Second OTP verification response: $secondResponse', name: 'AUTH');
            
            // Save token and user data
            if (secondResponse['token'] != null) {
              await _storage.saveToken(secondResponse['token']);
              // Set the token in the API client for subsequent requests
              _apiClient.setAuthToken(secondResponse['token']);
              if (secondResponse['user'] != null) {
                await _storage.saveUserData(secondResponse['user']);
              }
              return secondResponse;
            } else {
              throw Exception('No token received from server on second attempt');
            }
          } else {
            // If it's some other error, rethrow it
            rethrow;
          }
        }
      }
    } catch (e) {
      developer.log('Error during code verification: $e', name: 'AUTH');
      
      if (e.toString().contains('User not found')) {
        throw 'User account not found. Please try registering again with a different email.';
      } else if (e.toString().contains('Invalid or expired OTP')) {
        throw 'The verification code has expired or is invalid. Please try again.';
      } else {
        throw 'Verification failed: ${e.toString()}';
      }
    }
  }

  static String? getUniversityName(String email) {
    for (var university in rwandanUniversities) {
      for (var domain in university['domains'] as List<String>) {
        if (email.toLowerCase().endsWith(domain)) {
          return university['name'] as String;
        }
      }
    }
    return null;
  }

  static bool isValidUniversityEmail(String email) {
    return getUniversityName(email) != null;
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> profileData) async {
    try {
      developer.log('Updating user profile: $profileData', name: 'AUTH');
      
      final response = await _apiClient.put('/profile/update', profileData);
      
      if (response['user'] != null) {
        // Update local storage with updated user data
        await _storage.saveUserData(response['user']);
        developer.log('Profile updated successfully', name: 'AUTH');
      } else {
        developer.log('Profile update response did not contain user data', name: 'AUTH');
      }
      
      return response;
    } catch (e) {
      developer.log('Error updating profile: $e', name: 'AUTH');
      rethrow;
    }
  }

  Future<void> updatePassword(String currentPassword, String newPassword) async {
    try {
      developer.log('Updating user password', name: 'AUTH');
      
      await _apiClient.put('/users/update-password', {
        'current_password': currentPassword,
        'new_password': newPassword,
      });
      
      developer.log('Password updated successfully', name: 'AUTH');
    } catch (e) {
      developer.log('Error updating password: $e', name: 'AUTH');
      if (e.toString().contains('Invalid password')) {
        throw 'Current password is incorrect. Please try again.';
      }
      rethrow;
    }
  }

  Future<void> setInitialPassword(String newPassword) async {
    try {
      developer.log('Setting initial password', name: 'AUTH');
      
      await _apiClient.put('/profile/set-initial-password', {
        'new_password': newPassword,
      });
      
      developer.log('Initial password set successfully', name: 'AUTH');
    } catch (e) {
      developer.log('Error setting initial password: $e', name: 'AUTH');
      rethrow;
    }
  }

  Future<void> requestPasswordReset(String email) async {
    try {
      developer.log('Requesting password reset for email: $email', name: 'AUTH');
      
      await _apiClient.post('/auth/reset-password-request', {
        'email': email,
      }, requireAuth: false);
      
      developer.log('Password reset request sent successfully', name: 'AUTH');
    } catch (e) {
      developer.log('Error requesting password reset: $e', name: 'AUTH');
      rethrow;
    }
  }

  Future<void> resetPassword(String email, String code, String newPassword) async {
    try {
      developer.log('Resetting password for email: $email', name: 'AUTH');
      
      await _apiClient.post('/auth/reset-password', {
        'email': email,
        'code': code,
        'new_password': newPassword,
      }, requireAuth: false);
      
      developer.log('Password reset successfully', name: 'AUTH');
    } catch (e) {
      developer.log('Error resetting password: $e', name: 'AUTH');
      if (e.toString().contains('Invalid or expired code')) {
        throw 'The reset code has expired or is invalid. Please request a new code.';
      }
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    try {
      developer.log('Deleting user account', name: 'AUTH');
      
      await _apiClient.delete('/users/account');
      
      // Clear local data
      await _storage.deleteToken();
      await _storage.deleteUserData();
      _apiClient.clearAuthToken();
      
      developer.log('Account deleted successfully', name: 'AUTH');
    } catch (e) {
      developer.log('Error deleting account: $e', name: 'AUTH');
      rethrow;
    }
  }
}