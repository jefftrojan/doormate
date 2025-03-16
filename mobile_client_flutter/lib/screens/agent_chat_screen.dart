import 'package:flutter/material.dart';
import '../widgets/loading_indicator.dart';
import 'dart:developer' as developer;
import '../services/agent_service.dart';
import '../models/agent_message.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

class AgentChatScreen extends StatefulWidget {
  const AgentChatScreen({Key? key}) : super(key: key);

  @override
  State<AgentChatScreen> createState() => _AgentChatScreenState();
}

class _AgentChatScreenState extends State<AgentChatScreen> {
  String _buttonText = 'Start Call';
  bool _isLoading = false;
  bool _isCallStarted = false;
  bool _isListening = false;
  String _statusText = "Tap the button to start a call with the housing assistant";
  
  // Agent service instance
  final AgentService _agentService = AgentService();
  List<AgentMessage> _messages = [];
  String? _conversationId;
  
  // Message refresh timer
  Timer? _messageRefreshTimer;
  
  // Text input controller
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeConversation();
  }
  
  Future<void> _initializeConversation() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      _conversationId = await _agentService.createConversation();
      _messages = _agentService.getMessages();
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      
      developer.log('Conversation initialized with ID: $_conversationId', name: 'AGENT_SCREEN');
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusText = "Failed to initialize conversation. Please try again.";
        });
      }
      developer.log('Error initializing conversation: $e', name: 'AGENT_SCREEN');
    }
  }

  Future<void> _toggleCall() async {
    if (!mounted) return;
    
    // Cancel any existing timer to prevent UI updates during call state changes
    _messageRefreshTimer?.cancel();
    
    setState(() {
      _buttonText = 'Loading...';
      _isLoading = true;
    });

    if (!_isCallStarted) {
      // Request microphone permission
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        if (mounted) {
          setState(() {
            _buttonText = 'Start Call';
            _isLoading = false;
            _statusText = "Microphone permission denied. Please enable it in settings.";
          });
        }
        developer.log('Microphone permission denied', name: 'AGENT_SCREEN');
        return;
      }
      
      // Start call
      try {
        // Update UI immediately to show call is starting
        if (mounted) {
          setState(() {
            _buttonText = 'End Call';
            _isLoading = true;
            _isCallStarted = true;
            _statusText = "Starting call...";
          });
        }
        
        final success = await _agentService.startCall();
        
        if (success && mounted) {
          setState(() {
            _isLoading = false;
            _statusText = "Call connected. Speak to the housing assistant now.";
          });
          
          developer.log('Call started', name: 'AGENT_SCREEN');
          
          // Start message refresh timer
          _startMessageRefreshTimer();
        } else if (mounted) {
          setState(() {
            _buttonText = 'Start Call';
            _isLoading = false;
            _isCallStarted = false;
            _statusText = "Failed to start call. You can still type your questions below.";
          });
          developer.log('Failed to start call', name: 'AGENT_SCREEN');
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _buttonText = 'Start Call';
            _isLoading = false;
            _isCallStarted = false;
            _statusText = "Error starting call: ${e.toString()}";
          });
        }
        developer.log('Error in _toggleCall: $e', name: 'AGENT_SCREEN');
      }
    } else {
      // End call
      try {
        // Update UI immediately to show call is ending
        if (mounted) {
          setState(() {
            _buttonText = 'Start Call';
            _isLoading = true;
            _statusText = "Ending call...";
          });
        }
        
        // Cancel message refresh timer
        _messageRefreshTimer?.cancel();
        
        // End the call
        await _agentService.endCall();
        
        if (mounted) {
          setState(() {
            _isLoading = false;
            _isCallStarted = false;
            _isListening = false;
            _statusText = "Call ended. Tap the button to start a new call.";
          });
        }
        developer.log('Call ended', name: 'AGENT_SCREEN');
      } catch (e) {
        if (mounted) {
          setState(() {
            _buttonText = 'Start Call';
            _isLoading = false;
            _isCallStarted = false;
            _isListening = false;
            _statusText = "Error ending call: ${e.toString()}";
          });
        }
        developer.log('Error ending call: $e', name: 'AGENT_SCREEN');
      }
    }
    
    // Refresh messages
    if (mounted) {
      setState(() {
        _messages = _agentService.getMessages();
      });
    }
    
    // Scroll to bottom
    _scrollToBottom();
  }
  
  // Start message refresh timer
  void _startMessageRefreshTimer() {
    // Cancel any existing timer
    _messageRefreshTimer?.cancel();
    
    // Create a new timer that refreshes messages every second
    _messageRefreshTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_isCallStarted && mounted) {
        setState(() {
          _messages = _agentService.getMessages();
        });
        
        // Scroll to bottom if new messages
        if (_messages.isNotEmpty) {
          _scrollToBottom();
        }
      } else {
        // Cancel timer if call is not active
        timer.cancel();
      }
    });
  }
  
  void _sendTextMessage() {
    if (_textController.text.trim().isEmpty) return;
    
    final message = _textController.text.trim();
    _textController.clear();
    
    // Add user message
    _agentService.addUserMessage(message);
    
    // Refresh messages
    if (mounted) {
      setState(() {
        _messages = _agentService.getMessages();
      });
    }
    
    // Scroll to bottom
    _scrollToBottom();
  }
  
  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    // Cancel message refresh timer
    _messageRefreshTimer?.cancel();
    
    // Clean up resources
    if (_isCallStarted) {
      // End call if active
      _agentService.dispose();
      developer.log('Ending call on dispose', name: 'AGENT_SCREEN');
    }
    
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Housing Assistant'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _buildMessageList(),
            ),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMessageList() {
    if (_isLoading && _messages.isEmpty) {
      return const Center(
        child: LoadingIndicator(size: 48),
      );
    }
    
    if (_messages.isEmpty) {
      return const Center(
        child: Text(
          'No messages yet. Start a call to begin the conversation.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }
    
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final isUser = message.role == 'user';
        
        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUser ? Theme.of(context).colorScheme.primary : Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            child: Text(
              message.content,
              style: TextStyle(
                color: isUser ? Colors.white : Colors.black,
                fontSize: 16,
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildInputArea() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Status and call button
        Container(
          padding: const EdgeInsets.all(8),
          color: Colors.grey[100],
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _statusText,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : IconButton(
                      onPressed: _toggleCall,
                      icon: Icon(
                        _isCallStarted ? Icons.call_end : Icons.call,
                        color: _isCallStarted ? Colors.red : Theme.of(context).colorScheme.primary,
                      ),
                      tooltip: _isCallStarted ? 'End Call' : 'Start Call',
                    ),
            ],
          ),
        ),
        
        // Text input
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    hintText: 'Type your message...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendTextMessage(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _sendTextMessage,
                icon: Icon(
                  Icons.send,
                  color: Theme.of(context).colorScheme.primary,
                ),
                tooltip: 'Send message',
              ),
            ],
          ),
        ),
        
        // Call status indicator
        if (_isCallStarted)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            color: Colors.blue.withOpacity(0.1),
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.mic_none,
                  color: Colors.blue,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Voice call active',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
} 