class AgentMessage {
  final String id;
  final String content;
  final String role;
  final String? createdAt;

  AgentMessage({
    required this.id,
    required this.content,
    required this.role,
    this.createdAt,
  });

  factory AgentMessage.fromJson(Map<String, dynamic> json) {
    return AgentMessage(
      id: json['id'],
      content: json['content'],
      role: json['role'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'role': role,
      'created_at': createdAt,
    };
  }
} 