import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final int id;
  final String name;
  final String username;
  final String email;
  final String role;
  final String? phone;

  const UserModel({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.role,
    this.phone,
  });

  bool get isGuardian => role.toLowerCase().contains('wali');
  bool get isTreasurer =>
      role.toLowerCase().contains('bendahara') ||
      role.toLowerCase().contains('kasir');
  bool get isAdmin =>
      role.toLowerCase().contains('admin') ||
      role.toLowerCase().contains('super');

  factory UserModel.fromJson(Map<String, dynamic> rawJson) {
    Map<String, dynamic> json = rawJson;
    // Unwrap if wrapped in 'user' or 'data'
    if (json['user'] is Map<String, dynamic>) {
      json = json['user'] as Map<String, dynamic>;
    } else if (json['data'] is Map<String, dynamic>) {
      final data = json['data'] as Map<String, dynamic>;
      if (data['user'] is Map<String, dynamic>) {
        json = data['user'] as Map<String, dynamic>;
      } else {
        json = data;
      }
    }

    String roleName = 'Wali Santri';
    if (json['roles'] != null && (json['roles'] as List).isNotEmpty) {
      final firstRole = json['roles'][0];
      if (firstRole is Map<String, dynamic>) {
        roleName = firstRole['name']?.toString() ?? 'Wali Santri';
      } else if (firstRole is String) {
        roleName = firstRole;
      }
    } else if (json['role'] != null) {
      if (json['role'] is String && (json['role'] as String).isNotEmpty) {
        roleName = json['role'] as String;
      } else if (json['role'] is Map<String, dynamic>) {
        roleName = json['role']['name']?.toString() ?? 'Wali Santri';
      }
    }

    return UserModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? json['username']?.toString() ?? 'Pengguna',
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: roleName,
      phone: json['phone']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'role': role,
      'phone': phone,
      'roles': [
        {'id': 1, 'name': role},
      ],
    };
  }

  @override
  List<Object?> get props => [id, name, username, email, role, phone];
}
