class UserModel {
  final String? id;
  final String email;
  final String username;

  UserModel({
    this.id,
    required this.email,
    required this.username,
  });

  // Convert to and from JSON for API/storage
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      username: json['username'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'username': username,
  };
}