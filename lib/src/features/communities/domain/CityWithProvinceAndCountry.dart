
import '../../countries/domain/country.dart';
import '../../provinces/domain/province.dart';
import 'city.dart';

class CityWithProvinceAndCountry {
  final City city;
  final Province? province;
  final Country? country;

  CityWithProvinceAndCountry(this.city, this.province, this.country);
}