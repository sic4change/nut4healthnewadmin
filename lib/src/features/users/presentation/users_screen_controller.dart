import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../users/data/firestore_repository.dart';

import '../domain/user.dart';

class UsersScreenController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // ok to leave this empty if the return type is FutureOr<void>
  }

  Future<void> addUser(User user) async {
    final database = ref.read(databaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => database.addUser(user: user));
  }

  Future<void> deleteUser(User user) async {
    final database = ref.read(databaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => database.deleteUser(user: user));
  }

  Future<void> updateUser(User user) async {
    final database = ref.read(databaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => database.updateUser(user: user));
  }
}

final usersScreenControllerProvider =
    AutoDisposeAsyncNotifierProvider<UsersScreenController, void>(
        UsersScreenController.new);