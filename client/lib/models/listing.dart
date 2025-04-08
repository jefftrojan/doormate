import 'package:intl/intl.dart';

class Listing {
  final String id;
  final String title;
  final String description;
  final double price;
  final String location;
  final List<String> images;
  final List<String> amenities;
  final String? university;
  final String? roomType;
  final DateTime availableFrom;
  final DateTime? availableUntil;
  final String userId;
  final Map<String, dynamic>? user;
  final bool isSaved;
  final int? bedrooms;
  final int? bathrooms;
  final int? roommates;
  final int? totalRooms;
  final DateTime createdAt;

  Listing({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.location,
    required this.images,
    required this.amenities,
    this.university,
    this.roomType,
    required this.availableFrom,
    this.availableUntil,
    required this.userId,
    this.user,
    this.isSaved = false,
    this.bedrooms,
    this.bathrooms,
    this.roommates,
    this.totalRooms,
    required this.createdAt,
  });

  // Improved fromJson method with robust null handling
  factory Listing.fromJson(Map<String, dynamic> json) {
    try {
      // Handle different ID field names
      final String idValue;
      if (json['_id'] != null) {
        idValue = json['_id'].toString();
      } else if (json['id'] != null) {
        idValue = json['id'].toString();
      } else {
        print('Available keys in JSON: ${json.keys.join(", ")}');
        throw Exception('No ID field found in listing');
      }
                 
      // Get title with fallback
      final title = json['title']?.toString() ?? 'Untitled Listing';
      
      // Get description with fallback
      final description = json['description']?.toString() ?? 'No description available';
      
      // Parse price safely
      double price = 0.0;
      if (json['price'] != null) {
        if (json['price'] is num) {
          price = (json['price'] as num).toDouble();
        } else {
          try {
            price = double.parse(json['price'].toString());
          } catch (e) {
            // Leave default if parsing fails
          }
        }
      }
      
      // Get location with fallback
      final location = json['location']?.toString() ?? 'Unknown location';
      
      // Safely parse images
      List<String> images = [];
      if (json['images'] != null) {
        if (json['images'] is List) {
          images = (json['images'] as List)
            .where((item) => item != null)
            .map((item) => item.toString())
            .toList();
        }
      }
      
      // Safely parse amenities
      List<String> amenities = [];
      if (json['amenities'] != null) {
        if (json['amenities'] is List) {
          amenities = (json['amenities'] as List)
            .where((item) => item != null)
            .map((item) => item.toString())
            .toList();
        }
      }
      
      // Optional fields with null handling
      final university = json['university']?.toString();
      final roomType = json['room_type']?.toString();
      
      // Parse dates safely
      DateTime availableFrom;
      try {
        if (json['available_from'] != null) {
          availableFrom = DateTime.parse(json['available_from'].toString());
        } else {
          availableFrom = DateTime.now();
        }
      } catch (e) {
        availableFrom = DateTime.now();
      }
      
      DateTime? availableUntil;
      try {
        if (json['available_until'] != null) {
          availableUntil = DateTime.parse(json['available_until'].toString());
        }
      } catch (e) {
        // Leave as null if parsing fails
      }
      
      // Get user id with fallback
      final userId = json['user_id']?.toString() ?? '';
      
      // Parse user object safely
      Map<String, dynamic>? user;
      if (json['user'] != null && json['user'] is Map) {
        user = Map<String, dynamic>.from(json['user'] as Map);
      }
      
      // Parse boolean safely
      final isSaved = json['is_saved'] == true || json['isSaved'] == true;
      
      // Parse numeric values safely
      int? bedrooms;
      if (json['bedrooms'] != null) {
        if (json['bedrooms'] is num) {
          bedrooms = (json['bedrooms'] as num).toInt();
        } else {
          try {
            bedrooms = int.parse(json['bedrooms'].toString());
          } catch (e) {
            // Leave as null if parsing fails
          }
        }
      }
      
      int? bathrooms;
      if (json['bathrooms'] != null) {
        if (json['bathrooms'] is num) {
          bathrooms = (json['bathrooms'] as num).toInt();
        } else {
          try {
            bathrooms = int.parse(json['bathrooms'].toString());
          } catch (e) {
            // Leave as null if parsing fails
          }
        }
      }
      
      int? roommates;
      if (json['roommates'] != null) {
        if (json['roommates'] is num) {
          roommates = (json['roommates'] as num).toInt();
        } else {
          try {
            roommates = int.parse(json['roommates'].toString());
          } catch (e) {
            // Leave as null if parsing fails
          }
        }
      }
      
      int? totalRooms;
      if (json['total_rooms'] != null) {
        if (json['total_rooms'] is num) {
          totalRooms = (json['total_rooms'] as num).toInt();
        } else {
          try {
            totalRooms = int.parse(json['total_rooms'].toString());
          } catch (e) {
            // Leave as null if parsing fails
          }
        }
      }
      
      // Parse createdAt date safely
      DateTime createdAt;
      try {
        if (json['created_at'] != null) {
          createdAt = DateTime.parse(json['created_at'].toString());
        } else {
          createdAt = DateTime.now();
        }
      } catch (e) {
        createdAt = DateTime.now();
      }
      
      return Listing(
        id: idValue,
        title: title,
        description: description,
        price: price,
        location: location,
        images: images,
        amenities: amenities,
        university: university,
        roomType: roomType,
        availableFrom: availableFrom,
        availableUntil: availableUntil,
        userId: userId,
        user: user,
        isSaved: isSaved,
        bedrooms: bedrooms,
        bathrooms: bathrooms,
        roommates: roommates,
        totalRooms: totalRooms,
        createdAt: createdAt,
      );
    } catch (e) {
      print('Error creating Listing from JSON: $e');
      print('Problematic JSON: $json');
      rethrow;
    }
  }

  // Helper property for formatted price
  String get formattedPrice => '\$${price.toStringAsFixed(0)}/month';
  
  // Helper properties for formatted dates
  String get formattedAvailableFrom => DateFormat('MMM d, yyyy').format(availableFrom);
  String get formattedAvailableUntil => availableUntil != null 
      ? DateFormat('MMM d, yyyy').format(availableUntil!)
      : 'No end date';

  // Helper method to create a copy with updates
  Listing copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    String? location,
    List<String>? images,
    List<String>? amenities,
    String? university,
    String? roomType,
    DateTime? availableFrom,
    DateTime? availableUntil,
    String? userId,
    Map<String, dynamic>? user,
    bool? isSaved,
    int? bedrooms,
    int? bathrooms,
    int? roommates,
    int? totalRooms,
    DateTime? createdAt,
  }) {
    return Listing(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      location: location ?? this.location,
      images: images ?? this.images,
      amenities: amenities ?? this.amenities,
      university: university ?? this.university,
      roomType: roomType ?? this.roomType,
      availableFrom: availableFrom ?? this.availableFrom,
      availableUntil: availableUntil ?? this.availableUntil,
      userId: userId ?? this.userId,
      user: user ?? this.user,
      isSaved: isSaved ?? this.isSaved,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      roommates: roommates ?? this.roommates,
      totalRooms: totalRooms ?? this.totalRooms,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}