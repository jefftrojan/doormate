import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_client_flutter/models/listing.dart';
import 'package:mobile_client_flutter/providers/listing_provider.dart';
import 'package:mobile_client_flutter/widgets/glass_container.dart';
import 'package:mobile_client_flutter/widgets/gradient_background.dart';
import 'package:mobile_client_flutter/widgets/animated_fade_slide.dart';
import 'package:intl/intl.dart';

class ListingDetailsScreen extends StatefulWidget {
  final String listingId;
  
  const ListingDetailsScreen({
    super.key,
    required this.listingId,
  });

  @override
  State<ListingDetailsScreen> createState() => _ListingDetailsScreenState();
}

class _ListingDetailsScreenState extends State<ListingDetailsScreen> with SingleTickerProviderStateMixin {
  bool _showContent = false;
  late AnimationController _animationController;
  int _currentImageIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    // Fetch listing details
    _fetchListingDetails();
    
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
  
  Future<void> _fetchListingDetails() async {
    final listingProvider = Provider.of<ListingProvider>(context, listen: false);
    
    try {
      await listingProvider.fetchListingById(widget.listingId);
    } catch (e) {
      // Error handling is managed by the provider
      print('Error fetching listing details: $e');
    }
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
      
      // Refresh listing details
      _fetchListingDetails();
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
  
  void _contactOwner(Listing listing) {
    // TODO: Implement contact owner functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Contacting owner of ${listing.title}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final listingProvider = Provider.of<ListingProvider>(context);
    final listing = listingProvider.currentListing;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          if (listing != null)
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  listing.isSaved ? Icons.favorite : Icons.favorite_border,
                  color: listing.isSaved ? Colors.red : Colors.grey,
                ),
                onPressed: () => _toggleSaveListing(listing),
              ),
            ),
        ],
      ),
      body: listingProvider.isLoading
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
                        listingProvider.error ?? 'Failed to load listing details',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: theme.primaryColor.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchListingDetails,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                )
              : listing == null
                  ? const Center(child: Text('Listing not found'))
                  : GradientBackground(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image gallery
                            SizedBox(
                              height: 300,
                              child: Stack(
                                children: [
                                  // Images
                                  PageView.builder(
                                    itemCount: listing.images.isEmpty ? 1 : listing.images.length,
                                    onPageChanged: (index) {
                                      setState(() {
                                        _currentImageIndex = index;
                                      });
                                    },
                                    itemBuilder: (context, index) {
                                      return listing.images.isEmpty
                                          ? Container(
                                              color: Colors.grey[300],
                                              child: const Center(
                                                child: Icon(
                                                  Icons.image_not_supported,
                                                  size: 64,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            )
                                          : Image.network(
                                              listing.images[index],
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Container(
                                                  color: Colors.grey[300],
                                                  child: const Center(
                                                    child: Icon(
                                                      Icons.image_not_supported,
                                                      size: 64,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                    },
                                  ),
                                  
                                  // Image indicators
                                  if (listing.images.length > 1)
                                    Positioned(
                                      bottom: 16,
                                      left: 0,
                                      right: 0,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: List.generate(
                                          listing.images.length,
                                          (index) => Container(
                                            width: 8,
                                            height: 8,
                                            margin: const EdgeInsets.symmetric(horizontal: 4),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: _currentImageIndex == index
                                                  ? theme.primaryColor
                                                  : Colors.white.withOpacity(0.5),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            
                            // Listing details
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Title and price
                                  AnimatedFadeSlide(
                                    controller: _animationController,
                                    delay: const Duration(milliseconds: 100),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            listing.title,
                                            style: TextStyle(
                                              color: theme.primaryColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 24,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Text(
                                          listing.formattedPrice,
                                          style: TextStyle(
                                            color: theme.primaryColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 8),
                                  
                                  // Location
                                  AnimatedFadeSlide(
                                    controller: _animationController,
                                    delay: const Duration(milliseconds: 150),
                                    child: Row(
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
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 16),
                                  
                                  // Features
                                  AnimatedFadeSlide(
                                    controller: _animationController,
                                    delay: const Duration(milliseconds: 200),
                                    child: GlassContainer(
                                      borderRadius: 16,
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          _buildFeature(
                                            Icons.bed,
                                            listing.bedrooms != null
                                                ? '${listing.bedrooms} ${listing.bedrooms == 1 ? 'Bedroom' : 'Bedrooms'}'
                                                : 'N/A Bedrooms',
                                          ),
                                          _buildFeature(
                                            Icons.bathtub,
                                            listing.bathrooms != null
                                                ? '${listing.bathrooms} ${listing.bathrooms == 1 ? 'Bathroom' : 'Bathrooms'}'
                                                : 'N/A Bathrooms',
                                          ),
                                          _buildFeature(
                                            Icons.people,
                                            listing.roommates != null
                                                ? '${listing.roommates} ${listing.roommates == 1 ? 'Roommate' : 'Roommates'}'
                                                : 'No Roommates',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 24),
                                  
                                  // Description
                                  AnimatedFadeSlide(
                                    controller: _animationController,
                                    delay: const Duration(milliseconds: 250),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Description',
                                          style: TextStyle(
                                            color: theme.primaryColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          listing.description,
                                          style: TextStyle(
                                            color: theme.primaryColor.withOpacity(0.7),
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 24),
                                  
                                  // Availability
                                  AnimatedFadeSlide(
                                    controller: _animationController,
                                    delay: const Duration(milliseconds: 300),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Availability',
                                          style: TextStyle(
                                            color: theme.primaryColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        GlassContainer(
                                          borderRadius: 16,
                                          padding: const EdgeInsets.all(16),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Available From',
                                                      style: TextStyle(
                                                        color: theme.primaryColor.withOpacity(0.7),
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      listing.formattedAvailableFrom,
                                                      style: TextStyle(
                                                        color: theme.primaryColor,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if (listing.availableUntil != null)
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        'Available Until',
                                                        style: TextStyle(
                                                          color: theme.primaryColor.withOpacity(0.7),
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        listing.formattedAvailableUntil,
                                                        style: TextStyle(
                                                          color: theme.primaryColor,
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 16,
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
                                  
                                  const SizedBox(height: 24),
                                  
                                  // Amenities
                                  AnimatedFadeSlide(
                                    controller: _animationController,
                                    delay: const Duration(milliseconds: 350),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Amenities',
                                          style: TextStyle(
                                            color: theme.primaryColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: listing.amenities.map((amenity) {
                                            return Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: theme.primaryColor.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                              child: Text(
                                                amenity,
                                                style: TextStyle(
                                                  color: theme.primaryColor,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 24),
                                  
                                  // Contact button
                                  AnimatedFadeSlide(
                                    controller: _animationController,
                                    delay: const Duration(milliseconds: 400),
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () => _contactOwner(listing),
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                        ),
                                        child: const Text(
                                          'Contact Owner',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 40),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
    );
  }
  
  Widget _buildFeature(IconData icon, String text) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Icon(
          icon,
          color: theme.primaryColor,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          text,
          style: TextStyle(
            color: theme.primaryColor,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
} 