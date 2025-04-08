import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import '../models/listing.dart';
import '../providers/listing_provider.dart';
import '../services/location_service.dart';
import '../services/housing_data_service.dart';
import 'dart:developer' as developer;
import 'listing_details_screen.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/services.dart';

class MapViewScreen extends StatefulWidget {
  final String? initialNeighborhood;

  const MapViewScreen({Key? key, this.initialNeighborhood}) : super(key: key);

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  final Completer<GoogleMapController> _controller = Completer();

  static const CameraPosition _kigaliCenter = CameraPosition(
    target: LatLng(-1.9441, 30.0619), // Kigali city center
    zoom: 13,
  );

  Set<Marker> _markers = {};
  List<String> _neighborhoods = [];
  String? _selectedNeighborhood;
  bool _isLoading = false;
  bool _isMapError = false;
  List<Listing> _listings = [];

  @override
  void initState() {
    super.initState();
     _selectedNeighborhood = widget.initialNeighborhood;
    //  WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _loadListings();
    // });
  
  if (kIsWeb) {
    // Initialize separately for web platform to ensure API is loaded
    developer.log('Initializing map for web platform', name: 'MAP_VIEW');
  }
  
  // _selectedNeighborhood = widget.initialNeighborhood;
  _loadNeighborhoods();
  // _loadProperties();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _loadListings();
  });
}

  final HousingDataService _housingDataService = HousingDataService();
  
  
  // Map of neighborhood names to their coordinates
  final Map<String, LatLng> _neighborhoodCoordinates = {
    'Kacyiru': const LatLng(-1.9441, 30.0619),
    'Kimihurura': const LatLng(-1.9532, 30.0811),
    'Nyamirambo': const LatLng(-1.9811, 30.0419),
    'Remera': const LatLng(-1.9532, 30.1119),
    'Kicukiro': const LatLng(-1.9811, 30.0811),
    'Gikondo': const LatLng(-1.9711, 30.0711),
    'Gisozi': const LatLng(-1.9211, 30.0519),
    'Nyarutarama': const LatLng(-1.9341, 30.0719),
    'Kibagabaga': const LatLng(-1.9341, 30.0919),
    'Kiyovu': const LatLng(-1.9541, 30.0519),
  };
  
  
  // Future<void> _loadNeighborhoods() async {
  //   try {
  //     final result = await _housingDataService.getAllNeighborhoods();
  //     if (result['success'] == true && result['data'] != null) {
  //       setState(() {
  //         _neighborhoods = (result['data'] as List<dynamic>).map((n) => n.toString()).toList();
  //       });
  //     }
  //   } catch (e) {
  //     developer.log('Error loading neighborhoods: $e', name: 'MAP_VIEW');
  //   }
  // }
  
  Future<void> _loadNeighborhoods() async {
    setState(() {
      _neighborhoods = [
        'Kigali City',
        'Nyarugenge',
        'Kacyiru',
        'Kimihurura',
        'Gacuriro',
        'Gisozi',
        'Remera',
        'Kibagabaga',
        'Kicukiro',
        'Nyamirambo',
      ];
    });
  }

  Future<void> _loadListings() async {
    setState(() {
      _isLoading = true;
      _markers = {};
    });
    
    try {
      // Use the existing ListingProvider to fetch listings
      final listingProvider = Provider.of<ListingProvider>(context, listen: false);
      
      // Fetch listings based on neighborhood filter
      if (_selectedNeighborhood != null) {
        await listingProvider.fetchListings(location: _selectedNeighborhood);
        // await listingProvider.fetchListings(location: _selectedNeighborhood);
        // await _createMarkersFromListings(listingProvider.listings);
      } else {
        await listingProvider.fetchListings();
      }
      final listings = listingProvider.listings;
    developer.log('Fetched ${listings.length} listings', name: 'MAP_VIEW');
    
    // Always create markers from listings
    await _createMarkersFromListings(listings);
      
      // setState(() {
      //   _listings = listingProvider.listings;
      // });
      
      // Geocode each listing location to get coordinates
      // await _geocodeListingLocations(_listings);
      
    } catch (e) {
      developer.log('Error loading listings: $e', name: 'MAP_VIEW');
    }
      finally {
        setState(() {
        _isLoading = false;
      });
      }
  }

  Future<void> _createMarkersFromListings(List<Listing> listings) async {
  final markers = <Marker>{};
  developer.log('Creating markers for ${listings.length} listings', name: 'MAP_VIEW');
  
  for (var listing in listings) {
    try {
      // Log address for debugging
      developer.log('Processing listing: ${listing.id}, location: ${listing.location}', name: 'MAP_VIEW');
      
      if (listing.location.isEmpty) {
        developer.log('Skipping listing with empty location: ${listing.id}', name: 'MAP_VIEW');
        continue;
      }
      
      // Get coordinates for the listing's location
      final LatLng? coordinates = await LocationService.geocodeAddress(listing.location);
      
      if (coordinates != null) {
        developer.log('Adding marker at lat: ${coordinates.latitude}, lng: ${coordinates.longitude}', name: 'MAP_VIEW');
        markers.add(
          Marker(
            markerId: MarkerId(listing.id),
            position: coordinates,
            infoWindow: InfoWindow(
              title: listing.title,
              snippet: '\$${listing.price} - ${listing.location}',
            ),
            onTap: () => _showListingDetails(listing),
          ),
        );
      } else {
        developer.log('Failed to get coordinates for listing: ${listing.id}', name: 'MAP_VIEW');
      }
    } catch (e) {
      developer.log('Error creating marker for listing ${listing.id}: $e', name: 'MAP_VIEW');
    }
  }
  
  developer.log('Created ${markers.length} markers', name: 'MAP_VIEW');
  setState(() {
    _markers = markers;
  });
  
  // If we have markers, fit the map to show them all
  if (markers.isNotEmpty) {
    _fitMapToMarkers();
  } else {
    developer.log('No markers created, not fitting map', name: 'MAP_VIEW');
  }
}

  Future<void> _geocodeListingLocations(List<Listing> listings) async {
    // Process listings in batches to avoid overwhelming the geocoding service
    for (var listing in listings) {
      if (listing.location.isEmpty) continue;
      
      try {
        final coordinates = await LocationService.geocodeAddress(listing.location);
        if (coordinates != null) {
          setState(() {
            // Add marker for this listing
            _markers.add(
              Marker(
                markerId: MarkerId(listing.id),
                position: coordinates,
                infoWindow: InfoWindow(
                  title: listing.title,
                  snippet: '${listing.formattedPrice} - ${listing.location}',
                  onTap: () => _showListingDetails(listing),
                ),
              ),
            );
          });
        }
      } catch (e) {
        developer.log('Error geocoding location for listing ${listing.id}: $e', name: 'MAP_VIEW');
      }
      
      // Add a small delay between geocoding requests to respect rate limits
      await Future.delayed(Duration(milliseconds: 200));
    }
    
    setState(() {
      _isLoading = false;
    });
    
    // If we have coordinates, move camera to show all listings
    if (_markers.isNotEmpty) {
      _fitMapToMarkers();
    }
  }

  Future<void> _fitMapToMarkers() async {
    if (_markers.isEmpty) return;
    
    try {
      final GoogleMapController mapController = await _controller.future;
      
      // double minLat = 90;
      // double maxLat = -90;
      // double minLng = 180;
      // double maxLng = -180;
      double minLat = 90.0, maxLat = -90.0;
      double minLng = 180.0, maxLng = -180.0;
      
      // for (Marker marker in _markers) {
      //   if (marker.position.latitude < minLat) minLat = marker.position.latitude;
      //   if (marker.position.latitude > maxLat) maxLat = marker.position.latitude;
      //   if (marker.position.longitude < minLng) minLng = marker.position.longitude;
      //   if (marker.position.longitude > maxLng) maxLng = marker.position.longitude;
      // }
      for (Marker marker in _markers) {
        minLat = minLat > marker.position.latitude ? marker.position.latitude : minLat;
        maxLat = maxLat < marker.position.latitude ? marker.position.latitude : maxLat;
        minLng = minLng > marker.position.longitude ? marker.position.longitude : minLng;
        maxLng = maxLng < marker.position.longitude ? marker.position.longitude : maxLng;
      }
      
      // Add padding to bounds
      // final LatLngBounds bounds = LatLngBounds(
      //   southwest: LatLng(minLat - 0.01, minLng - 0.01),
      //   northeast: LatLng(maxLat + 0.01, maxLng + 0.01),
      // );
      final LatLngBounds bounds = LatLngBounds(
        southwest: LatLng(minLat - 0.01, minLng - 0.01),
        northeast: LatLng(maxLat + 0.01, maxLng + 0.01),
      );
      
      await mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
    } catch (e) {
      developer.log('Error fitting map to markers: $e', name: 'MAP_VIEW');
    }
  }
  
  // void _showListingDetails(Listing listing) {
  //   Navigator.of(context).push(
  //     MaterialPageRoute(
  //       builder: (context) => ListingDetailsScreen(
  //         listingId: listing.id,
  //       ),
  //     ),
  //   );
  // }

  void _showListingDetails(Listing listing) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ListingDetailsScreen(
          listingId: listing.id,
        ),
      ),
    );
  }

  Widget _buildMapErrorFallback(List<Listing> listings) {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.map_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Unable to load map view'),
            SizedBox(height: 8),
            if (listings.isNotEmpty) 
              Expanded(
                child: ListView.builder(
                  itemCount: listings.length,
                  itemBuilder: (context, index) {
                    final listing = listings[index];
                    return ListTile(
                      title: Text(listing.title),
                      subtitle: Text('${listing.location} - ${listing.formattedPrice}'),
                      leading: listing.images.isNotEmpty 
                        ? Image.network(listing.images[0], width: 50, height: 50, fit: BoxFit.cover)
                        : Icon(Icons.home),
                      onTap: () => _showListingDetails(listing),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Widget _buildMapErrorFallback() {
  //   return Container(
  //     color: Colors.grey[200],
  //     child: Center(
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           Icon(Icons.map_outlined, size: 64, color: Colors.grey),
  //           SizedBox(height: 16),
  //           Text('Unable to load map view'),
  //           SizedBox(height: 8),
  //           if (_listings.isNotEmpty) 
  //             Expanded(
  //               child: ListView.builder(
  //                 itemCount: _listings.length,
  //                 itemBuilder: (context, index) {
  //                   final listing = _listings[index];
  //                   return ListTile(
  //                     title: Text(listing.title),
  //                     subtitle: Text('${listing.location} - ${listing.formattedPrice}'),
  //                     leading: listing.images.isNotEmpty 
  //                       ? Image.network(listing.images[0], width: 50, height: 50, fit: BoxFit.cover)
  //                       : Icon(Icons.home),
  //                     onTap: () => _showListingDetails(listing),
  //                   );
  //                 },
  //               ),
  //             ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Future<void> _loadProperties() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      Set<Marker> markers = {};
      
      if (_selectedNeighborhood != null) {
        // Load properties for the selected neighborhood
        final result = await _housingDataService.getPropertiesByNeighborhood(_selectedNeighborhood!);
        if (result['success'] == true && result['data'] != null) {
          final properties = result['data'] as List<dynamic>;
          
          // Create markers for each property
          for (int i = 0; i < properties.length; i++) {
            final property = properties[i] as Map<String, dynamic>;
            
            // Get neighborhood coordinates (in a real app, each property would have its own coordinates)
            final neighborhoodName = property['neighborhood'] ?? _selectedNeighborhood;
            final coordinates = _neighborhoodCoordinates[neighborhoodName] ?? 
                               _neighborhoodCoordinates[_selectedNeighborhood] ?? 
                               _kigaliCenter.target;
            
            // Add some randomness to spread out markers in the same neighborhood
            final random = i * 0.0005;
            final position = LatLng(
              coordinates.latitude + random,
              coordinates.longitude + random,
            );
            
            // Create custom marker icon
            final BitmapDescriptor markerIcon = await _createMarkerIcon(property);
            
            // Create marker
            final marker = Marker(
              markerId: MarkerId(property['id'].toString()),
              position: position,
              icon: markerIcon,
              infoWindow: InfoWindow(
                title: property['title'],
                snippet: '${property['bedrooms']} bed, ${property['bathrooms']} bath - \$${property['price']}/${property['currency']}',
              ),
              onTap: () {
                _showPropertyDetails(property);
              },
            );
            
            markers.add(marker);
          }
        }
      } else {
        // Load all neighborhoods
        for (final neighborhood in _neighborhoods) {
          final coordinates = _neighborhoodCoordinates[neighborhood] ?? _kigaliCenter.target;
          
          // Create marker
          final marker = Marker(
            markerId: MarkerId(neighborhood),
            position: coordinates,
            infoWindow: InfoWindow(
              title: neighborhood,
              snippet: 'Tap to see properties',
            ),
            onTap: () {
              setState(() {
                _selectedNeighborhood = neighborhood;
              });
              _loadProperties();
            },
          );
          
          markers.add(marker);
        }
      }
      
      setState(() {
        _markers = markers;
        _isLoading = false;
      });
      
      // Move camera to the selected neighborhood or center of Kigali
      if (_selectedNeighborhood != null && _neighborhoodCoordinates.containsKey(_selectedNeighborhood)) {
        final controller = await _controller.future;
        controller.animateCamera(CameraUpdate.newLatLngZoom(
          _neighborhoodCoordinates[_selectedNeighborhood]!,
          14.0,
        ));
      }
    } catch (e) {
      developer.log('Error loading properties: $e', name: 'MAP_VIEW');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<BitmapDescriptor> _createMarkerIcon(Map<String, dynamic> property) async {
    // Choose icon color based on property type
    Color markerColor;
    switch (property['type']) {
      case 'apartment':
        markerColor = Colors.blue;
        break;
      case 'house':
        markerColor = Colors.green;
        break;
      case 'shared':
        markerColor = Colors.orange;
        break;
      case 'studio':
        markerColor = Colors.purple;
        break;
      default:
        markerColor = Colors.red;
    }
    
    // Create custom marker with price
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = Size(120, 80);
    
    // Draw marker background
    final paint = Paint()
      ..color = markerColor
      ..style = PaintingStyle.fill;
    
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    
    // Draw shadow
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(4, 4, size.width - 8, size.height - 24),
        const Radius.circular(8),
      ),
      shadowPaint,
    );
    
    // Draw marker body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height - 20),
        const Radius.circular(8),
      ),
      paint,
    );
    
    // Draw triangle pointer
    final path = Path()
      ..moveTo(size.width / 2 - 10, size.height - 20)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width / 2 + 10, size.height - 20)
      ..close();
    canvas.drawPath(path, paint);
    
    // Draw price text
    final textPainter = TextPainter(
      text: TextSpan(
        text: '\$${property['price']}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(minWidth: 0, maxWidth: size.width);
    textPainter.paint(
      canvas,
      Offset((size.width - textPainter.width) / 2, (size.height - 20 - textPainter.height) / 2),
    );
    
    // Convert to image
    final picture = recorder.endRecording();
    final img = await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List bytes = byteData!.buffer.asUint8List();
    
    return BitmapDescriptor.fromBytes(bytes);
  }
  
  void _showPropertyDetails(Map<String, dynamic> property) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
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
              
              // Property image placeholder
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(Icons.home, size: 80, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),
              
              // Property title
              Text(
                property['title'],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              // Property details
              Row(
                children: [
                  _buildDetailChip(Icons.king_bed, '${property['bedrooms']} bed'),
                  const SizedBox(width: 8),
                  _buildDetailChip(Icons.bathtub, '${property['bathrooms']} bath'),
                  const SizedBox(width: 8),
                  _buildDetailChip(
                    Icons.chair, 
                    property['furnished'] ? 'Furnished' : 'Unfurnished',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Price
              Row(
                children: [
                  Text(
                    '\$${property['price']}/${property['currency']}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const Text(
                    ' per month',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Description
              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                property['description'],
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              
              // Amenities
              const Text(
                'Amenities',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (property['amenities'] as List<dynamic>).map((amenity) => 
                  Chip(
                    label: Text(amenity),
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    side: BorderSide.none,
                  )
                ).toList(),
              ),
              const SizedBox(height: 24),
              
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
                child: const Text('Contact Landlord'),
              ),
              const SizedBox(height: 8),
              
              // Save button
              OutlinedButton(
                onPressed: () {
                  // Implement save functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Property saved!')),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Save Property'),
              ),
            ],
          ),
        ),
      ),
    );
  }

//   Widget _buildMapErrorFallback() {
//   return Container(
//     color: Colors.grey[200],
//     child: Center(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(Icons.map, size: 64, color: Colors.grey),
//           SizedBox(height: 16),
//           Text('Unable to load map view'),
//           SizedBox(height: 8),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//             },
//             child: Text('Return to listings'),
//           )
//         ],
//       ),
//     ),
//   );
// }
  
  Widget _buildDetailChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.blue),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
  // Get the listing provider
  final listingProvider = Provider.of<ListingProvider>(context);
  
  return Scaffold(
    appBar: AppBar(
      title: const Text('Listings Map'),
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: _showFilterDialog,
        ),
      ],
    ),
    body: Stack(
      children: [
        kIsWeb && _isMapError
        ? _buildMapErrorFallback(listingProvider.listings)
        : GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _kigaliCenter,
            markers: _markers,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              developer.log('Map created successfully with ${_markers.length} markers', name: 'MAP_VIEW');
            },
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            compassEnabled: true,
            zoomControlsEnabled: kIsWeb ? true : false,
          ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: _loadListings,
      child: const Icon(Icons.refresh),
    ),
  );
}
  // Widget build(BuildContext context) {
  //   // Access the listing provider to get the real listings
  //   final listingProvider = Provider.of<ListingProvider>(context);
  //   final listings = listingProvider.listings;
    
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: const Text('Listings Map'),
  //       actions: [
  //         IconButton(
  //           icon: const Icon(Icons.filter_list),
  //           onPressed: _showFilterDialog,
  //         ),
  //       ],
  //     ),
  //     body: Stack(
  //       children: [
  //         kIsWeb && _isMapError
  //         ? _buildMapErrorFallback(listings)
  //         : GoogleMap(
  //             mapType: MapType.normal,
  //             initialCameraPosition: _kigaliCenter,
  //             markers: _markers,
  //             onMapCreated: (GoogleMapController controller) {
  //               _controller.complete(controller);
  //               developer.log('Map created successfully', name: 'MAP_VIEW');
  //             },
  //             // onError: (errorMessage) {
  //             //   developer.log('Google Maps error: $errorMessage', name: 'MAP_ERROR');
  //             //   setState(() {
  //             //     _isMapError = true;
  //             //   });
  //             // },
  //             myLocationButtonEnabled: true,
  //             myLocationEnabled: true,
  //             compassEnabled: true,
  //             zoomControlsEnabled: kIsWeb ? true : false,
  //           ),
  //         if (_isLoading)
  //           Container(
  //             color: Colors.black.withOpacity(0.3),
  //             child: const Center(
  //               child: CircularProgressIndicator(),
  //             ),
  //           ),
  //       ],
  //     ),
  //     floatingActionButton: FloatingActionButton(
  //       onPressed: _loadListings,
  //       child: const Icon(Icons.refresh),
  //     ),
  //   );
  // }

  // void _showFilterDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Select Neighborhood'),
  //       content: SizedBox(
  //         width: double.maxFinite,
  //         child: ListView.builder(
  //           shrinkWrap: true,
  //           itemCount: _neighborhoods.length,
  //           itemBuilder: (context, index) {
  //             final neighborhood = _neighborhoods[index];
  //             return ListTile(
  //               title: Text(neighborhood),
  //               onTap: () {
  //                 Navigator.pop(context);
  //                 setState(() {
  //                   _selectedNeighborhood = neighborhood;
  //                 });
  //                 _loadListings();
  //               },
  //             );
  //           },
  //         ),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () {
  //             Navigator.pop(context);
  //           },
  //           child: const Text('Cancel'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  void _showFilterDialog() {
    // Get the neighborhoods from your current data
    final neighborhoods = Provider.of<ListingProvider>(context, listen: false)
        .listings
        .map((listing) => listing.location)
        .toSet()
        .toList();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Location'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: neighborhoods.length,
            itemBuilder: (context, index) {
              final neighborhood = neighborhoods[index];
              return ListTile(
                title: Text(neighborhood),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedNeighborhood = neighborhood;
                  });
                  _loadListings();
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _selectedNeighborhood = null;
              });
              _loadListings();
            },
            child: const Text('Show All'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
  
  // void _showFilterDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Select Neighborhood'),
  //       content: SizedBox(
  //         width: double.maxFinite,
  //         child: ListView.builder(
  //           shrinkWrap: true,
  //           itemCount: _neighborhoods.length,
  //           itemBuilder: (context, index) {
  //             final neighborhood = _neighborhoods[index];
  //             return ListTile(
  //               title: Text(neighborhood),
  //               onTap: () {
  //                 Navigator.pop(context);
  //                 setState(() {
  //                   _selectedNeighborhood = neighborhood;
  //                 });
  //                 _loadProperties();
  //               },
  //             );
  //           },
  //         ),
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () {
  //             Navigator.pop(context);
  //           },
  //           child: const Text('Cancel'),
  //         ),
  //       ],
  //     ),
  //   );
  // }
} 