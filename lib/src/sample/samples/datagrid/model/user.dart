import 'package:flutter/material.dart';

/// Custom business object class which contains properties to hold the detailed
/// information about the user which will be rendered in datagrid.
class User {
  /// Creates the user class with required details.
  User(
      this.username,
      this.surname,
      this.name,
      this.email,
      this.phone,
      this.status,
  );

  /// Name of an user.
  final String name;

  /// Surname of an user.
  final String surname;

  /// Username of an user.
  final String username;

  /// Status of an user.
  final bool status;

  /// Phone of an user.
  final String phone;

  /// Email of an user.
  final String email;

}
