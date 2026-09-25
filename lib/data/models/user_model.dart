class UserModel {
  final int id;
  final String name;
  final String username;
  final String email;
  final String role;

  const UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    String roleName = 'Wali Santri';
    if (json['roles'] != null && (json['roles'] as List).isNotEmpty) {
      final firstRole = json['roles'][0];
      if (firstRole is Map<String, dynamic>) {
        roleName = firstRole['name'] ?? 'Wali Santri';
      } else if (firstRole is String) {
        roleName = firstRole;
      }
    }
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? json['username'] ?? 'Pengguna',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      role: roleName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'roles': [
        {'id': 1, 'name': role},
      ],
    };
  }
}
