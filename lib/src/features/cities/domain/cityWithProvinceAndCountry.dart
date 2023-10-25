
import 'package:adminnut4health/src/features/regions/domain/region.dart';

import '../../countries/domain/country.dart';
import '../../provinces/domain/province.dart';
import 'city.dart';

class CityWithProvinceAndCountry {
  final City city;
  final Province? province;
  final Region? region;
  final Country? country;

  CityWithProvinceAndCountry(this.city, this.province, this.country, this.region);
}