import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../countries/data/firestore_repository.dart';
import '../domain/country.dart';


class CountriesScreenController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // ok to leave this empty if the return type is FutureOr<void>
  }

  Future<void> addCountry(Country country) async {
    final database = ref.read(databaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => database.addCountry(country: country));
  }

  Future<void> deleteCountry(Country country) async {
    final database = ref.read(databaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => database.deleteCountry(country: country));
  }

  Future<void> updateCountry(Country country) async {
    final database = ref.read(databaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => database.updateCountry(country: country));
  }
}

final countriesScreenControllerProvider =
    AutoDisposeAsyncNotifierProvider<CountriesScreenController, void>(
        CountriesScreenController.new);
