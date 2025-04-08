import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_client_flutter/providers/preferences_provider.dart';
import 'package:mobile_client_flutter/widgets/gradient_background.dart';
import 'package:mobile_client_flutter/widgets/gradient_glass_container.dart';
import 'package:mobile_client_flutter/widgets/animated_fade_slide.dart';
import 'package:mobile_client_flutter/widgets/animated_button.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _animationController;
  int _currentPage = 0;
  bool _showContent = false;
  bool _isLoading = false;
  
  // Lifestyle preferences
  int _cleanlinessLevel = 3;
  double _noiseTolerance = 5.0;
  String _studyHabits = 'Moderate';
  String _socialLevel = 'Balanced';
  String _wakeUpTime = '7:00 AM';
  String _sleepTime = '11:00 PM';
  
  // Location preferences
  String _preferredArea = 'On Campus';
  double _maxDistance = 5.0;
  double _budget = 500.0;
  bool _hasTransport = false;

  final List<String> _studyHabitOptions = ['Casual', 'Moderate', 'Intense'];
  final List<String> _socialLevelOptions = ['Very Private', 'Balanced', 'Very Social'];
  final List<String> _wakeUpTimeOptions = ['5:00 AM', '6:00 AM', '7:00 AM', '8:00 AM', '9:00 AM', '10:00 AM', 'Later'];
  final List<String> _sleepTimeOptions = ['9:00 PM', '10:00 PM', '11:00 PM', '12:00 AM', '1:00 AM', '2:00 AM', 'Later'];
  final List<String> _areaOptions = ['On Campus', 'Near Campus', 'City Center', 'Suburbs', 'Any'];

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
    
    // Load existing preferences if any
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PreferencesProvider>(context, listen: false).loadPreferences();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _savePreferences();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _savePreferences() async {
    final provider = Provider.of<PreferencesProvider>(context, listen: false);
    
    // Show loading indicator
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Convert noise tolerance to 0-10 scale for the UI
      // (it will be converted to 0-100 in the service)
      await provider.saveAllPreferences(
        // Lifestyle preferences
        cleanlinessLevel: _cleanlinessLevel,
        noiseTolerance: _noiseTolerance,
        studyHabits: _studyHabits,
        socialLevel: _socialLevel,
        wakeUpTime: _wakeUpTime,
        sleepTime: _sleepTime,
        
        // Location preferences
        preferredArea: _preferredArea,
        maxDistance: _maxDistance,
        budget: _budget,
        hasTransport: _hasTransport,
      );
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preferences saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Navigate to matches screen after successful save
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/matches');
      }
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving preferences: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // Hide loading indicator
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<PreferencesProvider>(context);
    
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
                    if (_currentPage > 0)
                      AnimatedFadeSlide(
                        show: _showContent,
                        child: IconButton(
                          onPressed: _previousPage,
                          icon: Icon(
                            Icons.arrow_back_ios,
                            color: theme.primaryColor,
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: 48),
                    AnimatedFadeSlide(
                      show: _showContent,
                      delay: const Duration(milliseconds: 100),
                      child: Text(
                        'Your Preferences',
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  children: [
                    // Lifestyle Preferences Page
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: AnimatedFadeSlide(
                        show: _showContent,
                        delay: const Duration(milliseconds: 200),
                        child: GradientGlassContainer(
                          padding: const EdgeInsets.all(20),
                          borderRadius: BorderRadius.circular(24),
                          gradientColors: [
                            Colors.white.withOpacity(0.2),
                            Colors.white.withOpacity(0.1),
                          ],
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Lifestyle Preferences',
                                style: theme.textTheme.titleLarge,
                              ),
                              const SizedBox(height: 24),
                              
                              // Cleanliness Level
                              Text(
                                'Cleanliness Level',
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Relaxed'),
                                  Expanded(
                                    child: Slider(
                                      value: _cleanlinessLevel.toDouble(),
                                      min: 1,
                                      max: 5,
                                      divisions: 4,
                                      onChanged: (value) {
                                        setState(() {
                                          _cleanlinessLevel = value.toInt();
                                        });
                                      },
                                    ),
                                  ),
                                  const Text('Very Clean'),
                                ],
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Noise Tolerance
                              Text(
                                'Noise Tolerance',
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Quiet'),
                                  Expanded(
                                    child: Slider(
                                      value: _noiseTolerance,
                                      min: 1,
                                      max: 10,
                                      divisions: 9,
                                      onChanged: (value) {
                                        setState(() {
                                          _noiseTolerance = value;
                                        });
                                      },
                                    ),
                                  ),
                                  const Text('Loud'),
                                ],
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Study Habits
                              Text(
                                'Study Habits',
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: _studyHabitOptions.map((option) {
                                  return ChoiceChip(
                                    label: Text(option),
                                    selected: _studyHabits == option,
                                    onSelected: (selected) {
                                      if (selected) {
                                        setState(() {
                                          _studyHabits = option;
                                        });
                                      }
                                    },
                                  );
                                }).toList(),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Social Level
                              Text(
                                'Social Level',
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: _socialLevelOptions.map((option) {
                                  return ChoiceChip(
                                    label: Text(option),
                                    selected: _socialLevel == option,
                                    onSelected: (selected) {
                                      if (selected) {
                                        setState(() {
                                          _socialLevel = option;
                                        });
                                      }
                                    },
                                  );
                                }).toList(),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Wake Up Time
                              Text(
                                'Wake Up Time',
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: _wakeUpTimeOptions.map((option) {
                                  return ChoiceChip(
                                    label: Text(option),
                                    selected: _wakeUpTime == option,
                                    onSelected: (selected) {
                                      if (selected) {
                                        setState(() {
                                          _wakeUpTime = option;
                                        });
                                      }
                                    },
                                  );
                                }).toList(),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Sleep Time
                              Text(
                                'Sleep Time',
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: _sleepTimeOptions.map((option) {
                                  return ChoiceChip(
                                    label: Text(option),
                                    selected: _sleepTime == option,
                                    onSelected: (selected) {
                                      if (selected) {
                                        setState(() {
                                          _sleepTime = option;
                                        });
                                      }
                                    },
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    // Location Preferences Page
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: AnimatedFadeSlide(
                        show: _showContent,
                        delay: const Duration(milliseconds: 200),
                        child: GradientGlassContainer(
                          padding: const EdgeInsets.all(20),
                          borderRadius: BorderRadius.circular(24),
                          gradientColors: [
                            Colors.white.withOpacity(0.2),
                            Colors.white.withOpacity(0.1),
                          ],
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Location Preferences',
                                style: theme.textTheme.titleLarge,
                              ),
                              const SizedBox(height: 24),
                              
                              // Preferred Area
                              Text(
                                'Preferred Area',
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: _areaOptions.map((option) {
                                  return ChoiceChip(
                                    label: Text(option),
                                    selected: _preferredArea == option,
                                    onSelected: (selected) {
                                      if (selected) {
                                        setState(() {
                                          _preferredArea = option;
                                        });
                                      }
                                    },
                                  );
                                }).toList(),
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Max Distance
                              Text(
                                'Maximum Distance from Campus (km)',
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('1 km'),
                                  Expanded(
                                    child: Slider(
                                      value: _maxDistance,
                                      min: 1,
                                      max: 20,
                                      divisions: 19,
                                      onChanged: (value) {
                                        setState(() {
                                          _maxDistance = value;
                                        });
                                      },
                                    ),
                                  ),
                                  const Text('20 km'),
                                ],
                              ),
                              Text(
                                '${_maxDistance.toStringAsFixed(1)} km',
                                style: theme.textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Budget
                              Text(
                                'Monthly Budget (USD)',
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('\$200'),
                                  Expanded(
                                    child: Slider(
                                      value: _budget,
                                      min: 200,
                                      max: 1000,
                                      divisions: 16,
                                      onChanged: (value) {
                                        setState(() {
                                          _budget = value;
                                        });
                                      },
                                    ),
                                  ),
                                  const Text('\$1000'),
                                ],
                              ),
                              Text(
                                '\$${_budget.toStringAsFixed(0)}',
                                style: theme.textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Has Transport
                              SwitchListTile(
                                title: Text(
                                  'I have my own transportation',
                                  style: theme.textTheme.titleMedium,
                                ),
                                value: _hasTransport,
                                onChanged: (value) {
                                  setState(() {
                                    _hasTransport = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Page indicator
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(2, (index) {
                    return Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPage == index
                            ? theme.primaryColor
                            : theme.primaryColor.withOpacity(0.3),
                      ),
                    );
                  }),
                ),
              ),
              
              // Next/Save button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: AnimatedFadeSlide(
                  show: _showContent,
                  delay: const Duration(milliseconds: 300),
                  child: AnimatedButton(
                    onPressed: provider.isLoading ? null : _nextPage,
                    isLoading: provider.isLoading,
                    gradientColors: [
                      theme.primaryColor,
                      theme.primaryColor.withOpacity(0.8),
                    ],
                    child: Text(
                      _currentPage < 1 ? 'Next' : 'Save & Find Matches',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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