import 'package:mobile_client_flutter/models/chat_message.dart';
import 'package:mobile_client_flutter/services/api_client.dart';
import 'package:mobile_client_flutter/services/storage_service.dart';
import 'dart:async';
import 'dart:developer' as developer;

class MessagingService {
  final ApiClient _apiClient;
  final StorageService _storage = StorageService();
  final Map<String, StreamController<List<ChatMessage>>> _messageControllers = {};
  String? _currentUserId;
  
  MessagingService(this._apiClient);

  Future<String> getCurrentUserId() async {
    final userData = await _storage.getUserData();
    if (userData == null || !userData.containsKey('id')) {
      throw Exception('User data not found');
    }
    _currentUserId = userData['id'];
    return _currentUserId!;
  }

  Future<Map<String, dynamic>> startChat(String userId) async {
    try {
      final response = await _apiClient.post('/chats/start', {
        'user_id': userId
      });
      return response;
    } catch (e) {
      developer.log('Error starting chat: $e', name: 'MESSAGING');
      throw Exception('Failed to start chat: $e');
    }
  }

  void closeMessageStream(String chatId) {
    if (_messageControllers.containsKey(chatId)) {
      _messageControllers[chatId]!.close();
      _messageControllers.remove(chatId);
    }
  }
  
  Future<List<Map<String, dynamic>>> getChats() async {
    try {
      await _apiClient.ensureTokenIsSet();
      final response = await _apiClient.get('/chats');
      
      if (response.containsKey('chats')) {
        return List<Map<String, dynamic>>.from(response['chats']);
      } else {
        throw Exception('Invalid response format from server');
      }
    } catch (e) {
      developer.log('Error fetching chats: $e', name: 'MESSAGING');
      throw Exception('Failed to fetch chats: $e');
    }
  }

  Future<List<ChatMessage>> getMessages(String chatId) async {
    try {
      final response = await _apiClient.get('/chats/$chatId/messages');
      if (response.containsKey('messages')) {
        final List<dynamic> messagesJson = response['messages'];
        return messagesJson.map((json) => ChatMessage.fromJson(json)).toList();
      } else {
        throw Exception('Invalid response format from server');
      }
    } catch (e) {
      developer.log('Error fetching messages: $e', name: 'MESSAGING');
      throw Exception('Failed to fetch messages: $e');
    }
  }

  Future<void> markMessagesAsRead(String chatId) async {
    try {
      await _apiClient.post('/chats/$chatId/mark-read', {});
    } catch (e) {
      developer.log('Error marking messages as read: $e', name: 'MESSAGING');
      throw Exception('Failed to mark messages as read: $e');
    }
  }

  Future<ChatMessage> sendMessage(String chatId, String content) async {
    try {
      final response = await _apiClient.post('/chats/$chatId/messages', {
        'content': content,
      });
      
      if (response.containsKey('message')) {
        return ChatMessage.fromJson(response['message']);
      } else {
        throw Exception('Invalid response format from server');
      }
    } catch (e) {
      developer.log('Error sending message: $e', name: 'MESSAGING');
      throw Exception('Failed to send message: $e');
    }
  }

  Stream<List<ChatMessage>> getMessageStream(String chatId) {
    if (!_messageControllers.containsKey(chatId)) {
      _messageControllers[chatId] = StreamController<List<ChatMessage>>.broadcast();
      
      getMessages(chatId).then((messages) {
        if (_messageControllers.containsKey(chatId)) {
          _messageControllers[chatId]!.add(messages);
        }
      });
      
      _setupWebSocketConnection(chatId);
    }
    
    return _messageControllers[chatId]!.stream;
  }

  void _setupWebSocketConnection(String chatId) {
    Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (!_messageControllers.containsKey(chatId)) {
        timer.cancel();
        return;
      }
      try {
        final messages = await getMessages(chatId);
        _messageControllers[chatId]!.add(messages);
      } catch (e) {
        developer.log('Error polling messages: $e', name: 'MESSAGING');
      }
    });
  }

  void dispose() {
    for (var controller in _messageControllers.values) {
      controller.close();
    }
    _messageControllers.clear();
  }
}