import 'dart:async';

import 'package:adminnut4health/src/features/complications/domain/complication.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:adminnut4health/src/features/complications/data/firestore_repository.dart';


class ComplicationsScreenController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // ok to leave this empty if the return type is FutureOr<void>
  }

  Future<void> addComplication(Complication complication) async {
    final database = ref.read(databaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => database.addComplication(complication: complication));
  }

  Future<void> deleteComplication(Complication complication) async {
    final database = ref.read(databaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => database.deleteComplication(complication: complication));
  }

  Future<void> updateComplication(Complication complication) async {
    final database = ref.read(databaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => database.updateComplication(complication: complication));
  }
}

final complicationsScreenControllerProvider =
    AutoDisposeAsyncNotifierProvider<ComplicationsScreenController, void>(
        ComplicationsScreenController.new);
