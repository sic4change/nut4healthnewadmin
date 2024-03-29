import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../authentication/data/firebase_auth_repository.dart';
import '../../data/firestore_repository.dart';
import '../../domain/job.dart';

class JobsScreenController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // ok to leave this empty if the return type is FutureOr<void>
  }

  Future<void> deleteJob(Job job) async {
    final currentUser = ref.read(authRepositoryProvider).currentUser;
    if (currentUser == null) {
      throw AssertionError('User can\'t be null');
    }
    final database = ref.read(databaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => database.deleteJob(uid: currentUser.uid, job: job));
  }
}

final jobsScreenControllerProvider =
    AutoDisposeAsyncNotifierProvider<JobsScreenController, void>(
        JobsScreenController.new);
