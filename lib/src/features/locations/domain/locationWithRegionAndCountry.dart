
import 'package:adminnut4health/src/features/regions/domain/region.dart';

import '../../countries/domain/country.dart';
import 'location.dart';

class LocationWithRegionAndCountry {
  final Location location;
  final Region? region;
  final Country? country;

  LocationWithRegionAndCountry(this.location, this.country, this.region);
}