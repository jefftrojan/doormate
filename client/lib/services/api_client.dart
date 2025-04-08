import 'package:dio/dio.dart';
import 'package:mobile_client_flutter/services/storage_service.dart';
import 'dart:developer' as developer;
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
class ApiClient {
  // Update baseUrl to use your container's address
  static String baseUrl = kIsWeb
      ? 'http://localhost:8001/api'  // Web platform
      : (Platform.isAndroid 
          ? 'http://10.0.2.2:8001/api'  // Android emulator
          : 'http://localhost:8001/api'); // iOS simulator
  
  final Dio _dio;
  String? _authToken;
  final StorageService _storage = StorageService();
  
  // Disable mock mode
  bool _useMockData = false;
  
  // Singleton pattern
  static final ApiClient _instance = ApiClient._internal();
  
  factory ApiClient() {
    return _instance;
  }
  
  ApiClient._internal() : _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    validateStatus: (status) => status! < 500,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  )) {
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (object) => developer.log(object.toString(), name: 'API'),
    ));
  }

  bool get useMockData => _useMockData;
  
  void setMockMode(bool useMock) {
    _useMockData = useMock;
    developer.log('Mock mode set to: $_useMockData', name: 'API');
  }

  void setAuthToken(String token) {
    _authToken = token;
    _dio.options.headers['Authorization'] = 'Bearer $token';
    developer.log('Auth token set', name: 'API');
  }

  void clearAuthToken() {
    _authToken = null;
    _dio.options.headers.remove('Authorization');
    developer.log('Auth token cleared', name: 'API');
  }

  // Ensure token is set before making API calls
  Future<void> ensureTokenIsSet() async {
    if (_authToken == null) {
      final token = await _storage.getToken();
      if (token != null) {
        setAuthToken(token);
      } else {
        developer.log('No auth token available', name: 'API');
      }
    }
  }

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data, {
    bool requireAuth = true,
  }) async {
    try {
      if (requireAuth) {
        await ensureTokenIsSet();
      }
      
      developer.log('POST request to $endpoint', name: 'API');
      final response = await _dio.post(endpoint, data: data);
      
      if (response.statusCode! >= 400) {
        _handleErrorResponse(response, endpoint);
      }
      
      return response.data is Map ? Map<String, dynamic>.from(response.data) : {'data': response.data};
    } on DioException catch (e) {
      return _handleDioException(e, endpoint);
    } catch (e) {
      developer.log('Unexpected error during POST to $endpoint: $e', name: 'API');
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data, {
    bool requireAuth = true,
  }) async {
    try {
      if (requireAuth) {
        await ensureTokenIsSet();
      }
      
      developer.log('PUT request to $endpoint', name: 'API');
      final response = await _dio.put(endpoint, data: data);
      
      if (response.statusCode! >= 400) {
        _handleErrorResponse(response, endpoint);
      }
      
      return response.data is Map ? Map<String, dynamic>.from(response.data) : {'data': response.data};
    } on DioException catch (e) {
      return _handleDioException(e, endpoint);
    } catch (e) {
      developer.log('Unexpected error during PUT to $endpoint: $e', name: 'API');
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    bool requireAuth = true,
  }) async {
    try {
      if (requireAuth) {
        await ensureTokenIsSet();
      }
      
      developer.log('GET request to $endpoint with params: $queryParameters', name: 'API');
      
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
      );
      
      if (response.statusCode! >= 400) {
        _handleErrorResponse(response, endpoint);
      }
      
      return response.data is Map ? Map<String, dynamic>.from(response.data) : {'data': response.data};
    } on DioException catch (e) {
      return _handleDioException(e, endpoint);
    } catch (e) {
      developer.log('Unexpected error during GET to $endpoint: $e', name: 'API');
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<Map<String, dynamic>> delete(
    String endpoint, {
    bool requireAuth = true,
  }) async {
    try {
      if (requireAuth) {
        await ensureTokenIsSet();
      }
      
      developer.log('DELETE request to $endpoint', name: 'API');
      
      final response = await _dio.delete(endpoint);
      
      if (response.statusCode! >= 400) {
        _handleErrorResponse(response, endpoint);
      }
      
      return response.data is Map ? Map<String, dynamic>.from(response.data) : {'data': response.data};
    } on DioException catch (e) {
      return _handleDioException(e, endpoint);
    } catch (e) {
      developer.log('Unexpected error during DELETE to $endpoint: $e', name: 'API');
      throw Exception('An unexpected error occurred: $e');
    }
  }
  
  void _handleErrorResponse(Response response, String endpoint) {
    final statusCode = response.statusCode;
    final errorMessage = response.data is Map && response.data['detail'] != null
        ? response.data['detail']
        : 'Request failed with status: $statusCode';
    
    developer.log('Error response from $endpoint: $statusCode - $errorMessage', name: 'API');
    
    if (statusCode == 401) {
      // Clear token on unauthorized
      clearAuthToken();
      throw Exception('Unauthorized: Please log in again');
    } else if (statusCode == 403) {
      throw Exception('Forbidden: You do not have permission to access this resource');
    } else if (statusCode == 404) {
      throw Exception('Not Found');
    } else if (statusCode == 400) {
      throw Exception('Bad Request: $errorMessage');
    } else {
      throw Exception(errorMessage);
    }
  }
  
  Map<String, dynamic> _handleDioException(DioException e, String endpoint) {
    developer.log('DioException during request to $endpoint: ${e.type} - ${e.message}', name: 'API');
    
    // Provide detailed error messages
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw Exception('Connection timeout. Please check your internet connection.');
      case DioExceptionType.connectionError:
        throw Exception('Connection error. Please check your internet connection.');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final errorMessage = e.response?.data is Map && e.response?.data['detail'] != null
            ? e.response?.data['detail']
            : 'Request failed with status: $statusCode';
        
        if (statusCode == 401) {
          throw Exception('Unauthorized: Please log in again');
        } else if (statusCode == 403) {
          throw Exception('Forbidden: You do not have permission to access this resource');
        } else if (statusCode == 404) {
          throw Exception('Resource not found');
        } else if (statusCode == 400) {
          throw Exception('Bad Request: $errorMessage');
        } else {
          throw Exception('Server error: $errorMessage');
        }
      default:
        throw Exception('Network error: ${e.message}');
    }
  }
}