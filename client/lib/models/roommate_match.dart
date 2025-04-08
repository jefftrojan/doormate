import 'package:flutter/material.dart';

class RoommateMatch {
  final String id;
  final String? userId;
  final String? matchedUserId;
  final String name;
  final String? bio;
  final String? profileImage;
  final double matchScore;
  final bool isConfirmed;
  final Map<String, dynamic>? matchedUser;
  final Map<String, double> compatibilityFactors;

  RoommateMatch({
    required this.id,
    this.userId,
    this.matchedUserId,
    required this.name,
    this.bio,
    this.profileImage,
    required this.matchScore,
    this.isConfirmed = false,
    this.matchedUser,
    required this.compatibilityFactors,
  });

  factory RoommateMatch.fromJson(Map<String, dynamic> json) {
    // Handle different JSON structures
    Map<String, dynamic> userJson = {};
    Map<String, double> factors = {};
    
    // Extract user info
    if (json.containsKey('user')) {
      userJson = json['user'] as Map<String, dynamic>;
    }
    
    // Extract compatibility factors
    if (json.containsKey('compatibility_breakdown')) {
      final breakdown = json['compatibility_breakdown'] as Map<String, dynamic>;
      breakdown.forEach((key, value) {
        if (value is num) {
          factors[key] = value.toDouble();
        }
      });
    } else if (json.containsKey('compatibilityFactors')) {
      final breakdown = json['compatibilityFactors'] as Map<String, dynamic>;
      breakdown.forEach((key, value) {
        if (value is num) {
          factors[key] = value.toDouble();
        }
      });
    }
    
    // Handle different ID field names
    String id = '';
    if (userJson.containsKey('id')) {
      id = userJson['id'].toString();
    } else if (json.containsKey('id')) {
      id = json['id'].toString();
    } else if (json.containsKey('_id')) {
      id = json['_id'].toString();
    } else {
      id = DateTime.now().millisecondsSinceEpoch.toString(); // Fallback
    }
    
    return RoommateMatch(
      id: id,
      userId: json['userId'] as String?,
      matchedUserId: json['matchedUserId'] as String?,
      name: userJson['name'] ?? json['name'] ?? 'Unknown',
      bio: json['bio'] ?? 'No bio available',
      profileImage: userJson['profile_photo'] ?? json['profileImage'],
      matchScore: (json['compatibility_score'] is num) 
          ? (json['compatibility_score'] as num).toDouble() 
          : (json['matchScore'] is num)
              ? (json['matchScore'] as num).toDouble()
              : 0.5,
      isConfirmed: json['isConfirmed'] == true || json['is_confirmed'] == true,
      matchedUser: json['matchedUser'] as Map<String, dynamic>?,
      compatibilityFactors: factors,
    );
  }

  // Helper method to get compatibility percentage for display
  String get compatibilityPercentage {
    return '${(matchScore * 100).round()}%';
  }

  // Helper method to get the most compatible factor
  String? get topCompatibilityFactor {
    if (compatibilityFactors.isEmpty) return null;
    
    // Find entry with highest value
    final sortedEntries = compatibilityFactors.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedEntries.first.key;
  }

  // Helper method to get formatted compatibility description
  String get compatibilityDescription {
    if (matchScore >= 0.9) {
      return 'Exceptional match';
    } else if (matchScore >= 0.8) {
      return 'Excellent match';
    } else if (matchScore >= 0.7) {
      return 'Great match';
    } else if (matchScore >= 0.6) {
      return 'Good match';
    } else if (matchScore >= 0.5) {
      return 'Fair match';
    } else {
      return 'Potential match';
    }
  }

  // Helper method to get color for compatibility score
  Color getCompatibilityColor(BuildContext context) {
    if (matchScore >= 0.8) {
      return Colors.green;
    } else if (matchScore >= 0.6) {
      return Colors.teal;
    } else if (matchScore >= 0.4) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}