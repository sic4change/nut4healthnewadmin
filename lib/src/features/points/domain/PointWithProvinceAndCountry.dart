
import 'package:adminnut4health/src/features/regions/domain/region.dart';

import '../../countries/domain/country.dart';
import '../../locations/domain/location.dart';
import '../../provinces/domain/province.dart';
import 'point.dart';

class PointWithProvinceAndCountry {
  final Point point;
  final Province? province;
  final Country? country;
  final Region? region;
  final Location? location;

  PointWithProvinceAndCountry(this.point, this.province, this.country, this.region, this.location);
}