
import 'package:adminnut4health/src/features/regions/domain/region.dart';
import '../../countries/domain/country.dart';

class RegionFull {
  final Region region;
  final Country? country;

  RegionFull(this.region, this.country);
}