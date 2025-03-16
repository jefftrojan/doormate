import 'package:flutter/material.dart';
import 'package:mobile_client_flutter/screens/account_settings_screen.dart';
import 'package:mobile_client_flutter/screens/matches_screen.dart';
import 'package:mobile_client_flutter/screens/preferences_setup_screen.dart';
import 'package:mobile_client_flutter/widgets/glass_container.dart';
import 'package:mobile_client_flutter/widgets/animated_fade_slide.dart';
import 'package:mobile_client_flutter/widgets/animated_button.dart';
import 'package:mobile_client_flutter/widgets/gradient_background.dart';
import 'package:mobile_client_flutter/screens/listings_screen.dart';
import 'package:mobile_client_flutter/screens/agent_chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  
  // List of screens to display
  late final List<Widget> _screens;
  
  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeTab(),
      const ListingsTab(),
      const ExploreTab(),
      const MatchesTab(),
      const MessagesTab(),
      const ProfileTab(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
              backgroundColor: theme.primaryColor,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.apartment_rounded),
              label: 'Listings',
              backgroundColor: theme.primaryColor,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_rounded),
              label: 'Explore',
              backgroundColor: theme.primaryColor,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_rounded),
              label: 'Matches',
              backgroundColor: theme.primaryColor,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_rounded),
              label: 'Messages',
              backgroundColor: theme.primaryColor,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
              backgroundColor: theme.primaryColor,
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: theme.primaryColor,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with SingleTickerProviderStateMixin {
  bool _isLookingForRoommate = true;
  bool _showContent = false;
  late AnimationController _animationController;

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
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App Bar
                AnimatedFadeSlide(
                  show: _showContent,
                  direction: AnimationDirection.fromTop,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'DoorMate',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                      CircleAvatar(
                        backgroundColor: theme.primaryColor.withOpacity(0.1),
                        child: Icon(
                          Icons.notifications_outlined,
                          color: theme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Welcome message
                AnimatedFadeSlide(
                  show: _showContent,
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    'Welcome to DoorMate!',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                AnimatedFadeSlide(
                  show: _showContent,
                  delay: const Duration(milliseconds: 300),
                  child: Text(
                    'Find your perfect roommate match',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.primaryColor.withOpacity(0.8),
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Roommate Status Card
                AnimatedFadeSlide(
                  show: _showContent,
                  delay: const Duration(milliseconds: 400),
                  child: GradientGlassContainer(
                    padding: const EdgeInsets.all(24),
                    borderRadius: BorderRadius.circular(24),
                    gradientColors: [
                      Colors.white.withOpacity(0.2),
                      Colors.white.withOpacity(0.1),
                    ],
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Roommate Status',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: theme.primaryColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _isLookingForRoommate ? Icons.search : Icons.check_circle,
                                color: theme.primaryColor,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _isLookingForRoommate 
                                        ? 'Looking for a roommate' 
                                        : 'Not looking for a roommate',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: theme.primaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _isLookingForRoommate
                                        ? 'You are visible to potential matches'
                                        : 'You are not visible to potential matches',
                                    style: TextStyle(
                                      color: theme.primaryColor.withOpacity(0.7),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _isLookingForRoommate,
                              onChanged: (value) {
                                setState(() {
                                  _isLookingForRoommate = value;
                                });
                              },
                              activeColor: theme.primaryColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Stats Section
                AnimatedFadeSlide(
                  show: _showContent,
                  delay: const Duration(milliseconds: 500),
                  child: Row(
                    children: [
                      Expanded(
                        child: GlassContainer(
                          padding: const EdgeInsets.all(20),
                          borderRadius: BorderRadius.circular(20),
                          child: Column(
                            children: [
                              Icon(
                                Icons.visibility,
                                color: theme.primaryColor,
                                size: 32,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '24',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.primaryColor,
                                ),
                              ),
                              Text(
                                'Profile Views',
                                style: TextStyle(
                                  color: theme.primaryColor.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GlassContainer(
                          padding: const EdgeInsets.all(20),
                          borderRadius: BorderRadius.circular(20),
                          child: Column(
                            children: [
                              Icon(
                                Icons.favorite,
                                color: theme.primaryColor,
                                size: 32,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '5',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.primaryColor,
                                ),
                              ),
                              Text(
                                'Matches',
                                style: TextStyle(
                                  color: theme.primaryColor.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GlassContainer(
                          padding: const EdgeInsets.all(20),
                          borderRadius: BorderRadius.circular(20),
                          child: Column(
                            children: [
                              Icon(
                                Icons.message,
                                color: theme.primaryColor,
                                size: 32,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '3',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.primaryColor,
                                ),
                              ),
                              Text(
                                'Messages',
                                style: TextStyle(
                                  color: theme.primaryColor.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Quick Actions
                AnimatedFadeSlide(
                  show: _showContent,
                  delay: const Duration(milliseconds: 600),
                  child: Text(
                    'Quick Actions',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                AnimatedFadeSlide(
                  show: _showContent,
                  delay: const Duration(milliseconds: 700),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          context,
                          Icons.tune,
                          'Preferences',
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PreferencesSetupScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildActionCard(
                          context,
                          Icons.lock_rounded,
                          'Account',
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AccountSettingsScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                AnimatedFadeSlide(
                  show: _showContent,
                  delay: const Duration(milliseconds: 800),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          context,
                          Icons.add_home,
                          'Create Listing',
                          () {
                            Navigator.pushNamed(context, '/create-listing');
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildActionCard(
                          context,
                          Icons.smart_toy,
                          'AI Assistant',
                          () {
                            Navigator.pushNamed(context, '/ai-assistant');
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                AnimatedFadeSlide(
                  show: _showContent,
                  delay: const Duration(milliseconds: 900),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          context,
                          Icons.voice_chat,
                          'Housing Agent',
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AgentChatScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildActionCard(
                          context,
                          Icons.person_search,
                          'Find Matches',
                          () {
                            // Navigate to Explore tab
                            (context.findAncestorStateOfType<_HomeScreenState>())?._onItemTapped(2);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildActionCard(
                          context,
                          Icons.help_outline,
                          'Help & FAQ',
                          () {
                            // Show help dialog
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Help & FAQ'),
                                content: const Text('Need help? Contact us at support@doormate.com'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Close'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 24,
                color: theme.primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: theme.primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class ListingsTab extends StatelessWidget {
  const ListingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const ListingsScreen();
  }
}

class ExploreTab extends StatefulWidget {
  const ExploreTab({super.key});

  @override
  State<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab> with SingleTickerProviderStateMixin {
  bool _showContent = false;
  late AnimationController _animationController;
  final List<Map<String, dynamic>> _potentialMatches = [];
  int _currentIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    // Generate mock data
    _generateMockData();
    
    // Delay showing content for a smoother entrance
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _showContent = true;
        });
      }
    });
  }
  
  void _generateMockData() {
    final List<String> universities = [
      'University of Rwanda',
      'Carnegie Mellon University Africa',
      'African Leadership University',
      'Mount Kenya University',
      'Kigali Independent University',
    ];
    
    final List<String> studyHabits = [
      'Night owl',
      'Early bird',
      'Regular study sessions',
      'Weekend studier',
      'Study with music',
    ];
    
    final List<String> lifestyles = [
      'Very social',
      'Quiet and reserved',
      'Balanced social life',
      'Fitness enthusiast',
      'Creative and artistic',
    ];
    
    for (int i = 0; i < 10; i++) {
      _potentialMatches.add({
        'name': 'User ${i + 1}',
        'email': 'user${i + 1}@${universities[i % universities.length].toLowerCase().replaceAll(' ', '')}.ac.rw',
        'university': universities[i % universities.length],
        'year': (i % 4) + 1,
        'compatibility': 0.65 + (i * 0.03),
        'studyHabit': studyHabits[i % studyHabits.length],
        'lifestyle': lifestyles[i % lifestyles.length],
        'budget': '\$${300 + (i * 50)}-\$${400 + (i * 50)}/month',
        'location': i % 2 == 0 ? 'Near campus' : 'City center',
        'bio': 'Hi, I\'m User ${i + 1}! I\'m a year ${(i % 4) + 1} student looking for a roommate who is ${i % 2 == 0 ? 'clean and organized' : 'respectful and friendly'}. I enjoy ${i % 3 == 0 ? 'quiet evenings and occasional social gatherings' : i % 3 == 1 ? 'sports and outdoor activities' : 'music and arts'}.',
      });
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  void _onSwipeRight() {
    // Like the current profile
    if (_currentIndex < _potentialMatches.length - 1) {
      setState(() {
        _currentIndex++;
      });
    }
  }
  
  void _onSwipeLeft() {
    // Skip the current profile
    if (_currentIndex < _potentialMatches.length - 1) {
      setState(() {
        _currentIndex++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App Bar
                AnimatedFadeSlide(
                  show: _showContent,
                  direction: AnimationDirection.fromTop,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Explore',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                      CircleAvatar(
                        backgroundColor: theme.primaryColor.withOpacity(0.1),
                        child: Icon(
                          Icons.search,
                          color: theme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Explore options
                AnimatedFadeSlide(
                  show: _showContent,
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    'Discover',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                AnimatedFadeSlide(
                  show: _showContent,
                  delay: const Duration(milliseconds: 300),
                  child: Text(
                    'Find housing and roommates in Kigali',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.primaryColor.withOpacity(0.8),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Explore Cards
                AnimatedFadeSlide(
                  show: _showContent,
                  delay: const Duration(milliseconds: 400),
                  child: _buildExploreCard(
                    context,
                    title: 'Property Map',
                    description: 'Explore available properties on a map',
                    icon: Icons.map_outlined,
                    onTap: () {
                      Navigator.pushNamed(context, '/map-view');
                    },
                  ),
                ),
                
                const SizedBox(height: 16),
                
                AnimatedFadeSlide(
                  show: _showContent,
                  delay: const Duration(milliseconds: 500),
                  child: _buildExploreCard(
                    context,
                    title: 'Roommate Matching',
                    description: 'Find compatible roommates based on your preferences',
                    icon: Icons.people_outline,
                    onTap: () {
                      Navigator.pushNamed(context, '/roommate-matching');
                    },
                  ),
                ),
                
                const SizedBox(height: 16),
                
                AnimatedFadeSlide(
                  show: _showContent,
                  delay: const Duration(milliseconds: 600),
                  child: _buildExploreCard(
                    context,
                    title: 'Voice Assistant',
                    description: 'Ask our AI assistant about housing in Kigali',
                    icon: Icons.mic_outlined,
                    onTap: () {
                      Navigator.pushNamed(context, '/agent-chat');
                    },
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Popular Neighborhoods
                AnimatedFadeSlide(
                  show: _showContent,
                  delay: const Duration(milliseconds: 700),
                  child: Text(
                    'Popular Neighborhoods',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                AnimatedFadeSlide(
                  show: _showContent,
                  delay: const Duration(milliseconds: 800),
                  child: SizedBox(
                    height: 120,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildNeighborhoodCard(context, 'Kacyiru'),
                        _buildNeighborhoodCard(context, 'Kimihurura'),
                        _buildNeighborhoodCard(context, 'Remera'),
                        _buildNeighborhoodCard(context, 'Nyamirambo'),
                        _buildNeighborhoodCard(context, 'Kicukiro'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildExploreCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: theme.primaryColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: theme.primaryColor,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildNeighborhoodCard(BuildContext context, String neighborhood) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/map-view-neighborhood',
          arguments: neighborhood,
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_on,
              color: theme.primaryColor,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              neighborhood,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'View properties',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MatchesTab extends StatefulWidget {
  const MatchesTab({super.key});

  @override
  State<MatchesTab> createState() => _MatchesTabState();
}

class _MatchesTabState extends State<MatchesTab> with SingleTickerProviderStateMixin {
  bool _showContent = false;
  late AnimationController _animationController;
  
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
    
    // Navigate to matches screen automatically
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushNamed(context, '/matches');
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
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
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: theme.primaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'Loading matches...',
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MessagesTab extends StatefulWidget {
  const MessagesTab({super.key});

  @override
  State<MessagesTab> createState() => _MessagesTabState();
}

class _MessagesTabState extends State<MessagesTab> with SingleTickerProviderStateMixin {
  bool _showContent = false;
  late AnimationController _animationController;
  
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
    
    // Navigate to chat list screen automatically
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushNamed(context, '/chats');
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
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
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: theme.primaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'Loading messages...',
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> with SingleTickerProviderStateMixin {
  bool _showContent = false;
  late AnimationController _animationController;
  
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
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App Bar
                AnimatedFadeSlide(
                  show: _showContent,
                  direction: AnimationDirection.fromTop,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'My Profile',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.settings,
                              color: theme.primaryColor,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AccountSettingsScreen(),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.logout,
                              color: theme.primaryColor,
                            ),
                            onPressed: () {
                              _showLogoutDialog();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Profile Header
                AnimatedFadeSlide(
                  show: _showContent,
                  delay: const Duration(milliseconds: 200),
                  child: Center(
                    child: Column(
                      children: [
                        GradientGlassContainer(
                          height: 120,
                          width: 120,
                          borderRadius: BorderRadius.circular(60),
                          gradientColors: [
                            Colors.white.withOpacity(0.2),
                            Colors.white.withOpacity(0.1),
                          ],
                          child: Center(
                            child: Icon(
                              Icons.person,
                              size: 60,
                              color: theme.primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'John Doe',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'University of Rwanda • Year 3',
                          style: TextStyle(
                            fontSize: 16,
                            color: theme.primaryColor.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 16),
                        AnimatedButton(
                          onPressed: () {
                            // Navigate to edit profile
                          },
                          isOutlined: true,
                          borderColor: theme.primaryColor,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.edit,
                                color: theme.primaryColor,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Edit Profile',
                                style: TextStyle(
                                  color: theme.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // About Me Section
                AnimatedFadeSlide(
                  show: _showContent,
                  delay: const Duration(milliseconds: 300),
                  child: GlassContainer(
                    padding: const EdgeInsets.all(20),
                    borderRadius: BorderRadius.circular(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'About Me',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'I am a third-year student looking for a roommate who is clean, respectful, and studious. I enjoy quiet evenings and occasional social gatherings.',
                          style: TextStyle(
                            fontSize: 16,
                            color: theme.primaryColor.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // My Preferences Section
                AnimatedFadeSlide(
                  show: _showContent,
                  delay: const Duration(milliseconds: 400),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Preferences',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GlassContainer(
                        padding: const EdgeInsets.all(20),
                        borderRadius: BorderRadius.circular(20),
                        child: Column(
                          children: [
                            _buildPreferenceItem(Icons.location_on, 'Location', 'Near campus'),
                            _buildPreferenceItem(Icons.attach_money, 'Budget', '\$300-\$500/month'),
                            _buildPreferenceItem(Icons.nightlife, 'Lifestyle', 'Quiet, occasional social'),
                            _buildPreferenceItem(Icons.book, 'Study Habits', 'Regular evening study sessions', showDivider: false),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Update Preferences Button
                AnimatedFadeSlide(
                  show: _showContent,
                  delay: const Duration(milliseconds: 500),
                  child: AnimatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PreferencesSetupScreen(),
                        ),
                      );
                    },
                    gradientColors: [
                      theme.primaryColor,
                      theme.primaryColor.withOpacity(0.8),
                    ],
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.tune, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Update Preferences',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreferenceItem(IconData icon, String title, String value, {bool showDivider = true}) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: theme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: theme.primaryColor.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: theme.primaryColor,
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: theme.primaryColor.withOpacity(0.5),
                size: 16,
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            color: theme.primaryColor.withOpacity(0.1),
            thickness: 1,
          ),
      ],
    );
  }
  
  void _showLogoutDialog() {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Logout',
          style: TextStyle(
            color: theme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Are you sure you want to logout?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Cancel',
              style: TextStyle(
                color: theme.primaryColor,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Perform logout
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/welcome');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}