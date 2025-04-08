import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_client_flutter/models/chat_message.dart';
import 'package:mobile_client_flutter/providers/ai_assistant_provider.dart';
import 'package:mobile_client_flutter/widgets/glass_container.dart';
import 'package:mobile_client_flutter/widgets/gradient_background.dart';
import 'package:mobile_client_flutter/widgets/animated_fade_slide.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  bool _showInsights = false;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    // Start animation after a short delay
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _animationController.forward();
      }
    });
    
    // Load chat history and insights
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final aiProvider = Provider.of<AIAssistantProvider>(context, listen: false);
      
      // Try to load chat history
      aiProvider.loadChatHistory().then((_) {
        developer.log('Chat history loaded', name: 'AI_ASSISTANT_SCREEN');
        
        // If no messages, add initial welcome message
        if (aiProvider.messages.isEmpty) {
          developer.log('No chat history found, sending welcome message', name: 'AI_ASSISTANT_SCREEN');
          aiProvider.sendMessage('Hello');
        }
        
        // Scroll to bottom after messages are loaded
        _scrollToBottom();
      }).catchError((error) {
        developer.log('Error loading chat history: $error', name: 'AI_ASSISTANT_SCREEN');
      });
      
      // Load AI insights
      aiProvider.loadInsights().then((_) {
        developer.log('AI insights loaded', name: 'AI_ASSISTANT_SCREEN');
      }).catchError((error) {
        developer.log('Error loading AI insights: $error', name: 'AI_ASSISTANT_SCREEN');
      });
    });
  }
  
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  
  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;
    
    final aiProvider = Provider.of<AIAssistantProvider>(context, listen: false);
    aiProvider.sendMessage(message);
    
    _messageController.clear();
    
    // Scroll to bottom after message is sent
    _scrollToBottom();
  }
  
  void _clearMessages() {
    final provider = Provider.of<AIAssistantProvider>(context, listen: false);
    
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Conversation'),
        content: const Text('Are you sure you want to clear this conversation? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              provider.clearChatHistory();
            },
            child: const Text('CLEAR'),
          ),
        ],
      ),
    );
  }
  
  void _toggleInsights() {
    setState(() {
      _showInsights = !_showInsights;
    });
  }
  
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);
    
    if (messageDate == today) {
      return DateFormat('h:mm a').format(timestamp);
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday, ${DateFormat('h:mm a').format(timestamp)}';
    } else {
      return DateFormat('MMM d, h:mm a').format(timestamp);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('AI Assistant'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_showInsights ? Icons.chat : Icons.insights),
            onPressed: _toggleInsights,
            tooltip: _showInsights ? 'Show Chat' : 'Show Insights',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _clearMessages,
            tooltip: 'Clear Conversation',
          ),
        ],
      ),
      body: GradientBackground(
        child: SafeArea(
          child: Consumer<AIAssistantProvider>(
            builder: (context, aiProvider, child) {
              // Show loading indicator if loading history
              if (aiProvider.isLoadingHistory) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              
              // Show error if there is one
              if (aiProvider.error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Something went wrong',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        aiProvider.error!,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          aiProvider.clearError();
                          aiProvider.loadChatHistory();
                        },
                        child: const Text('RETRY'),
                      ),
                    ],
                  ),
                );
              }
              
              return Column(
                children: [
                  // Chat messages or Insights
                  Expanded(
                    child: _showInsights 
                      ? _buildInsightsView(aiProvider)
                      : _buildChatView(aiProvider),
                  ),
                  
                  // Input field (only show in chat view)
                  if (!_showInsights)
                    GlassContainer(
                      borderRadius: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              decoration: const InputDecoration(
                                hintText: 'Ask me about listings, roommates, etc...',
                                border: InputBorder.none,
                              ),
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                          aiProvider.isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : IconButton(
                                icon: const Icon(Icons.send),
                                color: Theme.of(context).primaryColor,
                                onPressed: _sendMessage,
                              ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
  
  Widget _buildChatView(AIAssistantProvider aiProvider) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
    
    if (aiProvider.messages.isEmpty) {
      return const Center(
        child: Text('No messages yet. Start a conversation!'),
      );
    }
    
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: aiProvider.messages.length,
      itemBuilder: (context, index) {
        final message = aiProvider.messages[index];
        return AnimatedFadeSlide(
          controller: _animationController,
          delay: Duration(milliseconds: 100 * index),
          child: _buildMessageBubble(message),
        );
      },
    );
  }
  
  Widget _buildInsightsView(AIAssistantProvider aiProvider) {
    if (aiProvider.isLoadingInsights) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (aiProvider.insights.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.insights, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No insights available yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Continue chatting to generate insights about your preferences',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                aiProvider.loadInsights();
              },
              child: const Text('REFRESH'),
            ),
          ],
        ),
      );
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI Insights',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Top preferences
          if (aiProvider.insights.containsKey('top_preferences'))
            _buildInsightSection(
              context,
              'Top Preferences',
              Icons.favorite,
              (aiProvider.insights['top_preferences'] as List<dynamic>)
                .map((item) => '${item['name']} (${item['count']})')
                .toList(),
            ),
          
          // Popular locations
          if (aiProvider.insights.containsKey('popular_locations'))
            _buildInsightSection(
              context,
              'Popular Locations',
              Icons.location_on,
              (aiProvider.insights['popular_locations'] as List<dynamic>)
                .map((item) => '${item['name']} (${item['count']})')
                .toList(),
            ),
          
          // Average budget
          if (aiProvider.insights.containsKey('average_budget'))
            _buildInsightSection(
              context,
              'Average Budget',
              Icons.attach_money,
              ['${'${aiProvider.insights['average_budget']}'} per month'],
            ),
          
          // Recommendation
          if (aiProvider.insights.containsKey('recommendation'))
            _buildInsightSection(
              context,
              'Recommendation',
              Icons.lightbulb,
              [aiProvider.insights['recommendation']],
            ),
        ],
      ),
    );
  }
  
  Widget _buildInsightSection(
    BuildContext context,
    String title,
    IconData icon,
    List<String> items,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: GlassContainer(
        borderRadius: 16,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                item,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            )),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isFromCurrentUser;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser)
            CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.assistant, color: Colors.white),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                GlassContainer(
                  borderRadius: 16,
                  padding: const EdgeInsets.all(12),
                  color: isUser ? Theme.of(context).primaryColor : Colors.white,
                  opacity: isUser ? 0.2 : 0.1,
                  child: Text(
                    message.content,
                    style: TextStyle(
                      color: isUser ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTimestamp(message.timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isUser)
            CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.person, color: Colors.white),
            ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }
} 