import 'dart:async';

import 'package:adminnut4health/src/features/countries/domain/country.dart';
import 'package:adminnut4health/src/features/regions/domain/region.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../locations/data/firestore_repository.dart';

import '../domain/location.dart';

class LocationsScreenController extends AutoDisposeAsyncNotifier<void> {

  Country countrySelected = const Country(countryId: "", name: "", code: "",
      active: false, needValidation: false, cases: 0, casesnormopeso: 0, casesmoderada: 0, casessevera: 0);
  Region regionSelected = const Region(regionId: '', name: '', countryId: '', active: false);
  List<Region> regionOptions = List.empty();

  @override
  FutureOr<void> build() {
    // ok to leave this empty if the return type is FutureOr<void>
  }

  Country getCountrySelected() {
    return countrySelected;
  }

  void setCountrySelected(Country countrySelected) {
    this.countrySelected = countrySelected;
  }

  Region getRegionSelected() {
    return regionSelected;
  }

  void setRegionSelected(Region regionSelected) {
    this.regionSelected = regionSelected;
  }

  void setRegionOptions(List<Region> regionOptions) {
    this.regionOptions = regionOptions;
  }

  List<Region> getRegionOptions() {
    return regionOptions;
  }

  Future<void> addLocation(Location location) async {
    final database = ref.read(databaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => database.addLocation(location: location));
  }

  Future<void> deleteLocation(Location location) async {
    final database = ref.read(databaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => database.deleteLocation(location: location));
  }

  Future<void> updateLocation(Location location) async {
    final database = ref.read(databaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => database.updateLocation(location: location));
  }
}

final provincesScreenControllerProvider =
    AutoDisposeAsyncNotifierProvider<LocationsScreenController, void>(
        LocationsScreenController.new);
