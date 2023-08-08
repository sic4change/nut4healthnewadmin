import 'dart:async';

import 'package:adminnut4health/src/features/regions/domain/region.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../countries/domain/country.dart';
import '../../provinces/domain/province.dart';
import '../data/firestore_repository.dart';
import '../domain/city.dart';


class CitiesScreenController extends AutoDisposeAsyncNotifier<void> {

  Country countrySelected = const Country(countryId: "", name: "", code: "",
      active: false, cases: 0, casesnormopeso: 0, casesmoderada: 0, casessevera: 0);
  Region regionSelected = const Region(regionId: '', name: '', countryId: '', active: false);
  Province provinceSelected = const Province(provinceId: '', country: "", regionId: '',
      name: "", active: false);
  List<Region> regionOptions = List.empty();
  List<Province> provinceOptions = List.empty();

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

  Province getProvinceSelected() {
    return provinceSelected;
  }

  void setProvinceSelected(Province provinceSelected) {
    this.provinceSelected = provinceSelected;
  }

  void setProvinceOptions(List<Province> provinceOptions) {
    this.provinceOptions = provinceOptions;
  }

  List<Province> getProvinceOptions() {
    return provinceOptions;
  }

  Future<void> addCity(City city) async {
    final database = ref.read(databaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => database.addCity(city: city));
  }

  Future<void> deleteCity(City city) async {
    final database = ref.read(databaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => database.deleteCity(city: city));
  }

  Future<void> updateCity(City city) async {
    final database = ref.read(databaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => database.updateCity(city: city));
  }
}

final citiesScreenControllerProvider =
    AutoDisposeAsyncNotifierProvider<CitiesScreenController, void>(
        CitiesScreenController.new);
