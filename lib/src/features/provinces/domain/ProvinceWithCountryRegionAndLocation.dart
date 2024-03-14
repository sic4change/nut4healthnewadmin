
import 'package:adminnut4health/src/features/regions/domain/region.dart';

import '../../countries/domain/country.dart';
import '../../locations/domain/location.dart';
import 'province.dart';

class ProvinceWithCountryRegionAndLocation {
  final Province province;
  final Country? country;
  final Region? region;
  final Location? location;

  ProvinceWithCountryRegionAndLocation(this.province, this.country, this.region, this.location);
}