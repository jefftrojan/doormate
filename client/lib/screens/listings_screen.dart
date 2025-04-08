import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_client_flutter/models/listing.dart';
import 'package:mobile_client_flutter/providers/listing_provider.dart';
import 'package:mobile_client_flutter/widgets/glass_container.dart';
import 'package:mobile_client_flutter/widgets/gradient_background.dart';
import 'package:mobile_client_flutter/widgets/animated_fade_slide.dart';
import 'package:intl/intl.dart';

class ListingsScreen extends StatefulWidget {
  const ListingsScreen({super.key});

  @override
  State<ListingsScreen> createState() => _ListingsScreenState();
}

class _ListingsScreenState extends State<ListingsScreen> with SingleTickerProviderStateMixin {
  bool _showContent = false;
  late AnimationController _animationController;
  String? _selectedFilter;
  RangeValues _priceRange = const RangeValues(0, 2000);
  final List<String> _filters = ['All', 'Saved', 'My Listings'];
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    // Set default filter
    _selectedFilter = _filters[0];
    
    // Fetch listings when screen loads
    _fetchListings();
    
    // Start animation after a short delay
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _animationController.forward();
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
  
  Future<void> _fetchListings() async {
    final listingProvider = Provider.of<ListingProvider>(context, listen: false);
    
    try {
      // Clear any previous errors
      listingProvider.clearError();
      
      // Fetch listings based on selected filter
      if (_selectedFilter == 'Saved') {
        await listingProvider.fetchSavedListings();
      } else if (_selectedFilter == 'My Listings') {
        await listingProvider.fetchUserListings();
      } else {
        // Fetch all listings with price filter
        await listingProvider.fetchListings(
          minPrice: _priceRange.start,
          maxPrice: _priceRange.end,
        );
      }
    } catch (e) {
      // Error handling is managed by the provider
      print('Error fetching listings: $e');
    }
  }
  
  void _onFilterChanged(String? filter) {
    if (filter != null && filter != _selectedFilter) {
      setState(() {
        _selectedFilter = filter;
      });
      _fetchListings();
    }
  }
  
  void _onPriceRangeChanged(RangeValues values) {
    setState(() {
      _priceRange = values;
    });
    // Only apply price filter for All listings
    if (_selectedFilter == 'All') {
      _fetchListings();
    }
  }
  
  void _viewListingDetails(Listing listing) {
    final listingProvider = Provider.of<ListingProvider>(context, listen: false);
    listingProvider.fetchListingById(listing.id);
    
    // Navigate to listing details screen
    Navigator.pushNamed(
      context, 
      '/listing-details',
      arguments: listing.id,
    );
  }
  
  void _toggleSaveListing(Listing listing) async {
    final listingProvider = Provider.of<ListingProvider>(context, listen: false);
    
    try {
      if (listing.isSaved) {
        await listingProvider.unsaveListing(listing.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Listing removed from saved'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        await listingProvider.saveListing(listing.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Listing saved'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      
      // Refresh listings
      _fetchListings();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final listingProvider = Provider.of<ListingProvider>(context);
    
    // Determine which listings to display based on filter
    List<Listing> displayedListings = [];
    if (_selectedFilter == 'Saved') {
      displayedListings = listingProvider.savedListings;
    } else if (_selectedFilter == 'My Listings') {
      displayedListings = listingProvider.userListings;
    } else {
      displayedListings = listingProvider.listings;
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/create-listing');
            },
          ),
        ],
      ),
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Filters
              AnimatedFadeSlide(
                controller: _animationController,
                delay: const Duration(milliseconds: 100),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Filter chips
                      SizedBox(
                        height: 50,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _filters.length,
                          itemBuilder: (context, index) {
                            final filter = _filters[index];
                            final isSelected = filter == _selectedFilter;
                            
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: FilterChip(
                                label: Text(filter),
                                selected: isSelected,
                                onSelected: (_) => _onFilterChanged(filter),
                                backgroundColor: Colors.white,
                                selectedColor: theme.primaryColor.withOpacity(0.2),
                                checkmarkColor: theme.primaryColor,
                              ),
                            );
                          },
                        ),
                      ),
                      
