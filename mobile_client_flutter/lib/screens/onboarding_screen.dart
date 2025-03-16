import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_client_flutter/widgets/glass_container.dart';
import 'package:mobile_client_flutter/widgets/animated_fade_slide.dart';
import 'package:mobile_client_flutter/widgets/animated_button.dart';
import 'package:mobile_client_flutter/widgets/gradient_background.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _showContent = false;
  late AnimationController _animationController;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      'title': 'Find Your Perfect Roommate',
      'description': 'Join the trusted community of student roommates in Rwanda',
      'icon': Icons.people_outline,
      'color': const Color(0xFF8B5A2B),
    },
    {
      'title': 'Safe and Secure',
      'description': 'Verified university students only',
      'icon': Icons.security_outlined,
      'color': const Color(0xFF8B5A2B),
    },
    {
      'title': 'Smart Matching',
      'description': 'AI-powered roommate matching based on your preferences',
      'icon': Icons.psychology_outlined,
      'color': const Color(0xFF8B5A2B),
    },
  ];

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
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/welcome');
    }
  }

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
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
          child: Stack(
            children: [
              // Skip button
              AnimatedFadeSlide(
                show: _showContent,
                direction: AnimationDirection.fromTop,
                child: Positioned(
                  top: 16,
                  right: 16,
                  child: TextButton(
                    onPressed: _completeOnboarding,
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              
              // Page content
              PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  return OnboardingPage(
                    title: _onboardingData[index]['title'],
                    description: _onboardingData[index]['description'],
                    icon: _onboardingData[index]['icon'],
                    color: _onboardingData[index]['color'],
                    show: _showContent,
                    delay: Duration(milliseconds: 300 + (index * 100)),
                  );
                },
              ),
              
              // Bottom controls
              Positioned(
                bottom: 48,
                left: 0,
                right: 0,
                child: AnimatedFadeSlide(
                  show: _showContent,
                  direction: AnimationDirection.fromBottom,
                  delay: const Duration(milliseconds: 600),
                  child: Column(
                    children: [
                      // Page indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _onboardingData.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentPage == index ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: _currentPage == index
                                  ? theme.primaryColor
                                  : theme.primaryColor.withOpacity(0.3),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Next/Get Started button
                      AnimatedButton(
                        onPressed: _nextPage,
                        gradientColors: [
                          theme.primaryColor,
                          theme.primaryColor.withOpacity(0.8),
                        ],
                        width: 200,
                        child: Text(
                          _currentPage == _onboardingData.length - 1
                              ? 'Get Started'
                              : 'Next',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
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
}

class OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool show;
  final Duration? delay;

  const OnboardingPage({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.show = true,
    this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedFadeSlide(
            show: show,
            delay: delay,
            child: GradientGlassContainer(
              height: 160,
              width: 160,
              borderRadius: BorderRadius.circular(80),
              gradientColors: [
                Colors.white.withOpacity(0.2),
                Colors.white.withOpacity(0.1),
              ],
              child: Icon(
                icon,
                size: 80,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 40),
          AnimatedFadeSlide(
            show: show,
            delay: delay != null 
                ? Duration(milliseconds: delay!.inMilliseconds + 100) 
                : null,
            child: Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          AnimatedFadeSlide(
            show: show,
            delay: delay != null 
                ? Duration(milliseconds: delay!.inMilliseconds + 200) 
                : null,
            child: Text(
              description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: color.withOpacity(0.8),
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}