import 'dart:convert';
import 'dart:math';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/agent_message.dart';
import 'dart:developer' as developer;
import 'package:flutter_tts/flutter_tts.dart';
import 'housing_data_service.dart';

const String VAPI_API_KEY = '4a8cf14b-ac04-4f55-ae30-59bfa7393cc9';
const String VAPI_AGENT_ID = 'd8e42075-49a8-47da-b977-f36a58e52ccc';
const String VAPI_BASE_URL = 'https://api.vapi.ai';

class AgentService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: VAPI_BASE_URL,
      headers: {
        'Authorization': 'Bearer $VAPI_API_KEY',
        'Content-Type': 'application/json',
      },
    ),
  );
  final FlutterTts _flutterTts = FlutterTts();
  final HousingDataService _housingDataService = HousingDataService();

  bool _isCallStarted = false;
  String? _conversationId;
  String? _callId;
  final List<AgentMessage> _messages = [];
  bool _isTtsInitialized = false;

  // Timer for polling vapi messages
  Timer? _pollTimer;

  AgentService() {
    _messages.add(
      AgentMessage(
        id: 'welcome',
        content:
            'Hello! I\'m your DoorMate voice assistant for housing in Kigali. You can ask me about available apartments, houses, roommate options, pricing, neighborhoods, and amenities. Just tap the microphone button to start speaking.',
        role: 'assistant',
        createdAt: DateTime.now().toIso8601String(),
      ),
    );
    _initTts();
  }

  // Initialize text-to-speech
  Future<void> _initTts() async {
    try {
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      _flutterTts.setCompletionHandler(() {
        developer.log('TTS completed', name: 'AGENT_API');
      });
      _isTtsInitialized = true;
      developer.log('TTS initialized successfully', name: 'AGENT_API');
    } catch (e) {
      developer.log('Error initializing TTS: $e', name: 'AGENT_API');
    }
  }

  // Get all messages (immutable copy)
  List<AgentMessage> getMessages() {
    return List.unmodifiable(_messages);
  }

  // Create a new conversation (locally generated)
  Future<String?> createConversation() async {
    try {
      developer.log('Creating new conversation', name: 'AGENT_API');
      _conversationId = 'conversation-${DateTime.now().millisecondsSinceEpoch}';
      return _conversationId;
    } catch (e) {
      developer.log('Error creating conversation: $e', name: 'AGENT_API');
      return null;
    }
  }

  // Start a call using vapi REST API
  Future<bool> startCall() async {
    if (_isCallStarted) {
      developer.log('Call already started', name: 'AGENT_API');
      return true;
    }

    try {
      // Prepare call options data (adjust keys per vapi API requirements)
      final callOptions = {
        'agent_id': VAPI_AGENT_ID,
        'first_message':
            "Hello! I'm your DoorMate voice assistant for housing in Kigali. How can I help you find housing today?",
        'llm_config': {
          "provider": "openai",
          "model": "gpt-3.5-turbo",
          "system_prompt": """You are a helpful housing assistant for DoorMate, a platform that helps students find housing and roommates in Kigali, Rwanda.
          
Your goal is to help users find suitable housing options based on their preferences. Provide information on:
1. Apartments, houses, and rooms for rent in Kigali.
2. Rental price ranges.
3. Popular neighborhoods for students.
4. Roommate matching services.
5. Required amenities.

Mention neighborhoods such as Kacyiru, Kimihurura, Nyamirambo, Remera, Kicukiro, Gikondo, and Gisozi.
Prices typically range from 150-300 USD for shared accommodations and 300-600 USD for single apartments.

Use these commands when needed:
- "SHOW_PROPERTIES_IN: [neighborhood]"
- "SHOW_PRICE_RANGE_IN: [neighborhood]"
- "SHOW_ROOMMATE_MATCHES"
- "SHOW_ALL_NEIGHBORHOODS"

Be conversational, helpful, and if uncertain, admit it.
"""
        },
        'voice_config': {
          "provider": "11labs",
          "voice_id": "jennifer",
        },
        'record_call': false,
      };

      // POST to vapi endpoint to start the call
      final response =
          await _dio.post('/calls', data: jsonEncode(callOptions));
      if (response.statusCode == 200 &&
          response.data != null &&
          response.data['call_id'] != null) {
        _callId = response.data['call_id'];
        _isCallStarted = true;
        developer.log('vapi call started with ID: $_callId', name: 'AGENT_API');

        // Start polling for messages
        _startPollingMessages();
        return true;
      } else {
        developer.log('Failed to start vapi call: ${response.data}',
            name: 'AGENT_API');
        return false;
      }
    } catch (e) {
      developer.log('Error starting call: $e', name: 'AGENT_API');
      // Fallback to local implementation
      _isCallStarted = true;
      _addAssistantMessage("I'm ready to help you find housing in Kigali. What are you looking for?");
      return true;
    }
  }

  // Send a message during an active call
  Future<void> _sendVapiMessage(String messageContent) async {
    if (!_isCallStarted || _callId == null) return;
    try {
      final payload = {'message': messageContent};
      final url = '/calls/$_callId/messages';
      final response = await _dio.post(url, data: jsonEncode(payload));
      if (response.statusCode != 200) {
        developer.log('Failed to send message: ${response.data}', name: 'AGENT_API');
      }
    } catch (e) {
      developer.log('Error sending message to vapi: $e', name: 'AGENT_API');
      // Optionally, fall back to generating a simulated response
      _generateSimulatedResponse(messageContent);
    }
  }

  // Poll for new messages from vapi
  Future<void> _pollMessages() async {
    if (!_isCallStarted || _callId == null) return;
    try {
      final url = '/calls/$_callId/messages';
      final response = await _dio.get(url);
      if (response.statusCode == 200 && response.data != null) {
        // Assume the API returns a list of messages in the 'messages' field
        List<dynamic> messages = response.data['messages'];
        // For each new message not already in our local list, add it
        for (final msg in messages) {
          // Simple check based on unique ID (adjust if necessary)
          final msgId = msg['id'] ?? '';
          bool alreadyExists =
              _messages.any((m) => m.id.toString() == msgId.toString());
          if (!alreadyExists) {
            final AgentMessage agentMessage = AgentMessage(
              id: msgId.isNotEmpty
                  ? msgId
                  : DateTime.now().millisecondsSinceEpoch.toString(),
              content: msg['content'] ?? '',
              role: msg['role'] ?? 'assistant',
              createdAt: msg['created_at'] ?? DateTime.now().toIso8601String(),
            );
            _messages.add(agentMessage);
            // Process commands for assistant messages
            if (agentMessage.role == 'assistant') {
              _processAssistantMessage(agentMessage.content);
              // Optionally speak out the message if TTS is active
              if (_isTtsInitialized && _isCallStarted) {
                _speakMessage(agentMessage.content);
              }
            }
          }
        }
      }
    } catch (e) {
      developer.log('Error polling messages from vapi: $e', name: 'AGENT_API');
    }
  }

  // Start polling timer
  void _startPollingMessages() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      _pollMessages();
    });
  }

  // End the call using vapi REST API
  Future<void> endCall() async {
    if (!_isCallStarted || _callId == null) {
      developer.log('No active call to end', name: 'AGENT_API');
      return;
    }
    try {
      _isCallStarted = false;
      _pollTimer?.cancel();
      final url = '/calls/$_callId/end';
      await _dio.post(url);
      developer.log('vapi call ended: $_callId', name: 'AGENT_API');
      _callId = null;

      // Stop any ongoing TTS
      if (_isTtsInitialized) {
        try {
          await _flutterTts.stop();
        } catch (e) {
          developer.log('Error stopping TTS: $e', name: 'AGENT_API');
        }
      }

      _addAssistantMessage(
          "Thank you for using DoorMate voice assistant. Call again when you need help finding housing in Kigali!");
    } catch (e) {
      developer.log('Error ending call: $e', name: 'AGENT_API');
      _isCallStarted = false;
    }
  }

  // Speak a message using TTS
  Future<void> _speakMessage(String message) async {
    if (!_isTtsInitialized) return;
    try {
      await _flutterTts.speak(message);
    } catch (e) {
      developer.log('Error speaking message: $e', name: 'AGENT_API');
    }
  }

  // Add an assistant message to the local list and process commands
  void _addAssistantMessage(String content) {
    try {
      final assistantMessage = AgentMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: content,
        role: 'assistant',
        createdAt: DateTime.now().toIso8601String(),
      );
      _messages.add(assistantMessage);
      _processAssistantMessage(content);
      // In fallback mode, use TTS to speak the message
      if (_isTtsInitialized && _isCallStarted) {
        _speakMessage(content);
      }
    } catch (e) {
      developer.log('Error adding assistant message: $e', name: 'AGENT_API');
    }
  }

  // Process assistant messages for any commands
  Future<void> _processAssistantMessage(String content) async {
    try {
      final propertyRegex =
          RegExp(r'SHOW_PROPERTIES_IN:\s*(\w+)', caseSensitive: false);
      final propertyMatch = propertyRegex.firstMatch(content);
      if (propertyMatch != null && propertyMatch.groupCount >= 1) {
        final neighborhood = propertyMatch.group(1);
        if (neighborhood != null) {
          await _showPropertiesInNeighborhood(neighborhood);
        }
      }
      final priceRegex =
          RegExp(r'SHOW_PRICE_RANGE_IN:\s*(\w+)', caseSensitive: false);
      final priceMatch = priceRegex.firstMatch(content);
      if (priceMatch != null && priceMatch.groupCount >= 1) {
        final neighborhood = priceMatch.group(1);
        if (neighborhood != null) {
          await _showPriceRangeInNeighborhood(neighborhood);
        }
      }
      if (content.toUpperCase().contains('SHOW_ROOMMATE_MATCHES')) {
        await _showRoommateMatches();
      }
      if (content.toUpperCase().contains('SHOW_ALL_NEIGHBORHOODS')) {
        await _showAllNeighborhoods();
      }
    } catch (e) {
      developer.log('Error processing assistant message: $e', name: 'AGENT_API');
    }
  }

  // Show properties in a neighborhood using the housing data service
  Future<void> _showPropertiesInNeighborhood(String neighborhood) async {
    try {
      final result =
          await _housingDataService.getPropertiesByNeighborhood(neighborhood);
      if (result['success'] == true && result['data'] != null) {
        final properties = result['data'] as List<dynamic>;
        if (properties.isEmpty) {
          _addAssistantMessage(
              "I couldn't find any properties in $neighborhood at the moment.");
          return;
        }
        String message = "Here are some properties available in $neighborhood:\n\n";
        for (int i = 0; i < properties.length; i++) {
          final property = properties[i] as Map<String, dynamic>;
          message += "${i + 1}. ${property['title']}\n";
          message +=
              "   ${property['bedrooms']} bed, ${property['bathrooms']} bath - \$${property['price']}/${property['currency']}\n";
          message += "   ${property['furnished'] ? 'Furnished' : 'Unfurnished'}\n";
          message += "   ${property['description']}\n\n";
        }
        _addAssistantMessage(message);
      } else {
        _addAssistantMessage(
            "I couldn't retrieve property listings for $neighborhood at the moment. Please try again later.");
      }
    } catch (e) {
      developer.log('Error showing properties: $e', name: 'AGENT_API');
      _addAssistantMessage(
          "I encountered an error while retrieving property listings. Please try again later.");
    }
  }

  // Show price range in a neighborhood
  Future<void> _showPriceRangeInNeighborhood(String neighborhood) async {
    try {
      final result =
          await _housingDataService.getPriceRangeByNeighborhood(neighborhood);
      if (result['success'] == true && result['data'] != null) {
        final priceRanges = result['data'] as Map<String, dynamic>;
        if (priceRanges.isEmpty) {
          _addAssistantMessage(
              "I couldn't find price information for $neighborhood at the moment.");
          return;
        }
        String message = "Here are the typical price ranges in $neighborhood:\n\n";
        priceRanges.forEach((propertyType, range) {
          final rangeData = range as Map<String, dynamic>;
          message +=
              "${_capitalizeFirstLetter(propertyType)}: \$${rangeData['min']}-${rangeData['max']}/${rangeData['currency']} per month\n";
        });
        _addAssistantMessage(message);
      } else {
        _addAssistantMessage(
            "I couldn't retrieve price information for $neighborhood at the moment. Please try again later.");
      }
    } catch (e) {
      developer.log('Error showing price ranges: $e', name: 'AGENT_API');
      _addAssistantMessage(
          "I encountered an error while retrieving price information. Please try again later.");
    }
  }

  // Show roommate matches
  Future<void> _showRoommateMatches() async {
    try {
      final result = await _housingDataService.getRoommateMatches({});
      if (result['success'] == true && result['data'] != null) {
        final matches = result['data'] as List<dynamic>;
        if (matches.isEmpty) {
          _addAssistantMessage("I couldn't find any roommate matches at the moment.");
          return;
        }
        String message = "Here are some potential roommate matches:\n\n";
        for (int i = 0; i < matches.length; i++) {
          final match = matches[i] as Map<String, dynamic>;
          message += "${i + 1}. ${match['name']}, ${match['age']}, ${match['gender']}\n";
          message += "   ${match['occupation']}";
          if (match.containsKey('university') && match['university'] != null) {
            message += " at ${match['university']}";
          } else if (match.containsKey('workplace') && match['workplace'] != null) {
            message += " at ${match['workplace']}";
          }
          message += "\n";
          message += "   Budget: \$${match['budget']}/${match['currency']}\n";
          message += "   Move-in date: ${match['moveInDate']}\n";
          message += "   Interests: ${(match['interests'] as List<dynamic>).join(', ')}\n";
          message += "   Compatibility: ${match['compatibility']}%\n\n";
        }
        _addAssistantMessage(message);
      } else {
        _addAssistantMessage("I couldn't retrieve roommate matches at the moment. Please try again later.");
      }
    } catch (e) {
      developer.log('Error showing roommate matches: $e', name: 'AGENT_API');
      _addAssistantMessage("I encountered an error while retrieving roommate matches. Please try again later.");
    }
  }

  // Show all neighborhoods
  Future<void> _showAllNeighborhoods() async {
    try {
      final result = await _housingDataService.getAllNeighborhoods();
      if (result['success'] == true && result['data'] != null) {
        final neighborhoods = result['data'] as List<dynamic>;
        if (neighborhoods.isEmpty) {
          _addAssistantMessage("I couldn't find any neighborhood information at the moment.");
          return;
        }
        String message = "Here are the neighborhoods in Kigali where we have listings:\n\n";
        message += neighborhoods.join(', ');
        _addAssistantMessage(message);
      } else {
        _addAssistantMessage("I couldn't retrieve neighborhood information at the moment. Please try again later.");
      }
    } catch (e) {
      developer.log('Error showing neighborhoods: $e', name: 'AGENT_API');
      _addAssistantMessage("I encountered an error while retrieving neighborhood information. Please try again later.");
    }
  }

  // Helper method to capitalize the first letter of a string
  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  // Add a user message and generate a response
  void addUserMessage(String content) {
    if (content.trim().isEmpty) return;
    try {
      _messages.add(
        AgentMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: content,
          role: 'user',
          createdAt: DateTime.now().toIso8601String(),
        ),
      );
      // If call is active, send the message to vapi
      if (_isCallStarted && _callId != null) {
        _sendVapiMessage(content);
      } else {
        _generateSimulatedResponse(content);
      }
    } catch (e) {
      developer.log('Error adding user message: $e', name: 'AGENT_API');
    }
  }

  // Generate a simulated response if vapi is not active or fails
  Future<void> _generateSimulatedResponse(String userMessage) async {
    try {
      final lowerUserMessage = userMessage.toLowerCase();
      if (lowerUserMessage.contains('properties in') ||
          lowerUserMessage.contains('apartments in') ||
          lowerUserMessage.contains('houses in') ||
          lowerUserMessage.contains('housing in')) {
        final neighborhoods = await _housingDataService.getAllNeighborhoods();
        if (neighborhoods['success'] == true && neighborhoods['data'] != null) {
          for (final neighborhood in neighborhoods['data'] as List<dynamic>) {
            if (lowerUserMessage.contains(neighborhood.toString().toLowerCase())) {
              await _showPropertiesInNeighborhood(neighborhood.toString());
              return;
            }
          }
        }
      }
      if (lowerUserMessage.contains('price') ||
          lowerUserMessage.contains('cost') ||
          lowerUserMessage.contains('how much') ||
          lowerUserMessage.contains('range')) {
        final neighborhoods = await _housingDataService.getAllNeighborhoods();
        if (neighborhoods['success'] == true && neighborhoods['data'] != null) {
          for (final neighborhood in neighborhoods['data'] as List<dynamic>) {
            if (lowerUserMessage.contains(neighborhood.toString().toLowerCase())) {
              await _showPriceRangeInNeighborhood(neighborhood.toString());
              return;
            }
          }
        }
      }
      if (lowerUserMessage.contains('roommate') ||
          lowerUserMessage.contains('share') ||
          lowerUserMessage.contains('sharing') ||
          lowerUserMessage.contains('live with')) {
        await _showRoommateMatches();
        return;
      }
      if (lowerUserMessage.contains('neighborhood') ||
          lowerUserMessage.contains('area') ||
          lowerUserMessage.contains('location') ||
          lowerUserMessage.contains('where')) {
        await _showAllNeighborhoods();
        return;
      }
      final List<String> responses = [
        "I can help you find housing in Kigali. What neighborhood are you interested in?",
        "In Kacyiru, you can find apartments ranging from 300-500 USD per month.",
        "Shared accommodations in Remera typically cost between 150-250 USD per month.",
        "Kimihurura is popular for students due to its proximity to universities and amenities.",
        "Would you prefer a furnished or unfurnished apartment?",
        "Most apartments in Kigali come with basic amenities like water and electricity, though utilities may be extra."
      ];
      if (lowerUserMessage.contains('price') ||
          lowerUserMessage.contains('cost')) {
        responses.add(
            "Prices vary by neighborhood. In Kigali, expect to pay between 150-300 USD for shared spaces and 300-600 USD for single apartments.");
      }
      if (lowerUserMessage.contains('roommate') ||
          lowerUserMessage.contains('share')) {
        responses.add(
            "We offer a roommate matching service to help you find compatible roommates based on your preferences and budget.");
      }
      if (lowerUserMessage.contains('neighborhood') ||
          lowerUserMessage.contains('area')) {
        responses.add(
            "Popular neighborhoods for students include Kacyiru, Kimihurura, and Remera because of their proximity to universities and amenities.");
      }
      if (lowerUserMessage.contains('amenities') ||
          lowerUserMessage.contains('facilities')) {
        responses.add(
            "Most apartments in Kigali come with basic amenities like water and electricity, while premium listings may include extras like internet and security.");
      }
      if (lowerUserMessage.contains('university') ||
          lowerUserMessage.contains('school') ||
          lowerUserMessage.contains('college')) {
        responses.add(
            "For housing near educational institutions, Kacyiru and Kimihurura are excellent options.");
      }
      final random = Random();
      final response = responses[random.nextInt(responses.length)];
      _addAssistantMessage(response);
    } catch (e) {
      developer.log('Error generating simulated response: $e', name: 'AGENT_API');
      _addAssistantMessage("I'm sorry, I couldn't process that request. Could you try again?");
    }
  }

  // Check if a call is active
  bool isCallActive() {
    return _isCallStarted;
  }

  // Clean up resources
  void dispose() {
    try {
      _isCallStarted = false;
      _pollTimer?.cancel();
      if (_isTtsInitialized) {
        try {
          _flutterTts.stop();
        } catch (e) {
          developer.log('Error stopping TTS in dispose: $e', name: 'AGENT_API');
        }
      }
      // Optionally, if a call is still active, end it via API
      if (_isCallStarted && _callId != null) {
        _dio.post('/calls/$_callId/end').catchError((e) {
          developer.log('Error ending vapi call in dispose: $e', name: 'AGENT_API');
        });
      }
      _callId = null;
      _messages.clear();
      _messages.add(
        AgentMessage(
          id: 'welcome',
          content:
              'Hello! I\'m your DoorMate voice assistant for housing in Kigali. You can ask me about available apartments, houses, roommate options, pricing, neighborhoods, and amenities. Just tap the microphone button to start speaking.',
          role: 'assistant',
          createdAt: DateTime.now().toIso8601String(),
        ),
      );
    } catch (e) {
      developer.log('Error in dispose: $e', name: 'AGENT_API');
    }
  }
}
