import 'package:flutter/foundation.dart';
import 'package:mobile_client_flutter/models/chat_message.dart';
import 'package:mobile_client_flutter/services/messaging_service.dart';

class MessagingProvider extends ChangeNotifier {
  final MessagingService _messagingService;
  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _chats = [];
  Map<String, List<ChatMessage>> _messages = {};
  String? _currentChatId;
  String? _currentUserId;

  MessagingProvider(this._messagingService) {
    _initCurrentUserId();
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Map<String, dynamic>> get chats => _chats;
  List<ChatMessage> get currentMessages => _messages[_currentChatId] ?? [];
  String? get currentChatId => _currentChatId;
  String? get currentUserId => _currentUserId;

  // Initialize current user ID
  Future<void> _initCurrentUserId() async {
    try {
      _currentUserId = await _messagingService.getCurrentUserId();
    } catch (e) {
      print('Error initializing current user ID: $e');
      // We'll try again when needed
    }
  }

  // Ensure we have the current user ID
  Future<String?> _ensureCurrentUserId() async {
    if (_currentUserId == null) {
      _currentUserId = await _messagingService.getCurrentUserId();
    }
    return _currentUserId;
  }

  // Fetch all chats for the current user
  Future<void> fetchChats() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Ensure we have the current user ID
      await _ensureCurrentUserId();
      
      _chats = await _messagingService.getChats();
      
      if (_chats.isEmpty) {
        print('No chats found for the current user');
      }
    } catch (e) {
      print('Error fetching chats: $e');
      _error = 'Failed to load chats';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Set the current chat and fetch its messages
  Future<void> setCurrentChat(String chatId) async {
    try {
      _isLoading = true;
      _error = null;
      _currentChatId = chatId;
      notifyListeners();

      // Ensure we have the current user ID
      await _ensureCurrentUserId();

      // Mark messages as read
      await _messagingService.markMessagesAsRead(chatId);

      // Listen to the message stream
      _messagingService.getMessageStream(chatId).listen(
        (messages) {
          _messages[chatId] = messages;
          notifyListeners();
        },
        onError: (error) {
          print('Error in message stream: $error');
          // Don't set error state here to avoid UI disruption
        },
      );
    } catch (e) {
      print('Error setting current chat: $e');
      _error = 'Failed to load messages';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Send a message in the current chat
  Future<void> sendMessage(String content) async {
    if (_currentChatId == null) {
      _error = 'No active chat selected';
      notifyListeners();
      return;
    }

    try {
      await _messagingService.sendMessage(_currentChatId!, content);
    } catch (e) {
      _error = 'Failed to send message';
      notifyListeners();
    }
  }

  // Start a new chat with a user
  Future<String?> startChat(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final chat = await _messagingService.startChat(userId);
      
      // Add the new chat to the list
      _chats.insert(0, chat);
      
      _isLoading = false;
      notifyListeners();
      
      return chat['id'];
    } catch (e) {
      _error = 'Failed to start chat';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Check if a message is from the current user
  bool isMessageFromCurrentUser(ChatMessage message) {
    return message.senderId == _currentUserId;
  }

  // Clear the current chat when navigating away
  void clearCurrentChat() {
    if (_currentChatId != null) {
      _messagingService.closeMessageStream(_currentChatId!);
      _currentChatId = null;
      notifyListeners();
    }
  }

  // Clear any error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    // Close any open streams
    if (_currentChatId != null) {
      _messagingService.closeMessageStream(_currentChatId!);
    }
    super.dispose();
  }
} 