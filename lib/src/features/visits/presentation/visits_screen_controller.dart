import 'dart:async';

import 'package:adminnut4health/src/features/visits/domain/visit.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../visits/data/firestore_repository.dart';


class VisitsScreenController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // ok to leave this empty if the return type is FutureOr<void>
  }

  Future<void> addVisit(Visit visit) async {
    final database = ref.read(databaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => database.addVisit(visit: visit));
  }

  Future<void> deleteVisit(Visit visit) async {
    final database = ref.read(databaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => database.deleteVisit(visit: visit));
  }

  Future<void> updateVisit(Visit visit) async {
    final database = ref.read(databaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => database.updateVisit(visit: visit));
  }
}

final visitsScreenControllerProvider =
    AutoDisposeAsyncNotifierProvider<VisitsScreenController, void>(
        VisitsScreenController.new);
