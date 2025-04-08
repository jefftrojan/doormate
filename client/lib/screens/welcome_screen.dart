import 'package:flutter/material.dart';
import 'package:mobile_client_flutter/widgets/glass_container.dart';
import 'package:mobile_client_flutter/widgets/animated_fade_slide.dart';
import 'package:mobile_client_flutter/widgets/animated_button.dart';
import 'package:mobile_client_flutter/widgets/gradient_background.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _showContent = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    
    return Scaffold(
      body: AnimatedGradientBackground(
        colorSets: const [
          [
            Color(0xFFF8F0E5),
            Color(0xFFEADBC8),
            Color(0xFFDAC0A3),
            Color(0xFFBCAA94),
          ],
          [
            Color(0xFFEADBC8),
            Color(0xFFDAC0A3),
            Color(0xFFBCAA94),
            Color(0xFFF8F0E5),
          ],
        ],
        duration: const Duration(seconds: 20),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                    minWidth: constraints.maxWidth,
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Spacer(flex: 1),
                          
                          // Logo with animation
                          AnimatedFadeSlide(
                            show: _showContent,
                            beginOffset: const Offset(0, 0.3),
                            duration: const Duration(milliseconds: 800),
                            child: Hero(
                              tag: 'logo',
                              child: Image.asset(
                                'assets/images/doormate-logo.png',
                                height: 120,
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 48),
                          
                          // Welcome text
                          AnimatedFadeSlide(
                            show: _showContent,
                            beginOffset: const Offset(0, 0.3),
                            delay: const Duration(milliseconds: 200),
                            child: Text(
                              'Welcome to DoorMate',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.primaryColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Tagline
                          AnimatedFadeSlide(
                            show: _showContent,
                            beginOffset: const Offset(0, 0.3),
                            delay: const Duration(milliseconds: 300),
                            child: Text(
                              'Find your perfect roommate match',
                              style: TextStyle(
                                fontSize: 16,
                                color: theme.primaryColor.withOpacity(0.8),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          
                          const SizedBox(height: 48),
                          
                          // School Email Button with animation
                          AnimatedFadeSlide(
                            show: _showContent,
                            beginOffset: const Offset(0, 0.3),
                            delay: const Duration(milliseconds: 400),
                            child: GradientGlassContainer(
                              padding: const EdgeInsets.all(24),
                              borderRadius: BorderRadius.circular(16),
                              gradientColors: [
                                Colors.white.withOpacity(0.2),
                                Colors.white.withOpacity(0.1),
                              ],
                              child: Column(
                                children: [
                                  AnimatedButton(
                                    width: double.infinity,
                                    onPressed: () {
                                      Navigator.pushNamed(context, '/email-verification');
                                    },
                                    gradientColors: [
                                      theme.primaryColor,
                                      theme.primaryColor.withOpacity(0.8),
                                    ],
                                    child: const Text(
                                      'Sign Up with School Email',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Google Sign In Button with animation
                                  AnimatedButton(
                                    width: double.infinity,
                                    isGlass: true,
                                    onPressed: () {
                                      // Implement Google Sign In
                                    },
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          'assets/images/google-logo.png',
                                          height: 24,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Continue with Google',
                                          style: TextStyle(
                                            color: theme.primaryColor,
                                            fontSize: 16,
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
                          
                          const SizedBox(height: 24),
                          
                          // Login Link with animation
                          AnimatedFadeSlide(
                            show: _showContent,
                            beginOffset: const Offset(0, 0.3),
                            delay: const Duration(milliseconds: 600),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Already have an account? ',
                                  style: TextStyle(color: theme.primaryColor.withOpacity(0.8)),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(context, '/login');
                                  },
                                  child: Text(
                                    'Log in',
                                    style: TextStyle(
                                      color: theme.primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const Spacer(flex: 1),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}