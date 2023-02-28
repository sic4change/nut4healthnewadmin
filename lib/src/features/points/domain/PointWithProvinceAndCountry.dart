
import '../../countries/domain/country.dart';
import '../../provinces/domain/province.dart';
import 'point.dart';

class PointWithProvinceAndCountry {
  final Point point;
  final Province? province;
  final Country? country;

  PointWithProvinceAndCountry(this.point, this.province, this.country);
}