import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_sikesan_flutter/data/models/user_model.dart';

void main() {
  group('UserModel.fromJson Deserialization Tests', () {
    test('Correctly parses Laravel Sanctum /auth/me payload wrapped in "user"', () {
      final json = {
        'user': {
          'id': 7,
          'name': 'Risda Nur Fajar Purnama,SE',
          'username': 'risda',
          'email': 'risda@example.com',
          'phone': '088218712525',
          'is_active': true,
          'roles': [
            {'id': 2, 'name': 'Bendahara'},
          ],
        },
      };

      final user = UserModel.fromJson(json);

      expect(user.id, 7);
      expect(user.name, 'Risda Nur Fajar Purnama,SE');
      expect(user.username, 'risda');
      expect(user.email, 'risda@example.com');
      expect(user.role, 'Bendahara');
      expect(user.phone, '088218712525');
    });

    test('Correctly parses payload wrapped in "data"', () {
      final json = {
        'data': {
          'id': 10,
          'name': 'Ahmad Fauzi',
          'username': 'afauzi',
          'email': 'fauzi@example.com',
          'roles': [
            {'id': 3, 'name': 'Staff Kesantrian'},
          ],
        },
      };

      final user = UserModel.fromJson(json);

      expect(user.id, 10);
      expect(user.name, 'Ahmad Fauzi');
      expect(user.role, 'Staff Kesantrian');
    });

    test('Correctly parses flat user payload with string role', () {
      final json = {
        'id': 1,
        'name': 'Wali Santri 1',
        'username': 'wali_1',
        'email': 'wali@example.com',
        'role': 'Wali Santri',
      };

      final user = UserModel.fromJson(json);

      expect(user.id, 1);
      expect(user.name, 'Wali Santri 1');
      expect(user.role, 'Wali Santri');
    });

    test('Falls back gracefully to "Pengguna" and "Wali Santri" when fields are missing', () {
      final json = <String, dynamic>{};

      final user = UserModel.fromJson(json);

      expect(user.id, 0);
      expect(user.name, 'Pengguna');
      expect(user.role, 'Wali Santri');
    });

    test('Equatable equality works based on properties', () {
      const user1 = UserModel(
        id: 7,
        name: 'Risda',
        username: 'risda',
        email: 'risda@example.com',
        role: 'Bendahara',
      );
      const user2 = UserModel(
        id: 7,
        name: 'Risda',
        username: 'risda',
        email: 'risda@example.com',
        role: 'Bendahara',
      );
      const user3 = UserModel(
        id: 7,
        name: 'Risda Updated',
        username: 'risda',
        email: 'risda@example.com',
        role: 'Bendahara',
      );

      expect(user1, equals(user2));
      expect(user1 == user3, isFalse);
    });
  });
}
