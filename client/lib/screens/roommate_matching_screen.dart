import 'package:flutter/material.dart';
import '../services/housing_data_service.dart';
import 'dart:developer' as developer;

class RoommateMatchingScreen extends StatefulWidget {
  const RoommateMatchingScreen({Key? key}) : super(key: key);

  @override
  State<RoommateMatchingScreen> createState() => _RoommateMatchingScreenState();
}

class _RoommateMatchingScreenState extends State<RoommateMatchingScreen> {
  final HousingDataService _housingDataService = HousingDataService();
  
  List<Map<String, dynamic>> _roommateMatches = [];
  bool _isLoading = true;
  
  // Filter preferences
  String? _selectedGender;
  double _minBudget = 100;
  double _maxBudget = 500;
  String? _selectedOccupation;
  
  @override
  void initState() {
    super.initState();
    _loadRoommateMatches();
  }
  
  Future<void> _loadRoommateMatches() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Build filter preferences
      final Map<String, dynamic> preferences = {};
      
      if (_selectedGender != null) {
        preferences['gender'] = _selectedGender;
      }
      
      preferences['minBudget'] = _minBudget.toInt();
      preferences['maxBudget'] = _maxBudget.toInt();
      
      if (_selectedOccupation != null) {
        preferences['occupation'] = _selectedOccupation;
      }
      
      final result = await _housingDataService.getRoommateMatches(preferences);
      
