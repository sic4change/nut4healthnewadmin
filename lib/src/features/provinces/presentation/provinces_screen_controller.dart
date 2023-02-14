import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../provinces/data/firestore_repository.dart';

import '../domain/province.dart';

class ProvincesScreenController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // ok to leave this empty if the return type is FutureOr<void>
  }

  Future<void> addProvince(Province province) async {
    final database = ref.read(databaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => database.addProvince(province: province));
  }

  Future<void> deleteProvince(Province province) async {
    final database = ref.read(databaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => database.deleteProvince(province: province));
  }

  Future<void> updateProvince(Province province) async {
    final database = ref.read(databaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => database.updateProvince(province: province));
  }
}

final provincesScreenControllerProvider =
    AutoDisposeAsyncNotifierProvider<ProvincesScreenController, void>(
        ProvincesScreenController.new);
