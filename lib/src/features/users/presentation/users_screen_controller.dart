import 'dart:async';

import 'package:adminnut4health/src/features/locations/domain/location.dart';
import 'package:adminnut4health/src/features/provinces/domain/province.dart';
import 'package:adminnut4health/src/features/regions/domain/region.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../users/data/firestore_repository.dart';

import '../domain/user.dart';

class UsersScreenController extends AutoDisposeAsyncNotifier<void> {
  Region regionSelected = const Region(regionId: '', name: '', countryId: '', active: false);
  Location locationSelected = const Location.empty();
  Province provinceSelected = const Province(provinceId: '', country: "", regionId: '',
      locationId: "", name: "", active: false);
  List<Location> locationOptions = List.empty();
  List<Province> provinceOptions = List.empty();

  @override
  FutureOr<void> build() {
    // ok to leave this empty if the return type is FutureOr<void>
  }

  Region getRegionSelected() {
    return regionSelected;
  }

  void setRegionSelected(Region regionSelected) {
    this.regionSelected = regionSelected;
  }

  Location getLocationSelected() {
    return locationSelected;
  }

  void setLocationSelected(Location locationSelected) {
    this.locationSelected = locationSelected;
  }

  void setLocationOptions(List<Location> locationOptions) {
    this.locationOptions = locationOptions;
  }

  List<Location> getLocationOptions() {
    return locationOptions;
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

  Future<void> addUser(User user) async {
    final database = ref.read(databaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => database.addUser(user: user));
  }

  Future<void> deleteUser(User user) async {
    final database = ref.read(databaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => database.deleteUser(user: user));
  }

  Future<void> updateUser(User user) async {
    final database = ref.read(databaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => database.updateUser(user: user));
  }
}

final usersScreenControllerProvider =
    AutoDisposeAsyncNotifierProvider<UsersScreenController, void>(
        UsersScreenController.new);
