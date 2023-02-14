
import '../../countries/domain/country.dart';
import 'province.dart';

class ProvinceWithCountry {
  final Province province;
  final Country? country;

  ProvinceWithCountry(this.province, this.country);
}