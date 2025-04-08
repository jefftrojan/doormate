import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_client_flutter/services/auth_service.dart';
import 'package:mobile_client_flutter/services/api_client.dart';
import 'package:mobile_client_flutter/widgets/glass_container.dart';
import 'package:mobile_client_flutter/widgets/animated_fade_slide.dart';
import 'package:mobile_client_flutter/widgets/animated_button.dart';
import 'package:mobile_client_flutter/widgets/gradient_background.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _authService = AuthService(ApiClient());
  bool _codeSent = false;
  bool _isLoading = false;
  String? _error;
  int _timeLeft = 0;
  Timer? _timer;
  String? _universityName;
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
    _timer?.cancel();
    _emailController.dispose();
    _codeController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timeLeft = 180; // 3 minutes
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  Future<void> _sendVerificationCode() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _authService.verifyEmail(_emailController.text);
      setState(() {
        _codeSent = true;
      });
      _startTimer();
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String get _timerText {
    if (_timeLeft == 0) return '';
    final minutes = (_timeLeft / 60).floor();
    final seconds = _timeLeft % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _verifyCode() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _authService.verifyCode(
        _emailController.text,
        _codeController.text,
      );
      
      // Token is automatically stored by AuthService
      if (response['user'] != null && response['user']['profile_completed'] == true) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/profile-setup');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
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
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Spacer(flex: 1),
                          
                          // Back button
                          Align(
                            alignment: Alignment.topLeft,
                            child: AnimatedFadeSlide(
                              show: _showContent,
                              direction: AnimationDirection.fromLeft,
                              child: IconButton(
                                icon: Icon(Icons.arrow_back, color: theme.primaryColor),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Email icon
                          AnimatedFadeSlide(
                            show: _showContent,
                            child: Center(
                              child: GradientGlassContainer(
                                height: 120,
                                width: 120,
                                borderRadius: BorderRadius.circular(60),
                                gradientColors: [
                                  Colors.white.withOpacity(0.2),
                                  Colors.white.withOpacity(0.1),
                                ],
                                child: Icon(
                                  _codeSent ? Icons.check_circle_outline : Icons.email_outlined,
                                  size: 60,
                                  color: theme.primaryColor,
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 30),
                          
                          // Title
                          AnimatedFadeSlide(
                            show: _showContent,
                            delay: const Duration(milliseconds: 200),
                            child: Text(
                              _codeSent ? 'Verify Your Email' : 'Email Verification',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.primaryColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Description
                          AnimatedFadeSlide(
                            show: _showContent,
                            delay: const Duration(milliseconds: 300),
                            child: Text(
                              _codeSent
                                  ? 'We\'ve sent a verification code to your email. Please enter it below.'
                                  : 'Enter your school email address to verify your student status',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.primaryColor.withOpacity(0.8),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          
                          const SizedBox(height: 30),
                          
                          // Error message
                          if (_error != null)
                            AnimatedFadeSlide(
                              show: _showContent,
                              delay: const Duration(milliseconds: 400),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: GlassContainer(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.red.withOpacity(0.5)),
                                  color: Colors.red.withOpacity(0.05),
                                  child: Text(
                                    _error!,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),
                              ),
                            ),
                          
                          // Form
                          AnimatedFadeSlide(
                            show: _showContent,
                            delay: const Duration(milliseconds: 500),
                            child: GradientGlassContainer(
                              padding: const EdgeInsets.all(24),
                              borderRadius: BorderRadius.circular(24),
                              gradientColors: [
                                Colors.white.withOpacity(0.2),
                                Colors.white.withOpacity(0.1),
                              ],
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // Email field
                                    TextFormField(
                                      controller: _emailController,
                                      enabled: !_codeSent,
                                      decoration: InputDecoration(
                                        labelText: 'School Email',
                                        prefixIcon: Icon(
                                          Icons.email_outlined,
                                          color: theme.primaryColor,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                      ),
                                      keyboardType: TextInputType.emailAddress,
                                      onChanged: (value) {
                                        setState(() {
                                          _universityName = AuthService.getUniversityName(value);
                                        });
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your email';
                                        }
                                        if (!AuthService.isValidUniversityEmail(value)) {
                                          return 'Please enter a valid university email';
                                        }
                                        return null;
                                      },
                                    ),
                                    
                                    // University name
                                    if (_universityName != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8, bottom: 8),
                                        child: GlassContainer(
                                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                          borderRadius: BorderRadius.circular(8),
                                          color: theme.primaryColor.withOpacity(0.05),
                                          child: Text(
                                            _universityName!,
                                            style: TextStyle(
                                              color: theme.primaryColor,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    
                                    // Verification code field
                                    if (_codeSent) ...[
                                      const SizedBox(height: 20),
                                      TextFormField(
                                        controller: _codeController,
                                        decoration: InputDecoration(
                                          labelText: 'Verification Code',
                                          prefixIcon: Icon(
                                            Icons.lock_outline,
                                            color: theme.primaryColor,
                                          ),
                                          suffixText: _timerText,
                                          suffixStyle: TextStyle(
                                            color: theme.primaryColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                        ),
                                        keyboardType: TextInputType.number,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter the verification code';
                                          }
                                          if (value.length != 6) {
                                            return 'Please enter a valid 6-digit code';
                                          }
                                          return null;
                                        },
                                      ),
                                      
                                      // Resend code button
                                      if (_timeLeft == 0)
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: TextButton(
                                            onPressed: _isLoading ? null : _sendVerificationCode,
                                            child: Text(
                                              'Resend Code',
                                              style: TextStyle(
                                                color: theme.primaryColor,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                    
                                    const SizedBox(height: 24),
                                    
                                    // Submit button
                                    AnimatedButton(
                                      onPressed: _isLoading
                                          ? null
                                          : () {
                                              if (_codeSent) {
                                                _verifyCode();
                                              } else {
                                                _sendVerificationCode();
                                              }
                                            },
                                      isLoading: _isLoading,
                                      gradientColors: [
                                        theme.primaryColor,
                                        theme.primaryColor.withOpacity(0.8),
                                      ],
                                      child: Text(
                                        _codeSent ? 'Verify Code' : 'Send Verification Code',
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