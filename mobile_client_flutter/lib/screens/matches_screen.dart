import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_client_flutter/models/roommate_match.dart';
import 'package:mobile_client_flutter/providers/match_provider.dart';
import 'package:mobile_client_flutter/widgets/gradient_background.dart';
import 'package:mobile_client_flutter/widgets/gradient_glass_container.dart';
import 'package:mobile_client_flutter/widgets/animated_fade_slide.dart';
import 'package:mobile_client_flutter/widgets/animated_button.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _showContent = false;
  int _currentIndex = 0;
  final PageController _pageController = PageController();

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
    
    // Load matches
    _loadMatches();
  }

  Future<void> _loadMatches() async {
    try {
      await Provider.of<MatchProvider>(context, listen: false).fetchMatches();
    } catch (e) {
      if (mounted) {
        _handleError('Failed to load matches: $e');
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _confirmMatch(RoommateMatch match) async {
    final provider = Provider.of<MatchProvider>(context, listen: false);
    final success = await provider.confirmMatch(match.id);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You matched with ${match.matchedUser?['name'] ?? 'this user'}!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Navigate to chat screen
      Navigator.pushNamed(context, '/chat', arguments: match.id);
    }
  }

  void _rejectMatch(RoommateMatch match) async {
    final provider = Provider.of<MatchProvider>(context, listen: false);
    final success = await provider.rejectMatch(match.id);
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You rejected ${match.matchedUser?['name'] ?? 'this user'}.'),
        ),
      );
      
      // Move to next match if available
      if (_currentIndex < provider.matches.length) {
        _pageController.animateToPage(
          _currentIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        // No more matches
        setState(() {
          _currentIndex = 0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<MatchProvider>(context);
    final matches = provider.matches;
    
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
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AnimatedFadeSlide(
                      show: _showContent,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: theme.primaryColor,
                        ),
                      ),
                    ),
                    AnimatedFadeSlide(
                      show: _showContent,
                      delay: const Duration(milliseconds: 100),
                      child: Text(
                        'Your Matches',
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              
              if (provider.isLoading)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (provider.error != null)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Error loading matches',
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
                          onPressed: () {
                            provider.fetchMatches();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              else if (matches.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: theme.primaryColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No matches found',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'We\'re still looking for your perfect roommate match.',
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            provider.fetchMatches();
                          },
                          child: const Text('Refresh'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          onPageChanged: _onPageChanged,
                          itemCount: matches.length,
                          itemBuilder: (context, index) {
                            final match = matches[index];
                            return _buildMatchCard(context, match);
                          },
                        ),
                      ),
                      
                      // Page indicator
                      if (matches.length > 1)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(matches.length, (index) {
                              return Container(
                                width: 10,
                                height: 10,
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _currentIndex == index
                                      ? theme.primaryColor
                                      : theme.primaryColor.withOpacity(0.3),
                                ),
                              );
                            }),
                          ),
                        ),
                      
                      // Action buttons
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            AnimatedFadeSlide(
                              show: _showContent,
                              delay: const Duration(milliseconds: 300),
                              child: FloatingActionButton(
                                onPressed: () {
                                  if (matches.isNotEmpty && _currentIndex < matches.length) {
                                    _rejectMatch(matches[_currentIndex]);
                                  }
                                },
                                backgroundColor: Colors.red,
                                child: const Icon(Icons.close, color: Colors.white),
                              ),
                            ),
                            AnimatedFadeSlide(
                              show: _showContent,
                              delay: const Duration(milliseconds: 400),
                              child: FloatingActionButton(
                                onPressed: () {
                                  if (matches.isNotEmpty && _currentIndex < matches.length) {
                                    _confirmMatch(matches[_currentIndex]);
                                  }
                                },
                                backgroundColor: Colors.green,
                                child: const Icon(Icons.check, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMatchCard(BuildContext context, RoommateMatch match) {
    final theme = Theme.of(context);
    
    return GradientGlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(20),
      gradientColors: [
        theme.primaryColor.withOpacity(0.1),
        theme.primaryColor.withOpacity(0.05),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Image
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                match.profileImage ?? 'https://placeholder.com/user',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: theme.primaryColor.withOpacity(0.1),
                  child: Icon(Icons.person, size: 64, color: theme.primaryColor),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Name and Match Score
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                match.name,
                style: theme.textTheme.titleLarge,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(match.matchScore * 100).round()}% Match',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Match Details
          Text(
            match.bio ?? 'No bio available',
            style: theme.textTheme.bodyMedium,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 16),
          
          // Compatibility Indicators
          ...match.compatibilityFactors.entries.map((entry) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.key,
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: entry.value,
                backgroundColor: Colors.grey.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getColorForScore(entry.value),
                ),
              ),
              const SizedBox(height: 8),
            ],
          )).toList(),
        ],
      ),
    );
  }

  Color _getColorForScore(double score) {
    if (score >= 0.8) return Colors.green;
    if (score >= 0.6) return Colors.orange;
    if (score >= 0.4) return Colors.amber;
    return Colors.red;
  }

  void _handleError(String error) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}