class Profile {
  final String id;
  final String email;
  final String role; // 'admin' atau 'user'

  Profile({required this.id, required this.email, required this.role});

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      email: json['email'] as String,
      role: json['role'] as String? ?? 'user',
    );
  }

  bool get isAdmin => role == 'admin';
}