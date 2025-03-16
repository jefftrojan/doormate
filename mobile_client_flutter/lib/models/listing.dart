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
  final DateTime? createdAt;

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
    this.createdAt,
  });

  factory Listing.fromJson(Map<String, dynamic> json) {
    return Listing(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: (json['price'] is int) ? (json['price'] as int).toDouble() : json['price'],
      location: json['location'],
      images: List<String>.from(json['images'] ?? []),
      amenities: List<String>.from(json['amenities'] ?? []),
      university: json['university'],
      roomType: json['room_type'],
      availableFrom: json['available_from'] is String 
          ? DateTime.parse(json['available_from']) 
          : DateTime.fromMillisecondsSinceEpoch(json['available_from']),
      availableUntil: json['available_until'] != null
          ? (json['available_until'] is String 
              ? DateTime.parse(json['available_until'])
              : DateTime.fromMillisecondsSinceEpoch(json['available_until']))
          : null,
      userId: json['user_id'],
      user: json['user'],
      isSaved: json['is_saved'] ?? false,
      bedrooms: json['bedrooms'],
      bathrooms: json['bathrooms'],
      roommates: json['roommates'],
      totalRooms: json['total_rooms'],
      createdAt: json['created_at'] != null 
          ? (json['created_at'] is String 
              ? DateTime.parse(json['created_at'])
              : DateTime.fromMillisecondsSinceEpoch(json['created_at']))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'location': location,
      'images': images,
      'amenities': amenities,
      if (university != null) 'university': university,
      if (roomType != null) 'room_type': roomType,
      'available_from': availableFrom.toIso8601String(),
      if (availableUntil != null) 'available_until': availableUntil?.toIso8601String(),
      'user_id': userId,
      'is_saved': isSaved,
      if (bedrooms != null) 'bedrooms': bedrooms,
      if (bathrooms != null) 'bathrooms': bathrooms,
      if (roommates != null) 'roommates': roommates,
      if (totalRooms != null) 'total_rooms': totalRooms,
      if (createdAt != null) 'created_at': createdAt?.toIso8601String(),
    };
  }

  String get formattedPrice => '\$${price.toStringAsFixed(0)}/month';

  String get formattedAvailableFrom => DateFormat('MMM d, yyyy').format(availableFrom);

  String get formattedAvailableUntil => availableUntil != null
      ? DateFormat('MMM d, yyyy').format(availableUntil!)
      : 'Not specified';
      
  String get formattedCreatedAt => createdAt != null
      ? DateFormat('MMM d, yyyy').format(createdAt!)
      : 'Unknown';
      
  String get bedroomText => bedrooms != null 
      ? '$bedrooms ${bedrooms == 1 ? 'bedroom' : 'bedrooms'}'
      : 'Unknown bedrooms';
      
  String get bathroomText => bathrooms != null 
      ? '$bathrooms ${bathrooms == 1 ? 'bathroom' : 'bathrooms'}'
      : 'Unknown bathrooms';
      
  String get roommateText => roommates != null && roommates! > 0
      ? '$roommates ${roommates == 1 ? 'roommate' : 'roommates'}'
      : 'No roommates';
} 