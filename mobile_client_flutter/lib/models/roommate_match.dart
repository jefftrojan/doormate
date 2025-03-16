class RoommateMatch {
  final String id;
  final String userId;
  final String matchedUserId;  // Added matchedUserId
  final String name;
  final String? profileImage;
  final String? bio;
  final double matchScore;
  final bool isConfirmed;
  final Map<String, double> compatibilityFactors;
  final Map<String, dynamic>? matchedUser;

  RoommateMatch({
    required this.id,
    required this.userId,
    required this.matchedUserId,  // Added to constructor
    required this.name,
    this.profileImage,
    this.bio,
    required this.matchScore,
    required this.isConfirmed,
    required this.compatibilityFactors,
    this.matchedUser,
  });

  factory RoommateMatch.fromJson(Map<String, dynamic> json) {
    return RoommateMatch(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      matchedUserId: json['matched_user_id'] as String,  // Added to fromJson
      name: json['name'] as String,
      profileImage: json['profile_image'] as String?,
      bio: json['bio'] as String?,
      matchScore: (json['match_score'] as num).toDouble(),
      isConfirmed: json['is_confirmed'] as bool? ?? false,
      compatibilityFactors: Map<String, double>.from(
        (json['compatibility_factors'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        ),
      ),
      matchedUser: json['matched_user'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'matched_user_id': matchedUserId,  // Added to toJson
      'name': name,
      'profile_image': profileImage,
      'bio': bio,
      'match_score': matchScore,
      'is_confirmed': isConfirmed,
      'compatibility_factors': compatibilityFactors,
      'matched_user': matchedUser,
    };
  }
}