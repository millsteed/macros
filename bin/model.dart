import 'dart:convert';

import 'package:macros/model.dart';

@Model()
class User {
  User({
    required this.username,
    required this.password,
  });

  final String username;
  final String password;
}

@Model()
class GetUsersResponse {
  GetUsersResponse({
    required this.users,
    required this.pageNumber,
    required this.pageSize,
  });

  final List<User> users;
  final int pageNumber;
  final int pageSize;
}

void main() {
  const body = '''
    {
      "users": [
        {
          "username": "ramon",
          "password": "12345678"
        }
      ],
      "pageNumber": 1,
      "pageSize": 30
    }
  ''';
  final json = jsonDecode(body) as Map<String, dynamic>;
  final response = GetUsersResponse.fromJson(json);
  final ramon = response.users.first;
  final millsteed = ramon.copyWith(username: 'millsteed', password: '87654321');
  final newResponse = response.copyWith(users: [...response.users, millsteed]);
  print(const JsonEncoder.withIndent('  ').convert(newResponse));
  // $ dart --enable-experiment=macros bin/model.dart
  // {
  //   "users": [
  //     {
  //       "username": "ramon",
  //       "password": "12345678"
  //     },
  //     {
  //       "username": "millsteed",
  //       "password": "87654321"
  //     }
  //   ],
  //   "pageNumber": 1,
  //   "pageSize": 30
  // }
}
