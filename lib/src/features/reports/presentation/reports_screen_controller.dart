import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../reports/data/firestore_repository.dart';
import '../domain/report.dart';


class ReportsScreenController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // ok to leave this empty if the return type is FutureOr<void>
  }

  Future<void> addReport(Report report) async {
    final database = ref.read(databaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => database.addReport(report: report));
  }

  Future<void> deleteReport(Report report) async {
    final database = ref.read(databaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => database.deleteReport(report: report));
  }

  Future<void> updateReport(Report report) async {
    final database = ref.read(databaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => database.updateReport(report: report));
  }
}

final reportsScreenControllerProvider =
    AutoDisposeAsyncNotifierProvider<ReportsScreenController, void>(
        ReportsScreenController.new);
