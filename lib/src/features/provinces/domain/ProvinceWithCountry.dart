
import 'package:adminnut4health/src/features/regions/domain/region.dart';

import '../../countries/domain/country.dart';
import 'province.dart';

class ProvinceWithCountry {
  final Province province;
  final Country? country;
  final Region? region;

  ProvinceWithCountry(this.province, this.country, this.region);
}