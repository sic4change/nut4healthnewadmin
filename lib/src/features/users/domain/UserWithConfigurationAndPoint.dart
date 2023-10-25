import 'package:adminnut4health/src/features/provinces/domain/province.dart';
import 'package:adminnut4health/src/features/regions/domain/region.dart';
import 'package:adminnut4health/src/features/users/domain/user.dart';

import '../../configurations/domain/configuration.dart';
import '../../points/domain/point.dart';

class UserWithConfigurationAndPoint {
  final User user;
  final Configuration? configuration;
  final Point? point;
  final Region? region;
  final Province? province;

  UserWithConfigurationAndPoint(this.user, this.configuration, this.point, this.region, this.province);
}