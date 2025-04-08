import 'package:mobile_client_flutter/models/chat_message.dart';
import 'package:mobile_client_flutter/services/api_client.dart';
import 'package:mobile_client_flutter/services/storage_service.dart';
import 'package:uuid/uuid.dart';
import 'dart:developer' as developer;
import 'dart:math' as math;

class AIAssistantService {
  final ApiClient _apiClient;
  final StorageService _storage = StorageService();
  final Uuid _uuid = const Uuid();
  static const String AI_CHAT_ID = 'ai-assistant';
  
  AIAssistantService(this._apiClient);

  Future<ChatMessage> sendMessage(String content) async {
    developer.log('Sending message to AI assistant: $content', name: 'AI_ASSISTANT');
    
    final userMessage = ChatMessage(
      id: _uuid.v4(),
      chatId: AI_CHAT_ID,
      senderId: 'current-user-id',
      content: content,
      timestamp: DateTime.now(),
      isRead: true,
    );

    try {
      // Ensure token is set in API client
      await _apiClient.ensureTokenIsSet();

      final response = await _apiClient.post('/ai/chat/', {
        'message': content,
        'context': 'roommate_matching', // Provide context to the AI
      });

      if (response.containsKey('response')) {
        final assistantMessage = ChatMessage(
          id: _uuid.v4(),
          chatId: AI_CHAT_ID,
          senderId: 'ai-assistant',
          content: response['response'],
          timestamp: DateTime.now(),
          isRead: true,
        );

        developer.log('Received AI response: ${response['response'].substring(0, math.min(50, response['response'].length))}...', name: 'AI_ASSISTANT');
        return assistantMessage;
      } else {
        developer.log('API response did not contain response key', name: 'AI_ASSISTANT');
        
        // If API client is in mock mode, use mock response
        if (_apiClient.useMockData) {
          developer.log('Invalid response format, using mock AI response', name: 'AI_ASSISTANT');
          return await sendMessageMock(content);
        }
        
        throw Exception('Invalid response format');
      }
    } catch (e) {
      developer.log('Error sending message to AI: $e', name: 'AI_ASSISTANT');
      
      // If in mock mode, use mock response
      if (_apiClient.useMockData) {
        developer.log('Using mock AI response', name: 'AI_ASSISTANT');
        return await sendMessageMock(content);
      }
      
      // If the API call fails, return a generic error message
      return ChatMessage(
        id: _uuid.v4(),
        chatId: AI_CHAT_ID,
        senderId: 'ai-assistant',
        content: 'Sorry, I encountered an error processing your request. Please try again later.',
        timestamp: DateTime.now(),
        isRead: true,
      );
    }
  }
  
  Future<List<ChatMessage>> getChatHistory() async {
    try {
      developer.log('Fetching AI chat history', name: 'AI_ASSISTANT');
      
      // Ensure token is set in API client
      await _apiClient.ensureTokenIsSet();

      final response = await _apiClient.get('/ai/chat/history/');
      
      if (response.containsKey('messages')) {
        final List<dynamic> messagesJson = response['messages'];
        
        // If we got an empty list and the API client is in mock mode, use mock data
        if (messagesJson.isEmpty && _apiClient.useMockData) {
          developer.log('Empty chat history from API, using mock data', name: 'AI_ASSISTANT');
          return getMockChatHistory();
        }
        
        final messages = messagesJson.map((json) => ChatMessage.fromJson(json)).toList();
        developer.log('Successfully fetched ${messages.length} AI chat messages', name: 'AI_ASSISTANT');
        return messages;
      } else {
        developer.log('API response did not contain messages key', name: 'AI_ASSISTANT');
        
        // If API client is in mock mode, use mock data
        if (_apiClient.useMockData) {
          developer.log('Invalid response format, using mock chat history', name: 'AI_ASSISTANT');
          return getMockChatHistory();
        }
        
        return [];
      }
    } catch (e) {
      developer.log('Error fetching AI chat history: $e', name: 'AI_ASSISTANT');
      
      // If in mock mode, return mock data
      if (_apiClient.useMockData) {
        developer.log('Using mock AI chat history', name: 'AI_ASSISTANT');
        return getMockChatHistory();
      }
      
      // Return empty list on error
      return [];
    }
  }
  
  Future<void> clearChatHistory() async {
    try {
      developer.log('Clearing AI chat history', name: 'AI_ASSISTANT');
      
      // Ensure token is set in API client
      await _apiClient.ensureTokenIsSet();

      await _apiClient.delete('/ai/chat/history/');
      
      developer.log('Successfully cleared AI chat history', name: 'AI_ASSISTANT');
    } catch (e) {
      developer.log('Error clearing AI chat history: $e', name: 'AI_ASSISTANT');
      // If in mock mode, don't throw the error
      if (!_apiClient.useMockData) {
        rethrow;
      }
    }
  }
  
  Future<Map<String, dynamic>> getAIInsights() async {
    try {
      developer.log('Fetching AI insights', name: 'AI_ASSISTANT');
      
      // Ensure token is set in API client
      await _apiClient.ensureTokenIsSet();

      final response = await _apiClient.get('/ai/insights/');
      
      if (response.isEmpty && _apiClient.useMockData) {
        developer.log('Empty insights from API, using mock data', name: 'AI_ASSISTANT');
        return getMockAIInsights();
      }
      
      developer.log('Successfully fetched AI insights', name: 'AI_ASSISTANT');
      return response;
    } catch (e) {
      developer.log('Error fetching AI insights: $e', name: 'AI_ASSISTANT');
      
      // If in mock mode, return mock data
      if (_apiClient.useMockData) {
        developer.log('Using mock AI insights', name: 'AI_ASSISTANT');
        return getMockAIInsights();
      }
      
      // Return empty map on error
      return {};
    }
  }
  