                      // Price range slider (only show for All listings)
                      if (_selectedFilter == 'All') ...[
                        const SizedBox(height: 16),
                        Text(
                          'Price Range: \$${_priceRange.start.toInt()} - \$${_priceRange.end.toInt()}',
                          style: TextStyle(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        RangeSlider(
                          values: _priceRange,
                          min: 0,
                          max: 2000,
                          divisions: 20,
                          labels: RangeLabels(
                            '\$${_priceRange.start.toInt()}',
                            '\$${_priceRange.end.toInt()}',
                          ),
                          onChanged: _onPriceRangeChanged,
                          activeColor: theme.primaryColor,
                          inactiveColor: theme.primaryColor.withOpacity(0.2),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              // Listings
              Expanded(
                child: listingProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : listingProvider.error != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: theme.primaryColor,
                                  size: 48,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Something went wrong',
                                  style: TextStyle(
                                    color: theme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  listingProvider.error ?? 'Failed to load listings',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: theme.primaryColor.withOpacity(0.7),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _fetchListings,
                                  child: const Text('Try Again'),
                                ),
                              ],
                            ),
                          )
                        : displayedListings.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.search_off,
                                      color: theme.primaryColor,
                                      size: 48,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No listings found',
                                      style: TextStyle(
                                        color: theme.primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _selectedFilter == 'My Listings'
                                          ? 'You haven\'t created any listings yet'
                                          : _selectedFilter == 'Saved'
                                              ? 'You haven\'t saved any listings yet'
                                              : 'No listings match your criteria',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: theme.primaryColor.withOpacity(0.7),
                                      ),
                                    ),
                                    if (_selectedFilter == 'My Listings') ...[
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pushNamed(context, '/create-listing');
                                        },
                                        child: const Text('Create Listing'),
                                      ),
                                    ],
                                  ],
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: _fetchListings,
                                color: theme.primaryColor,
                                child: ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: displayedListings.length,
                                  itemBuilder: (context, index) {
                                    final listing = displayedListings[index];
                                    return AnimatedFadeSlide(
                                      controller: _animationController,
                                      delay: Duration(milliseconds: 100 + (index * 50)),
                                      child: Padding(
                                        padding: const EdgeInsets.only(bottom: 16),
                                        child: _buildListingCard(listing),
                                      ),
                                    );
                                  },
                                ),
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildListingCard(Listing listing) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: () => _viewListingDetails(listing),
      child: GlassContainer(
        borderRadius: 16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: listing.images.isNotEmpty
                      ? Image.network(
                          listing.images.first,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 180,
                              width: double.infinity,
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.image_not_supported,
                                size: 50,
                                color: Colors.grey,
                              ),
                            );
                          },
                        )
                      : Container(
                          height: 180,
                          width: double.infinity,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                ),
                // Save button
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _toggleSaveListing(listing),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        listing.isSaved ? Icons.favorite : Icons.favorite_border,
                        color: listing.isSaved ? Colors.red : Colors.grey,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                // Price tag
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Text(
                      listing.formattedPrice,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.title,
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: theme.primaryColor.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          listing.location,
                          style: TextStyle(
                            color: theme.primaryColor.withOpacity(0.7),
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildFeatureChip(
                        listing.bedrooms != null ? '${listing.bedrooms} bed' : 'N/A bed',
                        Icons.bed,
                      ),
                      const SizedBox(width: 8),
                      _buildFeatureChip(
                        listing.bathrooms != null ? '${listing.bathrooms} bath' : 'N/A bath',
                        Icons.bathtub,
                      ),
                      const SizedBox(width: 8),
                      _buildFeatureChip(
                        'Available ${DateFormat('MMM d').format(listing.availableFrom)}',
                        Icons.calendar_today,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFeatureChip(String label, IconData icon) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: theme.primaryColor,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: theme.primaryColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
} 