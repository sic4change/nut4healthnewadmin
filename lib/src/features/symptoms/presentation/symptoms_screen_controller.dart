import 'dart:async';

import 'package:adminnut4health/src/features/symptoms/domain/symptom.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:adminnut4health/src/features/symptoms/data/firestore_repository.dart';


class SymptomsScreenController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // ok to leave this empty if the return type is FutureOr<void>
  }

  Future<void> addSymptom(Symptom symptom) async {
    final database = ref.read(databaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => database.addSymptom(symptom: symptom));
  }

  Future<void> deleteSymptom(Symptom symptom) async {
    final database = ref.read(databaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => database.deleteSymptom(symptom: symptom));
  }

  Future<void> updateSymptom(Symptom symptom) async {
    final database = ref.read(databaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => database.updateSymptom(symptom: symptom));
  }
}

final symptomsScreenControllerProvider =
    AutoDisposeAsyncNotifierProvider<SymptomsScreenController, void>(
        SymptomsScreenController.new);
