import 'dart:async';

import 'package:adminnut4health/src/features/cases/domain/case.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../cases/data/firestore_repository.dart';


class CasesScreenController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // ok to leave this empty if the return type is FutureOr<void>
  }

  Future<void> addCase(Case myCase) async {
    final database = ref.read(databaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => database.addCase(myCase: myCase));
  }

  Future<void> deleteCase(Case myCase) async {
    final database = ref.read(databaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => database.deleteCase(myCase: myCase));
  }

  Future<void> updateCase(Case myCase) async {
    final database = ref.read(databaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => database.updateCase(myCase: myCase));
  }
}

final casesScreenControllerProvider =
    AutoDisposeAsyncNotifierProvider<CasesScreenController, void>(
        CasesScreenController.new);