  Map<String, dynamic> getMockAIInsights() {
    return {
      'top_preferences': [
        {'name': 'Quiet environment', 'count': 45},
        {'name': 'Non-smoker', 'count': 38},
        {'name': 'Clean', 'count': 32},
      ],
      'popular_locations': [
        {'name': 'Near University of Rwanda', 'count': 28},
        {'name': 'Kigali City Center', 'count': 22},
        {'name': 'Nyamirambo', 'count': 15},
      ],
      'average_budget': 320,
      'recommendation': 'Based on your profile, you might want to consider looking for listings in the Kacyiru area, which has good access to public transportation and is popular among students.',
    };
  }

  // For demo purposes, we'll implement a mock method that doesn't require the backend
  Future<ChatMessage> sendMessageMock(String content) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Generate a mock response based on the user's message
    String response;

    if (content.toLowerCase().contains('listing') || 
        content.toLowerCase().contains('apartment') ||
        content.toLowerCase().contains('room')) {
      response = 'I found several listings that might interest you. Here are some options:\n\n1. Cozy Studio near University of Rwanda - \$350/month\n2. Shared 2-Bedroom Apartment - \$250/month\n3. Modern Room in 3-Bedroom House - \$300/month';
    } else if (content.toLowerCase().contains('roommate') || 
               content.toLowerCase().contains('match')) {
      response = 'Based on your preferences, I found these potential roommate matches:\n\n1. John Smith - University of Rwanda (89% compatible)\n2. Emma Wilson - Carnegie Mellon University Africa (76% compatible)\n3. Michael Brown - African Leadership University (92% compatible)';
    } else if (content.toLowerCase().contains('budget') || 
               content.toLowerCase().contains('price') ||
               content.toLowerCase().contains('cost')) {
      response = 'Here\'s a breakdown of average rental prices in different areas:\n\n- Near Campus: \$350/month\n- City Center: \$450/month\n- Suburbs: \$250/month';
    } else if (content.toLowerCase().contains('help') || 
               content.toLowerCase().contains('what can you do')) {
      response = 'I can help you with:\n\n- Finding roommate matches based on your preferences\n- Searching for listings that match your criteria\n- Providing information about different neighborhoods\n- Answering questions about the rental process\n- Offering tips for living with roommates';
    } else {
      response = 'I\'m your DoorMate AI assistant. I can help you find listings, match with roommates, or answer questions about housing. What would you like to know?';
    }

    return ChatMessage(
      id: _uuid.v4(),
      chatId: AI_CHAT_ID,
      senderId: 'ai-assistant',
      content: response,
      timestamp: DateTime.now(),
      isRead: true,
    );
  }
  
  List<ChatMessage> getMockChatHistory() {
    final now = DateTime.now();
    
    return [
      ChatMessage(
        id: _uuid.v4(),
        chatId: AI_CHAT_ID,
        senderId: 'current-user-id',
        content: 'Hello, I need help finding a roommate',
        timestamp: now.subtract(const Duration(days: 2, hours: 3)),
        isRead: true,
      ),
      ChatMessage(
        id: _uuid.v4(),
        chatId: AI_CHAT_ID,
        senderId: 'ai-assistant',
        content: 'Hi there! I\'d be happy to help you find a roommate. Could you tell me a bit about your preferences? For example, are you looking for someone who is quiet, social, a student, or working professional?',
        timestamp: now.subtract(const Duration(days: 2, hours: 3)).add(const Duration(minutes: 1)),
        isRead: true,
      ),
      ChatMessage(
        id: _uuid.v4(),
        chatId: AI_CHAT_ID,
        senderId: 'current-user-id',
        content: 'I prefer someone quiet who studies at the University of Rwanda',
        timestamp: now.subtract(const Duration(days: 2, hours: 2)),
        isRead: true,
      ),
      ChatMessage(
        id: _uuid.v4(),
        chatId: AI_CHAT_ID,
        senderId: 'ai-assistant',
        content: 'Great! I\'ll look for quiet students from the University of Rwanda. What\'s your budget range for rent?',
        timestamp: now.subtract(const Duration(days: 2, hours: 2)).add(const Duration(minutes: 1)),
        isRead: true,
      ),
      ChatMessage(
        id: _uuid.v4(),
        chatId: AI_CHAT_ID,
        senderId: 'current-user-id',
        content: 'Around \$300 per month',
        timestamp: now.subtract(const Duration(days: 2, hours: 1)),
        isRead: true,
      ),
      ChatMessage(
        id: _uuid.v4(),
        chatId: AI_CHAT_ID,
        senderId: 'ai-assistant',
        content: 'Based on your preferences, I found these potential roommate matches:\n\n1. John Smith - University of Rwanda (89% compatible)\n2. Emma Wilson - University of Rwanda (76% compatible)\n3. Michael Brown - University of Rwanda (92% compatible)\n\nWould you like more details about any of these matches?',
        timestamp: now.subtract(const Duration(days: 2, hours: 1)).add(const Duration(minutes: 1)),
        isRead: true,
      ),
    ];
  }
} 