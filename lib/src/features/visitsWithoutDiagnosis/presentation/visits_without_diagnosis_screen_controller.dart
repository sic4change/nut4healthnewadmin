import 'dart:async';

import 'package:adminnut4health/src/features/visitsWithoutDiagnosis/domain/visitWithoutDiagnosis.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../visitsWithoutDiagnosis/data/firestore_repository.dart';


class VisitsWithoutDiagnosisScreenController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // ok to leave this empty if the return type is FutureOr<void>
  }

  Future<void> addVisitWithoutDiagnosis(VisitWithoutDiagnosis visit) async {
    final database = ref.read(databaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => database.addVisitWithoutDiagnosis(visit: visit));
  }

  Future<void> deleteVisitWithoutDiagnosis(VisitWithoutDiagnosis visit) async {
    final database = ref.read(databaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => database.deleteVisitWithoutDiagnosis(visit: visit));
  }

  Future<void> updateVisitWithoutDiagnosis(VisitWithoutDiagnosis visit) async {
    final database = ref.read(databaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => database.updateVisitWithoutDiagnosis(visit: visit));
  }
}

final visitsWithoutDiagnosisScreenControllerProvider =
    AutoDisposeAsyncNotifierProvider<VisitsWithoutDiagnosisScreenController, void>(
        VisitsWithoutDiagnosisScreenController.new);
