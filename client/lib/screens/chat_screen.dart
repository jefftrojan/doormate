import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:mobile_client_flutter/models/chat_message.dart';
import 'package:mobile_client_flutter/providers/messaging_provider.dart';
import 'package:mobile_client_flutter/widgets/gradient_background.dart';
import 'package:mobile_client_flutter/widgets/gradient_glass_container.dart';
import 'package:mobile_client_flutter/widgets/animated_fade_slide.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _showContent = false;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _chatId;
  Map<String, dynamic>? _chatData;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    // Delay showing content for a smoother entrance
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _showContent = true;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Get chat ID from route arguments
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is String && _chatId != args) {
      _chatId = args;
      
      // Load chat data and messages
      _loadChat();
    }
  }

  Future<void> _loadChat() async {
    if (_chatId == null) return;
    
    final provider = Provider.of<MessagingProvider>(context, listen: false);
    
    // Find chat data
    _chatData = provider.chats.firstWhere(
      (chat) => chat['id'] == _chatId,
      orElse: () => {
        'id': _chatId,
        'other_user': {
          'name': 'User',
          'image': null,
        },
      },
    );
    
    // Set current chat and load messages
    await provider.setCurrentChat(_chatId!);
    
    // Scroll to bottom after messages load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _chatId == null) return;
    
    _messageController.clear();
    
    final provider = Provider.of<MessagingProvider>(context, listen: false);
    await provider.sendMessage(message);
    
    // Scroll to bottom after sending
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    
    // Clear current chat when leaving
    final provider = Provider.of<MessagingProvider>(context, listen: false);
    provider.clearCurrentChat();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<MessagingProvider>(context);
    final messages = provider.currentMessages;
    final otherUser = _chatData?['other_user'] ?? {};
    
    return Scaffold(
      body: GradientBackground(
        colors: const [
          Color(0xFFF8F0E5),
          Color(0xFFEADBC8),
          Color(0xFFDAC0A3),
          Color(0xFFBCAA94),
        ],
        useCircularGradient: true,
        child: SafeArea(
          child: Column(
            children: [
              // Chat header
              AnimatedFadeSlide(
                show: _showContent,
                child: GradientGlassContainer(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  borderRadius: BorderRadius.circular(0),
                  gradientColors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.1),
                  ],
                  border: Border(
                    bottom: BorderSide(
                      color: theme.primaryColor.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: theme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: theme.primaryColor.withOpacity(0.2),
                        backgroundImage: otherUser['image'] != null
                            ? NetworkImage(otherUser['image'])
                            : null,
                        child: otherUser['image'] == null
                            ? Text(
                                (otherUser['name'] ?? 'User')
                                    .substring(0, 1)
                                    .toUpperCase(),
                                style: TextStyle(
                                  color: theme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              otherUser['name'] ?? 'User',
                              style: theme.textTheme.titleMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              provider.isLoading ? 'Loading...' : 'Online',
                              style: TextStyle(
                                color: theme.primaryColor.withOpacity(0.6),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Messages
              Expanded(
                child: provider.isLoading && messages.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : provider.error != null && messages.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    size: 64,
                                    color: theme.primaryColor.withOpacity(0.7),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Something went wrong',
                                    style: theme.textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    provider.error!,
                                    style: theme.textTheme.bodyMedium,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: _loadChat,
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : messages.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.chat_bubble_outline,
                                      size: 64,
                                      color: theme.primaryColor,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No messages yet',
                                      style: theme.textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Start the conversation!',
                                      style: theme.textTheme.bodyMedium,
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                controller: _scrollController,
                                padding: const EdgeInsets.all(16),
                                itemCount: messages.length,
                                itemBuilder: (context, index) {
                                  final message = messages[index];
                                  final isFromCurrentUser = provider.isMessageFromCurrentUser(message);
                                  final showAvatar = index == 0 || 
                                      messages[index - 1].senderId != message.senderId;
                                  
                                  return AnimatedFadeSlide(
                                    show: _showContent,
                                    delay: Duration(milliseconds: 100 + (index * 30)),
                                    child: Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        mainAxisAlignment: isFromCurrentUser
                                            ? MainAxisAlignment.end
                                            : MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          if (!isFromCurrentUser && showAvatar)
                                            CircleAvatar(
                                              radius: 16,
                                              backgroundColor: theme.primaryColor.withOpacity(0.2),
                                              backgroundImage: otherUser['image'] != null
                                                  ? NetworkImage(otherUser['image'])
                                                  : null,
                                              child: otherUser['image'] == null
                                                  ? Text(
                                                      (otherUser['name'] ?? 'User')
                                                          .substring(0, 1)
                                                          .toUpperCase(),
                                                      style: TextStyle(
                                                        color: theme.primaryColor,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 12,
                                                      ),
                                                    )
                                                  : null,
                                            )
                                          else if (!isFromCurrentUser)
                                            const SizedBox(width: 32),
                                          
                                          const SizedBox(width: 8),
                                          
                                          Flexible(
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 10,
                                              ),
                                              decoration: BoxDecoration(
                                                color: isFromCurrentUser
                                                    ? theme.primaryColor
                                                    : Colors.white.withOpacity(0.8),
                                                borderRadius: BorderRadius.circular(16).copyWith(
                                                  bottomLeft: isFromCurrentUser
                                                      ? const Radius.circular(16)
                                                      : const Radius.circular(0),
                                                  bottomRight: !isFromCurrentUser
                                                      ? const Radius.circular(16)
                                                      : const Radius.circular(0),
                                                ),
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    message.content,
                                                    style: TextStyle(
                                                      color: isFromCurrentUser
                                                          ? Colors.white
                                                          : theme.primaryColor,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    _formatTimestamp(message.timestamp),
                                                    style: TextStyle(
                                                      color: isFromCurrentUser
                                                          ? Colors.white.withOpacity(0.7)
                                                          : theme.primaryColor.withOpacity(0.6),
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          
                                          const SizedBox(width: 8),
                                          
                                          if (isFromCurrentUser && message.isRead)
                                            Icon(
                                              Icons.done_all,
                                              size: 16,
                                              color: theme.primaryColor,
                                            )
                                          else if (isFromCurrentUser)
                                            Icon(
                                              Icons.done,
                                              size: 16,
                                              color: theme.primaryColor.withOpacity(0.5),
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
              ),
              
              // Message input
              AnimatedFadeSlide(
                show: _showContent,
                delay: const Duration(milliseconds: 300),
                child: GradientGlassContainer(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  borderRadius: BorderRadius.circular(0),
                  gradientColors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.1),
                  ],
                  border: Border(
                    top: BorderSide(
                      color: theme.primaryColor.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          // Attachment functionality would go here
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Attachment feature coming soon!'),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.attach_file,
                          color: theme.primaryColor,
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.5),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      IconButton(
                        onPressed: _sendMessage,
                        icon: Icon(
                          Icons.send,
                          color: theme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
} 