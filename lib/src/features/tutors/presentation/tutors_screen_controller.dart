import 'dart:async';

import 'package:adminnut4health/src/features/tutors/domain/tutor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../tutors/data/firestore_repository.dart';


class TutorsScreenController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // ok to leave this empty if the return type is FutureOr<void>
  }

  Future<void> addTutor(Tutor tutor) async {
    final database = ref.read(databaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => database.addTutor(tutor: tutor));
  }

  Future<void> deleteTutor(Tutor tutor) async {
    final database = ref.read(databaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => database.deleteTutor(tutor: tutor));
  }

  Future<void> updateTutor(Tutor tutor) async {
    final database = ref.read(databaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => database.updateTutor(tutor: tutor));
  }
}

final tutorsScreenControllerProvider =
    AutoDisposeAsyncNotifierProvider<TutorsScreenController, void>(
        TutorsScreenController.new);
