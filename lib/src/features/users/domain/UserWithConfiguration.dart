import 'package:adminnut4health/src/features/users/domain/user.dart';

import '../../configurations/domain/configuration.dart';

class UserWithConfiguration {
  final User user;
  final Configuration? configuration;

  UserWithConfiguration(this.user, this.configuration);
}