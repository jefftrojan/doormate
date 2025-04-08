import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_client_flutter/models/roommate_match.dart';
import 'package:mobile_client_flutter/providers/listing_provider.dart';
import 'package:mobile_client_flutter/providers/match_provider.dart';
import 'package:mobile_client_flutter/widgets/glass_container.dart';
import 'package:mobile_client_flutter/widgets/gradient_background.dart';
import 'package:mobile_client_flutter/widgets/animated_fade_slide.dart';

class MatchScreen extends StatefulWidget {
  const MatchScreen({Key? key}) : super(key: key);

  @override
  _MatchScreenState createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showContent = false;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      // When tab changes, load the relevant data if it hasn't been loaded yet
      _loadDataForCurrentTab();
    });
    
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDataForCurrentTab();
      setState(() {
        _showContent = true;
      });
    });
  }
  
  void _loadDataForCurrentTab() {
    final matchProvider = Provider.of<MatchProvider>(context, listen: false);
    
    switch (_tabController.index) {
      case 0: // Potential matches
        if (matchProvider.potentialMatches.isEmpty && !matchProvider.isLoading) {
          matchProvider.fetchPotentialMatches();
        }
        break;
      case 1: // Mutual matches
        if (matchProvider.mutualMatches.isEmpty && !matchProvider.isLoading) {
          matchProvider.fetchMutualMatches();
        }
        break;
      case 2: // All matches
        if (matchProvider.matches.isEmpty && !matchProvider.isLoading) {
          matchProvider.fetchMatches();
        }
        break;
    }
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final matchProvider = Provider.of<MatchProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Roommates'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Potential'),
            Tab(text: 'Mutual'),
            Tab(text: 'All'),
          ],
        ),
      ),
      body: GradientBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _refreshCurrentTab,
            child: TabBarView(
              controller: _tabController,
              children: [
                // Potential Matches Tab
                _buildPotentialMatchesTab(),
                
                // Mutual Matches Tab
                _buildMutualMatchesTab(),
                
                // All Matches Tab
                _buildAllMatchesTab(),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Future<void> _refreshCurrentTab() async {
    final matchProvider = Provider.of<MatchProvider>(context, listen: false);
    
    switch (_tabController.index) {
      case 0:
        await matchProvider.refreshPotentialMatches();
        break;
      case 1:
        await matchProvider.refreshMutualMatches();
        break;
      case 2:
        await matchProvider.refreshMatches();
        break;
    }
  }
  
  Widget _buildPotentialMatchesTab() {
    final matchProvider = Provider.of<MatchProvider>(context);
    
    if (matchProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (matchProvider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading matches',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(matchProvider.error ?? 'Unknown error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => matchProvider.refreshPotentialMatches(),
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }
    
    if (matchProvider.potentialMatches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_outline, size: 64, color: Colors.blue),
            const SizedBox(height: 16),
            Text(
              'No potential matches found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text('Complete your roommate preferences to find matches'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigate to preferences screen
                Navigator.pushNamed(context, '/preferences');
              },
              child: const Text('Set Preferences'),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: matchProvider.potentialMatches.length,
      itemBuilder: (context, index) {
        final match = matchProvider.potentialMatches[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildMatchCard(match, isPotential: true),
        );
      },
    );
  }
  
  Widget _buildMutualMatchesTab() {
    final matchProvider = Provider.of<MatchProvider>(context);
    
    if (matchProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (matchProvider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading mutual matches',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(matchProvider.error ?? 'Unknown error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => matchProvider.refreshMutualMatches(),
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }
    
    if (matchProvider.mutualMatches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.favorite_border, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'No mutual matches yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text('When both you and another user match, they\'ll appear here'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Switch to potential matches tab
                _tabController.animateTo(0);
              },
              child: const Text('See Potential Matches'),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: matchProvider.mutualMatches.length,
      itemBuilder: (context, index) {
        final match = matchProvider.mutualMatches[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildMatchCard(match, isMutual: true),
        );
      },
    );
  }
  
  Widget _buildAllMatchesTab() {
    final matchProvider = Provider.of<MatchProvider>(context);
    
    if (matchProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (matchProvider.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading matches',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(matchProvider.error ?? 'Unknown error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => matchProvider.refreshMatches(),
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }
    
    if (matchProvider.matches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No matches found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text('Start exploring potential matches to find roommates'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Switch to potential matches tab
                _tabController.animateTo(0);
              },
              child: const Text('See Potential Matches'),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: matchProvider.matches.length,
      itemBuilder: (context, index) {
        final match = matchProvider.matches[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildMatchCard(match),
        );
      },
    );
  }
  
  Widget _buildMatchCard(RoommateMatch match, {bool isPotential = false, bool isMutual = false}) {
    final theme = Theme.of(context);
    
    return GlassContainer(
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with image
          Stack(
            children: [
              // Profile image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: match.profileImage != null
                  ? Image.network(
                      match.profileImage!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 180,
                          width: double.infinity,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.person,
                            size: 64,
                            color: Colors.white,
                          ),
                        );
                      },
                    )
                  : Container(
                      height: 180,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.person,
                        size: 64,
                        color: Colors.white,
                      ),
                    ),
              ),
              
              // Match percentage
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: match.getCompatibilityColor(context),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    match.compatibilityPercentage,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              // Mutual match badge
              if (isMutual)
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.favorite, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Mutual Match',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          
          // Match info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        match.name,
                        style: theme.textTheme.titleLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      match.compatibilityDescription,
                      style: TextStyle(
                        color: match.getCompatibilityColor(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Bio
                if (match.bio != null)
                  Text(
                    match.bio!,
                    style: theme.textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 16),
                
                // Compatibility factors
                Text(
                  'Compatibility Factors',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                _buildCompatibilityFactors(match),
                const SizedBox(height: 16),
                
                // Action buttons
                if (isPotential)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _confirmMatch(match),
                        icon: const Icon(Icons.check),
                        label: const Text('Match'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _rejectMatch(match),
                        icon: const Icon(Icons.close),
                        label: const Text('Pass'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  )
                else if (isMutual)
                  ElevatedButton.icon(
                    onPressed: () => _viewProfile(match),
                    icon: const Icon(Icons.message),
                    label: const Text('Message'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCompatibilityFactors(RoommateMatch match) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: match.compatibilityFactors.entries.map((entry) {
        final factor = entry.key;
        final score = entry.value;
        
        // Determine color based on score
        Color color;
        if (score >= 0.8) {
          color = Colors.green;
        } else if (score >= 0.6) {
          color = Colors.teal;
        } else if (score >= 0.4) {
          color = Colors.orange;
        } else {
          color = Colors.red;
        }
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                factor,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '${(score * 100).round()}%',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
  
  Future<void> _confirmMatch(RoommateMatch match) async {
    final matchProvider = Provider.of<MatchProvider>(context, listen: false);
    
    final success = await matchProvider.confirmMatch(match.id);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You matched with ${match.name}!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(matchProvider.error ?? 'Failed to confirm match'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  Future<void> _rejectMatch(RoommateMatch match) async {
    final matchProvider = Provider.of<MatchProvider>(context, listen: false);
    
    final success = await matchProvider.rejectMatch(match.id);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Passed on ${match.name}'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(matchProvider.error ?? 'Failed to reject match'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  void _viewProfile(RoommateMatch match) {
    // Navigate to the user profile or chat screen
    Navigator.pushNamed(
      context,
      '/match/profile',
      arguments: match,
    );
  }
}