      if (result['success'] == true && result['data'] != null) {
        setState(() {
          _roommateMatches = List<Map<String, dynamic>>.from(result['data']);
          _isLoading = false;
        });
      } else {
        setState(() {
          _roommateMatches = [];
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load roommate matches')),
        );
      }
    } catch (e) {
      developer.log('Error loading roommate matches: $e', name: 'ROOMMATE_MATCHING');
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred while loading roommate matches')),
      );
    }
  }
  
  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (context, scrollController) => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                ),
                
                // Title
                const Text(
                  'Filter Roommate Matches',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Gender filter
                const Text(
                  'Gender',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildFilterChip(
                      label: 'Any',
                      selected: _selectedGender == null,
                      onSelected: (selected) {
                        setModalState(() {
                          _selectedGender = null;
                        });
                      },
                    ),
                    _buildFilterChip(
                      label: 'Male',
                      selected: _selectedGender == 'Male',
                      onSelected: (selected) {
                        setModalState(() {
                          _selectedGender = selected ? 'Male' : null;
                        });
                      },
                    ),
                    _buildFilterChip(
                      label: 'Female',
                      selected: _selectedGender == 'Female',
                      onSelected: (selected) {
                        setModalState(() {
                          _selectedGender = selected ? 'Female' : null;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Budget range filter
                const Text(
                  'Budget Range (USD)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('\$${_minBudget.toInt()}'),
                    Text('\$${_maxBudget.toInt()}'),
                  ],
                ),
                RangeSlider(
                  values: RangeValues(_minBudget, _maxBudget),
                  min: 100,
                  max: 500,
                  divisions: 40,
                  labels: RangeLabels(
                    '\$${_minBudget.toInt()}',
                    '\$${_maxBudget.toInt()}',
                  ),
                  onChanged: (values) {
                    setModalState(() {
                      _minBudget = values.start;
                      _maxBudget = values.end;
                    });
                  },
                ),
                const SizedBox(height: 24),
                
                // Occupation filter
                const Text(
                  'Occupation',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildFilterChip(
                      label: 'Any',
                      selected: _selectedOccupation == null,
                      onSelected: (selected) {
                        setModalState(() {
                          _selectedOccupation = null;
                        });
                      },
                    ),
                    _buildFilterChip(
                      label: 'Student',
                      selected: _selectedOccupation == 'Student',
                      onSelected: (selected) {
                        setModalState(() {
                          _selectedOccupation = selected ? 'Student' : null;
                        });
                      },
                    ),
                    _buildFilterChip(
                      label: 'Professional',
                      selected: _selectedOccupation == 'Professional',
                      onSelected: (selected) {
                        setModalState(() {
                          _selectedOccupation = selected ? 'Professional' : null;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                // Apply button
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _loadRoommateMatches();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Apply Filters'),
                ),
                const SizedBox(height: 8),
                
                // Reset button
                OutlinedButton(
                  onPressed: () {
                    setModalState(() {
                      _selectedGender = null;
                      _minBudget = 100;
                      _maxBudget = 500;
                      _selectedOccupation = null;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Reset Filters'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required Function(bool) onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      backgroundColor: Colors.grey.withOpacity(0.1),
      selectedColor: Colors.blue.withOpacity(0.2),
      checkmarkColor: Colors.blue,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: selected ? Colors.blue : Colors.transparent,
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Roommate Matching'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _roommateMatches.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.people_alt_outlined,
                        size: 80,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No roommate matches found',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Try adjusting your filters',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _showFilterDialog,
                        child: const Text('Adjust Filters'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _roommateMatches.length,
                  itemBuilder: (context, index) {
                    final match = _roommateMatches[index];
                    return _buildRoommateCard(match);
                  },
                ),
    );
  }
  
  Widget _buildRoommateCard(Map<String, dynamic> match) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _showRoommateDetails(match),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar placeholder
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blue.withOpacity(0.2),
                    child: Text(
                      match['name'].toString().substring(0, 1),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // User info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          match['name'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${match['age']}, ${match['gender']}',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          match['occupation'],
                          style: TextStyle(
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Compatibility badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getCompatibilityColor(match['compatibility']).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.favorite,
                          size: 16,
                          color: _getCompatibilityColor(match['compatibility']),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${match['compatibility']}%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _getCompatibilityColor(match['compatibility']),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Budget
              Row(
                children: [
                  const Icon(Icons.account_balance_wallet, size: 16, color: Colors.blue),
                  const SizedBox(width: 4),
                  Text(
                    'Budget: \$${match['budget']}/${match['currency']} per month',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Move-in date
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.blue),
                  const SizedBox(width: 4),
                  Text(
                    'Move-in date: ${match['moveInDate']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Interests
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (match['interests'] as List<dynamic>).map((interest) => 
                  Chip(
                    label: Text(interest),
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    side: BorderSide.none,
                    padding: EdgeInsets.zero,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                  )
                ).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Color _getCompatibilityColor(int compatibility) {
    if (compatibility >= 85) {
      return Colors.green;
    } else if (compatibility >= 70) {
      return Colors.blue;
    } else if (compatibility >= 50) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
  
  void _showRoommateDetails(Map<String, dynamic> match) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 5,
              ),
            ],
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
              
              // Profile header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar placeholder
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.blue.withOpacity(0.2),
                    child: Text(
                      match['name'].toString().substring(0, 1),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // User info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          match['name'],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${match['age']}, ${match['gender']}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          match['occupation'],
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Compatibility badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getCompatibilityColor(match['compatibility']).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.favorite,
                                size: 16,
                                color: _getCompatibilityColor(match['compatibility']),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${match['compatibility']}% Compatible',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _getCompatibilityColor(match['compatibility']),
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
              const SizedBox(height: 24),
              
              // Details section
              const Text(
                'Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Budget
              _buildDetailRow(
                icon: Icons.account_balance_wallet,
                title: 'Budget',
                value: '\$${match['budget']}/${match['currency']} per month',
              ),
              const Divider(),
              
              // Move-in date
              _buildDetailRow(
                icon: Icons.calendar_today,
                title: 'Move-in Date',
                value: match['moveInDate'],
              ),
              const Divider(),
              
              // Education/Workplace
              if (match.containsKey('university') && match['university'] != null)
                _buildDetailRow(
                  icon: Icons.school,
                  title: 'University',
                  value: match['university'],
                ),
              if (match.containsKey('workplace') && match['workplace'] != null)
                _buildDetailRow(
                  icon: Icons.work,
                  title: 'Workplace',
                  value: match['workplace'],
                ),
              const Divider(),
              
              // Interests
              const SizedBox(height: 16),
              const Text(
                'Interests',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (match['interests'] as List<dynamic>).map((interest) => 
                  Chip(
                    label: Text(interest),
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    side: BorderSide.none,
                  )
                ).toList(),
              ),
              const SizedBox(height: 32),
              
              // Contact button
              ElevatedButton(
                onPressed: () {
                  // Implement contact functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Contact feature coming soon!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Contact'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 