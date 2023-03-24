import 'dart:async';

import 'package:adminnut4health/src/features/treatments/domain/treatment.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:adminnut4health/src/features/treatments/data/firestore_repository.dart';


class TreatmentsScreenController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // ok to leave this empty if the return type is FutureOr<void>
  }

  Future<void> addTreatment(Treatment treatment) async {
    final database = ref.read(databaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => database.addTreatment(treatment: treatment));
  }

  Future<void> deleteTreatment(Treatment treatment) async {
    final database = ref.read(databaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => database.deleteTreatment(treatment: treatment));
  }

  Future<void> updateTreatment(Treatment treatment) async {
    final database = ref.read(databaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => database.updateTreatment(treatment: treatment));
  }
}

final treatmentsScreenControllerProvider =
    AutoDisposeAsyncNotifierProvider<TreatmentsScreenController, void>(
        TreatmentsScreenController.new);
