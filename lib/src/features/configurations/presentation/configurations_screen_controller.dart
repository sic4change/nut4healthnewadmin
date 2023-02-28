import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/firestore_repository.dart';
import '../domain/configuration.dart';


class ConfigurationsScreenController extends AutoDisposeAsyncNotifier<void> {

  @override
  FutureOr<void> build() {
    // ok to leave this empty if the return type is FutureOr<void>
  }

  Future<void> addConfiguration(Configuration configuration) async {
    final database = ref.read(databaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => database.addConfiguration(configuration: configuration));
  }

  Future<void> deleteConfiguration(Configuration configuration) async {
    final database = ref.read(databaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => database.deleteConfiguration(configuration: configuration));
  }

  Future<void> updateConfiguration(Configuration configuration) async {
    final database = ref.read(databaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => database.updateConfiguration(configuration: configuration));
  }
}

final configurationsScreenControllerProvider =
    AutoDisposeAsyncNotifierProvider<ConfigurationsScreenController, void>(
        ConfigurationsScreenController.new);
