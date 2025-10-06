class User {
  final int id;
  final String email;
  final DateTime? createdAt;

  User({required this.id, required this.email, this.createdAt});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      email: json['email'] as String,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : null,
    );
  }
}
