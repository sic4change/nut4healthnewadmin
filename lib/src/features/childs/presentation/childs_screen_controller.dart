import 'dart:async';

import 'package:adminnut4health/src/features/childs/domain/child.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../childs/data/firestore_repository.dart';


class ChildsScreenController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // ok to leave this empty if the return type is FutureOr<void>
  }

  Future<void> addChild(Child child) async {
    final database = ref.read(databaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => database.addChild(child: child));
  }

  Future<void> deleteChild(Child child) async {
    final database = ref.read(databaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => database.deleteChild(child: child));
  }

  Future<void> updateChild(Child child) async {
    final database = ref.read(databaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => database.updateChild(child: child));
  }
}

final childsScreenControllerProvider =
    AutoDisposeAsyncNotifierProvider<ChildsScreenController, void>(
        ChildsScreenController.new);
