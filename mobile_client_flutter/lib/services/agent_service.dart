import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/agent_message.dart';
import 'dart:developer' as developer;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vapi/vapi.dart';
import 'housing_data_service.dart';

// Vapi API keys - replace with your actual keys
const String VAPI_PUBLIC_KEY = '216f162d-4905-480d-b852-d6f6e8bfeab6';
const String VAPI_ASSISTANT_ID = 'f8e43091-a30a-4d22-bfae-fe698e8e4e7d';

class AgentService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final Dio _dio = Dio();
  final FlutterTts _flutterTts = FlutterTts();
  final HousingDataService _housingDataService = HousingDataService();
  Vapi? _vapi;
  
  bool _isCallStarted = false;
  String? _conversationId;
  final List<AgentMessage> _messages = [];
  bool _isTtsInitialized = false;
  bool _isVapiAvailable = false;
  
  // Constructor
  AgentService() {
    // Initialize with welcome message
    _messages.add(
      AgentMessage(
        id: 'welcome',
        content: 'Hello! I\'m your DoorMate voice assistant for housing in Kigali. You can ask me about available apartments, houses, roommate options, pricing, neighborhoods, and amenities. Just tap the microphone button to start speaking.',
        role: 'assistant',
        createdAt: DateTime.now().toIso8601String(),
      ),
    );
    
    // Initialize TTS
    _initTts();
    
    // Initialize Vapi
    _initVapi();
  }
  
  // Initialize Vapi
  Future<void> _initVapi() async {
    try {
      // Initialize Vapi
      _vapi = Vapi(VAPI_PUBLIC_KEY);
      
      // Set up event listener
      _vapi?.onEvent.listen((event) {
        try {
          developer.log('Vapi event: ${event.label}', name: 'AGENT_API');
          
          if (event.label == "call-start") {
            _isCallStarted = true;
            developer.log('Vapi call started', name: 'AGENT_API');
          }
          
          if (event.label == "call-end") {
            _isCallStarted = false;
            developer.log('Vapi call ended', name: 'AGENT_API');
          }
          
          if (event.label == "message") {
            developer.log('Vapi message: ${event.value}', name: 'AGENT_API');
            
            // Parse the message and add it to the messages list
            try {
              final Map<String, dynamic> messageData = jsonDecode(event.value);
              
              if (messageData.containsKey('content') && messageData.containsKey('role')) {
                final AgentMessage message = AgentMessage(
                  id: messageData['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  content: messageData['content'],
                  role: messageData['role'],
                  createdAt: messageData['created_at'] ?? DateTime.now().toIso8601String(),
                );
                
                _messages.add(message);
                
                // Check if we need to process any commands or queries
                if (message.role == 'assistant') {
                  _processAssistantMessage(message.content);
                }
              }
            } catch (e) {
              developer.log('Error parsing Vapi message: $e', name: 'AGENT_API');
            }
          }
        } catch (e) {
          developer.log('Error handling Vapi event: $e', name: 'AGENT_API');
        }
      }, onError: (error) {
        developer.log('Error in Vapi event stream: $error', name: 'AGENT_API');
        _isVapiAvailable = false;
      });
      
      _isVapiAvailable = true;
      developer.log('Vapi initialized successfully', name: 'AGENT_API');
    } catch (e) {
      developer.log('Error initializing Vapi: $e', name: 'AGENT_API');
      _isVapiAvailable = false;
      _vapi = null;
    }
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
  
  // Get all messages
  List<AgentMessage> getMessages() {
    return List.unmodifiable(_messages);
  }
  
  // Create a new conversation
  Future<String?> createConversation() async {
    try {
      developer.log('Creating new conversation', name: 'AGENT_API');
      
      // Generate a unique conversation ID
      _conversationId = 'conversation-${DateTime.now().millisecondsSinceEpoch}';
      
      // Don't speak the welcome message - let Vapi handle all voice interactions
      // Only use TTS in fallback mode when Vapi is not available
      // if (_isTtsInitialized && !_isVapiAvailable) {
      //   _speakMessage(_messages.first.content);
      // }
      
      return _conversationId;
    } catch (e) {
      developer.log('Error creating conversation: $e', name: 'AGENT_API');
      return null;
    }
  }
  
  // Start a call with the voice assistant
  Future<bool> startCall() async {
    if (_isCallStarted) {
      developer.log('Call already started', name: 'AGENT_API');
      return true;
    }
    
    try {
      // If Vapi is available, use it
      if (_isVapiAvailable && _vapi != null) {
        developer.log('Starting Vapi call', name: 'AGENT_API');
        
        try {
          // Set call as started immediately to prevent UI lag
          _isCallStarted = true;
          
          await _vapi?.start(assistant: {
            "firstMessage": "Hello! I'm your DoorMate voice assistant for housing in Kigali. How can I help you find housing today?",
            "model": {
              "provider": "openai",
              "model": "gpt-3.5-turbo",
              "messages": [
                {
                  "role": "system",
                  "content": """You are a helpful housing assistant for DoorMate, a platform that helps students find housing and roommates in Kigali, Rwanda.
                  
Your primary goal is to help users find suitable housing options based on their preferences. You can provide information about:
1. Available apartments, houses, and rooms for rent in Kigali
2. Typical rental prices in different neighborhoods
3. Popular neighborhoods for students
4. Roommate matching services
5. Required amenities and facilities

When discussing housing options, mention specific neighborhoods in Kigali like Kacyiru, Kimihurura, Nyamirambo, Remera, Kicukiro, Gikondo, and Gisozi.
Typical rental prices range from 150-300 USD for shared accommodations and 300-600 USD for single apartments.

You can use special commands to show property listings or roommate matches:
- To show properties in a neighborhood, say: "SHOW_PROPERTIES_IN: [neighborhood]"
- To show price ranges, say: "SHOW_PRICE_RANGE_IN: [neighborhood]"
- To show roommate matches, say: "SHOW_ROOMMATE_MATCHES"
- To show all neighborhoods, say: "SHOW_ALL_NEIGHBORHOODS"

Be conversational, helpful, and provide specific information when possible. If you don't know something, be honest about it.
"""
                }
              ]
            },
            "voice": {
              "provider": "11labs",
              "voiceId": "jennifer",
            }
          });
          
          return true;
        } catch (e) {
          developer.log('Error starting Vapi call: $e', name: 'AGENT_API');
          // Fall back to local implementation
          _isVapiAvailable = false;
          _isCallStarted = false;
        }
      }
      
      // Fallback to local implementation
      developer.log('Starting local voice assistant call', name: 'AGENT_API');
      
      _isCallStarted = true;
      _addAssistantMessage("I'm ready to help you find housing in Kigali. What are you looking for?");
      
      return true;
    } catch (e) {
      developer.log('Error starting call: $e', name: 'AGENT_API');
      
      // Fallback to local implementation if Vapi fails
      try {
        _isCallStarted = true;
        _addAssistantMessage("I'm ready to help you find housing in Kigali. What are you looking for?");
        return true;
      } catch (innerError) {
        developer.log('Error in fallback implementation: $innerError', name: 'AGENT_API');
        return false;
      }
    }
  }
  
  // End the call
  Future<void> endCall() async {
    if (!_isCallStarted) {
      developer.log('No active call to end', name: 'AGENT_API');
      return;
    }
    
    try {
      // Set call as ended immediately to prevent UI lag
      _isCallStarted = false;
      
      // If Vapi is available, stop the call
      if (_isVapiAvailable && _vapi != null) {
        developer.log('Ending Vapi call', name: 'AGENT_API');
        
        // Capture Vapi instance before nullifying it
        final vapiInstance = _vapi;
        _vapi = null;
        
        try {
          // Send stop command with a timeout to prevent hanging
          await vapiInstance?.stop().timeout(
            const Duration(milliseconds: 500),
            onTimeout: () {
              developer.log('Vapi stop command timed out', name: 'AGENT_API');
              return;
            },
          );
        } catch (e) {
          developer.log('Error stopping Vapi call: $e', name: 'AGENT_API');
        }
      } else {
        developer.log('Ending local call', name: 'AGENT_API');
      }
      
      // Stop any ongoing TTS
      if (_isTtsInitialized) {
        try {
          await _flutterTts.stop();
        } catch (e) {
          developer.log('Error stopping TTS: $e', name: 'AGENT_API');
        }
      }
      
      // Add an end message without speaking it
      _addAssistantMessage("Thank you for using DoorMate voice assistant. Call again when you need help finding housing in Kigali!");
    } catch (e) {
      developer.log('Error ending call: $e', name: 'AGENT_API');
      // Ensure call is marked as ended even if there's an error
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
  
  // Add an assistant message
  void _addAssistantMessage(String content) {
    try {
      final assistantMessage = AgentMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: content,
        role: 'assistant',
        createdAt: DateTime.now().toIso8601String(),
      );
      
      _messages.add(assistantMessage);
      
      // Process the message for any commands
      _processAssistantMessage(content);
      
      // Don't speak the response - let Vapi handle all voice interactions
      // Only use TTS in fallback mode when Vapi is not available
      if (_isTtsInitialized && _isCallStarted && !_isVapiAvailable) {
        _speakMessage(content);
      }
    } catch (e) {
      developer.log('Error adding assistant message: $e', name: 'AGENT_API');
    }
  }
  
  // Process assistant messages for commands
  Future<void> _processAssistantMessage(String content) async {
    try {
      // Check for property listing command
      final propertyRegex = RegExp(r'SHOW_PROPERTIES_IN:\s*(\w+)', caseSensitive: false);
      final propertyMatch = propertyRegex.firstMatch(content);
      
      if (propertyMatch != null && propertyMatch.groupCount >= 1) {
        final neighborhood = propertyMatch.group(1);
        if (neighborhood != null) {
          await _showPropertiesInNeighborhood(neighborhood);
        }
      }
      
      // Check for price range command
      final priceRegex = RegExp(r'SHOW_PRICE_RANGE_IN:\s*(\w+)', caseSensitive: false);
      final priceMatch = priceRegex.firstMatch(content);
      
      if (priceMatch != null && priceMatch.groupCount >= 1) {
        final neighborhood = priceMatch.group(1);
        if (neighborhood != null) {
          await _showPriceRangeInNeighborhood(neighborhood);
        }
      }
      
      // Check for roommate matches command
      if (content.toUpperCase().contains('SHOW_ROOMMATE_MATCHES')) {
        await _showRoommateMatches();
      }
      
      // Check for neighborhoods command
      if (content.toUpperCase().contains('SHOW_ALL_NEIGHBORHOODS')) {
        await _showAllNeighborhoods();
      }
    } catch (e) {
      developer.log('Error processing assistant message: $e', name: 'AGENT_API');
    }
  }
  
  // Show properties in a neighborhood
  Future<void> _showPropertiesInNeighborhood(String neighborhood) async {
    try {
      final result = await _housingDataService.getPropertiesByNeighborhood(neighborhood);
      
      if (result['success'] == true && result['data'] != null) {
        final properties = result['data'] as List<dynamic>;
        
        if (properties.isEmpty) {
          _addAssistantMessage("I couldn't find any properties in $neighborhood at the moment.");
          return;
        }
        
        // Create a formatted message with property listings
        String message = "Here are some properties available in $neighborhood:\n\n";
        
        for (int i = 0; i < properties.length; i++) {
          final property = properties[i] as Map<String, dynamic>;
          message += "${i + 1}. ${property['title']}\n";
          message += "   ${property['bedrooms']} bed, ${property['bathrooms']} bath - \$${property['price']}/${property['currency']}\n";
          message += "   ${property['furnished'] ? 'Furnished' : 'Unfurnished'}\n";
          message += "   ${property['description']}\n\n";
        }
        
        _addAssistantMessage(message);
      } else {
        _addAssistantMessage("I couldn't retrieve property listings for $neighborhood at the moment. Please try again later.");
      }
    } catch (e) {
      developer.log('Error showing properties: $e', name: 'AGENT_API');
      _addAssistantMessage("I encountered an error while retrieving property listings. Please try again later.");
    }
  }
  
  // Show price range in a neighborhood
  Future<void> _showPriceRangeInNeighborhood(String neighborhood) async {
    try {
      final result = await _housingDataService.getPriceRangeByNeighborhood(neighborhood);
      
      if (result['success'] == true && result['data'] != null) {
        final priceRanges = result['data'] as Map<String, dynamic>;
        
        if (priceRanges.isEmpty) {
          _addAssistantMessage("I couldn't find price information for $neighborhood at the moment.");
          return;
        }
        
        // Create a formatted message with price ranges
        String message = "Here are the typical price ranges in $neighborhood:\n\n";
        
        priceRanges.forEach((propertyType, range) {
          final rangeData = range as Map<String, dynamic>;
          message += "${_capitalizeFirstLetter(propertyType)}: \$${rangeData['min']}-${rangeData['max']}/${rangeData['currency']} per month\n";
        });
        
        _addAssistantMessage(message);
      } else {
        _addAssistantMessage("I couldn't retrieve price information for $neighborhood at the moment. Please try again later.");
      }
    } catch (e) {
      developer.log('Error showing price ranges: $e', name: 'AGENT_API');
      _addAssistantMessage("I encountered an error while retrieving price information. Please try again later.");
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
        
        // Create a formatted message with roommate matches
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
        
        // Create a formatted message with neighborhoods
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
  
  // Helper method to capitalize first letter
  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
  
  // Add a user message and generate a response
  void addUserMessage(String content) {
    if (content.trim().isEmpty) return;
    
    try {
      // Add user message
      _messages.add(
        AgentMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: content,
          role: 'user',
          createdAt: DateTime.now().toIso8601String(),
        ),
      );
      
      // If Vapi is available and call is active, send the message to Vapi
      if (_isVapiAvailable && _isCallStarted && _vapi != null) {
        try {
          _vapi?.send({
            "type": "add-message",
            "message": {
              "role": "user",
              "content": content,
            },
          });
        } catch (e) {
          developer.log('Error sending message to Vapi: $e', name: 'AGENT_API');
          // Fallback to local implementation
          _generateSimulatedResponse(content);
        }
      } else {
        // Generate a simulated response
        _generateSimulatedResponse(content);
      }
    } catch (e) {
      developer.log('Error adding user message: $e', name: 'AGENT_API');
    }
  }
  
  // Generate a simulated response
  Future<void> _generateSimulatedResponse(String userMessage) async {
    try {
      final lowerUserMessage = userMessage.toLowerCase();
      
      // Check for specific queries that we can handle with our housing data service
      if (lowerUserMessage.contains('properties in') || lowerUserMessage.contains('apartments in') || 
          lowerUserMessage.contains('houses in') || lowerUserMessage.contains('housing in')) {
        
        // Extract neighborhood name
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
      
      if (lowerUserMessage.contains('price') || lowerUserMessage.contains('cost') || 
          lowerUserMessage.contains('how much') || lowerUserMessage.contains('range')) {
        
        // Extract neighborhood name
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
      
      if (lowerUserMessage.contains('roommate') || lowerUserMessage.contains('share') || 
          lowerUserMessage.contains('sharing') || lowerUserMessage.contains('live with')) {
        await _showRoommateMatches();
        return;
      }
      
      if (lowerUserMessage.contains('neighborhood') || lowerUserMessage.contains('area') || 
          lowerUserMessage.contains('location') || lowerUserMessage.contains('where')) {
        await _showAllNeighborhoods();
        return;
      }
      
      // Simulate API call to get response
      final List<String> responses = [
        "I can help you find housing in Kigali. What neighborhood are you interested in?",
        "In Kacyiru, you can find apartments ranging from 300-500 USD per month.",
        "Shared accommodations in Remera typically cost between 150-250 USD per month.",
        "Kimihurura is a popular neighborhood for students due to its proximity to universities and amenities.",
        "Would you prefer a furnished or unfurnished apartment?",
        "Most apartments in Kigali come with basic amenities like water and electricity, but you may need to pay for these utilities separately."
      ];
      
      // Add some context-aware responses
      if (lowerUserMessage.contains('price') || lowerUserMessage.contains('cost')) {
        responses.add("Prices vary by neighborhood. In Kigali, you can expect to pay between 150-300 USD for shared accommodations and 300-600 USD for single apartments.");
      }
      
      if (lowerUserMessage.contains('roommate') || lowerUserMessage.contains('share')) {
        responses.add("We have a roommate matching service that can help you find compatible roommates based on your preferences and budget.");
      }
      
      if (lowerUserMessage.contains('neighborhood') || lowerUserMessage.contains('area')) {
        responses.add("Popular neighborhoods for students include Kacyiru, Kimihurura, and Remera due to their proximity to universities and amenities.");
      }
      
      if (lowerUserMessage.contains('amenities') || lowerUserMessage.contains('facilities')) {
        responses.add("Most apartments in Kigali come with basic amenities like water and electricity. Premium apartments may include internet, security, and backup generators.");
      }
      
      if (lowerUserMessage.contains('university') || lowerUserMessage.contains('school') || lowerUserMessage.contains('college')) {
        responses.add("If you're looking for housing near educational institutions, Kacyiru and Kimihurura are excellent choices as they're close to several universities.");
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
      // Set _isCallStarted to false immediately
      _isCallStarted = false;
      
      // Stop TTS if initialized
      if (_isTtsInitialized) {
        try {
          _flutterTts.stop();
        } catch (e) {
          developer.log('Error stopping TTS in dispose: $e', name: 'AGENT_API');
        }
      }
      
      // Capture Vapi instance before nullifying it
      final vapiInstance = _vapi;
      _vapi = null;
      
      // Stop Vapi call if active
      if (_isVapiAvailable && vapiInstance != null) {
        try {
          // Send stop command with a timeout
          vapiInstance.stop().timeout(
            const Duration(milliseconds: 500),
            onTimeout: () {
              developer.log('Vapi stop command timed out in dispose', name: 'AGENT_API');
              return;
            },
          );
        } catch (e) {
          developer.log('Error stopping Vapi call in dispose: $e', name: 'AGENT_API');
        }
      }
      
      // Clear messages and add welcome message back
      _messages.clear();
      _messages.add(
        AgentMessage(
          id: 'welcome',
          content: 'Hello! I\'m your DoorMate voice assistant for housing in Kigali. You can ask me about available apartments, houses, roommate options, pricing, neighborhoods, and amenities. Just tap the microphone button to start speaking.',
          role: 'assistant',
          createdAt: DateTime.now().toIso8601String(),
        ),
      );
    } catch (e) {
      developer.log('Error in dispose: $e', name: 'AGENT_API');
    }
  }
} 
