import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../regions/data/firestore_repository.dart';
import '../domain/region.dart';

class RegionsScreenController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // ok to leave this empty if the return type is FutureOr<void>
  }

  Future<void> addRegion(Region region) async {
    final database = ref.read(databaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => database.addRegion(region: region));
  }

  Future<void> deleteRegion(Region region) async {
    final database = ref.read(databaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => database.deleteRegion(region: region));
  }

  Future<void> updateRegion(Region region) async {
    final database = ref.read(databaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => database.updateRegion(region: region));
  }
}

final regionsScreenControllerProvider =
    AutoDisposeAsyncNotifierProvider<RegionsScreenController, void>(
        RegionsScreenController.new);
