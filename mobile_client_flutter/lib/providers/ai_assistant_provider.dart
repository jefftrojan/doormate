import 'package:flutter/foundation.dart';
import 'package:mobile_client_flutter/models/chat_message.dart';
import 'package:mobile_client_flutter/services/ai_assistant_service.dart';
import 'dart:developer' as developer;

class AIAssistantProvider extends ChangeNotifier {
  final AIAssistantService _aiAssistantService;
  bool _isLoading = false;
  bool _isLoadingHistory = false;
  bool _isLoadingInsights = false;
  String? _error;
  List<ChatMessage> _messages = [];
  Map<String, dynamic> _insights = {};
  static const String AI_CHAT_ID = 'ai-assistant';

  AIAssistantProvider(this._aiAssistantService);

  bool get isLoading => _isLoading;
  bool get isLoadingHistory => _isLoadingHistory;
  bool get isLoadingInsights => _isLoadingInsights;
  String? get error => _error;
  List<ChatMessage> get messages => _messages;
  Map<String, dynamic> get insights => _insights;

  Future<void> sendMessage(String content) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Add user message to the list
      final userMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        chatId: AI_CHAT_ID,
        senderId: 'current-user-id',
        content: content,
        timestamp: DateTime.now(),
        isRead: true,
      );
      _messages.add(userMessage);
      notifyListeners();

      // Use the real service method which will handle mock data if needed
      final assistantMessage = await _aiAssistantService.sendMessage(content);
      
      _messages.add(assistantMessage);
      developer.log('Added AI response to messages list', name: 'AI_ASSISTANT_PROVIDER');
    } catch (e) {
      developer.log('Error in sendMessage: $e', name: 'AI_ASSISTANT_PROVIDER');
      _error = e.toString();
      
      // Add error message
      final errorMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        chatId: AI_CHAT_ID,
        senderId: 'ai-assistant',
        content: 'Sorry, I encountered an error. Please try again.',
        timestamp: DateTime.now(),
        isRead: true,
      );
      _messages.add(errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadChatHistory() async {
    try {
      _isLoadingHistory = true;
      _error = null;
      notifyListeners();

      developer.log('Loading chat history', name: 'AI_ASSISTANT_PROVIDER');
      final history = await _aiAssistantService.getChatHistory();
      
      if (history.isNotEmpty) {
        _messages = history;
        developer.log('Loaded ${history.length} messages from history', name: 'AI_ASSISTANT_PROVIDER');
      } else {
        developer.log('No chat history found', name: 'AI_ASSISTANT_PROVIDER');
      }
    } catch (e) {
      developer.log('Error loading chat history: $e', name: 'AI_ASSISTANT_PROVIDER');
      _error = 'Failed to load chat history: ${e.toString()}';
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  Future<void> clearChatHistory() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      developer.log('Clearing chat history', name: 'AI_ASSISTANT_PROVIDER');
      await _aiAssistantService.clearChatHistory();
      _messages.clear();
      developer.log('Chat history cleared', name: 'AI_ASSISTANT_PROVIDER');
    } catch (e) {
      developer.log('Error clearing chat history: $e', name: 'AI_ASSISTANT_PROVIDER');
      _error = 'Failed to clear chat history: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadInsights() async {
    try {
      _isLoadingInsights = true;
      _error = null;
      notifyListeners();

      developer.log('Loading AI insights', name: 'AI_ASSISTANT_PROVIDER');
      final insights = await _aiAssistantService.getAIInsights();
      
      if (insights.isNotEmpty) {
        _insights = insights;
        developer.log('Loaded AI insights successfully', name: 'AI_ASSISTANT_PROVIDER');
      } else {
        developer.log('No AI insights found', name: 'AI_ASSISTANT_PROVIDER');
      }
    } catch (e) {
      developer.log('Error loading AI insights: $e', name: 'AI_ASSISTANT_PROVIDER');
      _error = 'Failed to load AI insights: ${e.toString()}';
    } finally {
      _isLoadingInsights = false;
      notifyListeners();
    }
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
} 