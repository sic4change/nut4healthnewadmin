import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/firestore_repository.dart';
import '../domain/city.dart';


class CitiesScreenController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // ok to leave this empty if the return type is FutureOr<void>
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
