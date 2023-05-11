import 'dart:async';

import 'package:adminnut4health/src/features/childs/domain/child.dart';
import 'package:adminnut4health/src/features/notifications/domain/notification.dart' as domain;
import 'package:adminnut4health/src/features/notifications/domain/notificationWithPointAndChild.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../authentication/data/firebase_auth_repository.dart';
import '../../../common_data/firestore_data_source.dart';
import '../../points/domain/point.dart';

import 'package:rxdart/rxdart.dart';

String documentIdFromCurrentDate() {
  final iso = DateTime.now().toIso8601String();
  return iso.replaceAll(':', '-').replaceAll('.', '-');
}

class FirestorePath {
  static String notification(String uid) => 'notifications/$uid';
  static String notifications() => 'notifications';
  static String point(String uid) => 'points/$uid';
  static String points() => 'points';
  static String child(String uid) => 'childs/$uid';
  static String childs() => 'childs';
}

class FirestoreRepository {
  const FirestoreRepository(this._dataSource);
  final FirestoreDataSource _dataSource;

  Future<void> setNotification({required domain.Notification notification}) =>
      _dataSource.setData(
        path: FirestorePath.notifications(),
        data: notification.toMap(),
      );

  Future<void> deleteNotification({required domain.Notification notification}) async {
    await _dataSource.deleteData(path: FirestorePath.notification(notification.notificationId));
  }

  Future<void> updateNotification({required domain.Notification notification}) async {
    await _dataSource.updateData(path: FirestorePath.notification(notification.notificationId), data: notification.toMap());
  }

  Future<void> addNotification({required domain.Notification notification}) async {
    await _dataSource.addData(path: FirestorePath.notifications(), data: notification.toMap());
  }

  Stream<domain.Notification> watchNotification({required domain.NotificationID notificationId}) =>
      _dataSource.watchDocument(
        path: FirestorePath.notification(notificationId),
        builder: (data, documentId) => domain.Notification.fromMap(data, documentId),
      );

  Stream<List<domain.Notification>> watchNotifications() =>
      _dataSource.watchCollection(
        path: FirestorePath.notifications(),
        builder: (data, documentId) => domain.Notification.fromMap(data, documentId),
      );

  Stream<List<Point>> watchPoints() =>
      _dataSource.watchCollection(
        path: FirestorePath.points(),
        builder: (data, documentId) => Point.fromMap(data, documentId),
      );

  Stream<List<Child>> watchChilds() =>
      _dataSource.watchCollection(
        path: FirestorePath.childs(),
        builder: (data, documentId) => Child.fromMap(data, documentId),
      );

  Stream<List<NotificationWithPointAndChild>> watchNotificationsWithPointAndChild() {
    return CombineLatestStream.combine3(
      watchNotifications(),
      watchPoints(),
      watchChilds(),
          (List<domain.Notification> notifications, List<Point> points, List<Child> childs) {
            final Map<String, Point> pointMap = Map.fromEntries(
              points.map((point) => MapEntry(point.pointId, point)),
            );

            final Map<String, Child> childMap = Map.fromEntries(
              childs.map((child) => MapEntry(child.childId, child)),
            );

            return notifications.map((notification) {
                final point = pointMap[notification.pointId] ?? const Point(
                    pointId: "",
                    name: "",
                    fullName: "",
                    active: false,
                    country: "",
                    province: "",
                    phoneCode: "",
                    phoneLength: 0,
                    latitude: 0.0,
                    longitude: 0.0,
                    cases: 0,
                    casesnormopeso: 0,
                    casesmoderada: 0,
                    casessevera: 0);

                final child = childMap[notification.childId] ?? Child(
                  childId: "",
                  tutorId: "",
                  pointId: "",
                  name: "",
                  surnames: "",
                  birthdate: DateTime.now(),
                  code: "",
                  createDate: DateTime.now(),
                  lastDate: DateTime.now(),
                  ethnicity: "",
                  sex: "",
                  observations: "",
                );

                return NotificationWithPointAndChild(notification, point, child);
            }).toList();
          });
  }

  Future<domain.Notification> fetchNotification({required domain.NotificationID notificationId}) =>
      _dataSource.fetchDocument(
        path: FirestorePath.notification(notificationId),
        builder: (data, documentId) => domain.Notification.fromMap(data, documentId),
      );

  Future<List<domain.Notification>> fetchNotifications() =>
      _dataSource.fetchCollection(
        path: FirestorePath.notifications(),
        builder: (data, documentId) => domain.Notification.fromMap(data, documentId),
      );

}

final databaseProvider = Provider<FirestoreRepository>((ref) {
  return FirestoreRepository(ref.watch(firestoreDataSourceProvider));
});

final notificationsStreamProvider = StreamProvider.autoDispose<List<NotificationWithPointAndChild>>((ref) {
  final notification = ref.watch(authStateChangesProvider).value;
  if (notification == null) {
    throw AssertionError('Notification can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchNotificationsWithPointAndChild();
});

final pointsStreamProvider = StreamProvider.autoDispose<List<Point>>((ref) {
  final notification = ref.watch(authStateChangesProvider).value;
  if (notification == null) {
    throw AssertionError('Notification can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchPoints();
});

final notificationStreamProvider =
    StreamProvider.autoDispose.family<domain.Notification, domain.NotificationID>((ref, notificationId) {
  final notification = ref.watch(authStateChangesProvider).value;
  if (notification == null) {
    throw AssertionError('Notification can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchNotification(notificationId: notificationId);
});

