import 'dart:async';

import 'package:adminnut4health/src/features/notifications/domain/notification.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../notifications/data/firestore_repository.dart';


class NotificationsScreenController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // ok to leave this empty if the return type is FutureOr<void>
  }

  Future<void> addNotification(Notification notification) async {
    final database = ref.read(databaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => database.addNotification(notification: notification));
  }

  Future<void> deleteNotification(Notification notification) async {
    final database = ref.read(databaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => database.deleteNotification(notification: notification));
  }

  Future<void> updateNotification(Notification notification) async {
    final database = ref.read(databaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => database.updateNotification(notification: notification));
  }
}

final notificationsScreenControllerProvider =
    AutoDisposeAsyncNotifierProvider<NotificationsScreenController, void>(
        NotificationsScreenController.new);
