import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../authentication/data/firebase_auth_repository.dart';
import '../../../common_data/firestore_data_source.dart';
import '../../configurations/domain/configuration.dart';
import '../../points/domain/point.dart';
import '../domain/UserWithConfigurationAndPoint.dart';
import '../domain/user.dart';

import 'package:rxdart/rxdart.dart';

String documentIdFromCurrentDate() {
  final iso = DateTime.now().toIso8601String();
  return iso.replaceAll(':', '-').replaceAll('.', '-');
}

class FirestorePath {
  static String user(String uid) => 'users/$uid';
  static String users() => 'users';
  static String configuration(String uid) => 'configurations/$uid';
  static String configurations() => 'configurations';
  static String point(String uid) => 'points/$uid';
  static String points() => 'points';
}

class FirestoreRepository {
  const FirestoreRepository(this._dataSource);
  final FirestoreDataSource _dataSource;

  Future<void> setUser({required User user}) =>
      _dataSource.setData(
        path: FirestorePath.users(),
        data: user.toMap(),
      );

  Future<void> deleteUser({required User user}) async {
    await _dataSource.deleteData(path: FirestorePath.user(user.userId));
  }

  Future<void> updateUser({required User user}) async {
    await _dataSource.updateData(path: FirestorePath.user(user.userId), data: user.toMap());
  }

  Future<void> addUser({required User user}) async {
    await _dataSource.addData(path: FirestorePath.users(), data: user.toMap());
  }

  Stream<User> watchUser({required UserID userId}) =>
      _dataSource.watchDocument(
        path: FirestorePath.user(userId),
        builder: (data, documentId) => User.fromMap(data, documentId),
      );

  Stream<List<User>> watchUsers() =>
      _dataSource.watchCollection(
        path: FirestorePath.users(),
        builder: (data, documentId) => User.fromMap(data, documentId),
      );

  Stream<List<Configuration>> watchConfigurations() =>
      _dataSource.watchCollection(
        path: FirestorePath.configurations(),
        builder: (data, documentId) => Configuration.fromMap(data, documentId),
      );

  Stream<List<Point>> watchPoints() =>
      _dataSource.watchCollection(
        path: FirestorePath.points(),
        builder: (data, documentId) => Point.fromMap(data, documentId),
      );

  Stream<List<UserWithConfigurationAndPoint>> watchUsersWithConfigurations() {
    return CombineLatestStream.combine3(
      watchUsers(),
      watchConfigurations(),
          watchPoints(),
          (List<User> users, List<Configuration> configurations, List<Point> points) {
            final Map<String, Configuration> configurationMap = Map.fromEntries(
              configurations.map((config) => MapEntry(config.id, config)),
            );
            final Map<String, Point> pointMap = Map.fromEntries(
              points.map((point) => MapEntry(point.pointId, point)),
            );
            return users.map((user) {
              try {
                final Configuration configuration = configurationMap[user
                    .configuration]!;
                final Point point = pointMap[user.point]!;
                return UserWithConfigurationAndPoint(
                    user, configuration, point);
              } catch (e) {
                try {
                  final Point point = pointMap[user.point]!;
                  return UserWithConfigurationAndPoint(
                      user,
                      const Configuration(
                          id: '',
                          name: '',
                          money: '',
                          payByConfirmation: 0,
                          payByDiagnosis: 0,
                          pointByConfirmation: 0,
                          pointsByDiagnosis: 0,
                          monthlyPayment: 0,
                          blockChainConfiguration: 0,
                          hash: "",
                      ),
                      point);
                } catch (e) {
                  try {
                    final Configuration configuration = configurationMap[user
                        .configuration]!;
                    return UserWithConfigurationAndPoint(
                  user,
                  configuration,
                  const Point(
                      pointId: "",
                      name: "",
                      fullName: "",
                      type: "",
                      active: false,
                      country: "",
                      province: "",
                      phoneCode: "",
                      phoneLength: 0,
                      latitude: 0.0,
                      longitude: 0.0,
                      language: "",
                      cases: 0,
                      casesnormopeso: 0,
                      casesmoderada: 0,
                      casessevera: 0,
                      transactionHash: "",
                  ));
            } catch (e) {
                    return UserWithConfigurationAndPoint(
                  user,
                  const Configuration(
                      id: '',
                      name: '',
                      money: '',
                      payByConfirmation: 0,
                      payByDiagnosis: 0,
                      pointByConfirmation: 0,
                      pointsByDiagnosis: 0,
                      monthlyPayment: 0,
                      blockChainConfiguration: 0,
                      hash: "",
                  ),
                  const Point(
                    pointId: "",
                    name: "",
                    fullName: "",
                    type: "",
                    country: "",
                    active: false,
                    province: "",
                    phoneCode: "",
                    phoneLength: 0,
                    latitude: 0.0,
                    longitude: 0.0,
                    language: "",
                    cases: 0,
                    casesnormopeso: 0,
                    casesmoderada: 0,
                    casessevera: 0,
                    transactionHash: "",
                  ));
            }
                }
              }
            }).toList();
          });
  }

  Future<User> fetchUser({required UserID userId}) =>
      _dataSource.fetchDocument(
        path: FirestorePath.user(userId),
        builder: (data, documentId) => User.fromMap(data, documentId),
      );

  Future<List<User>> fetchUsers() =>
      _dataSource.fetchCollection(
        path: FirestorePath.users(),
        builder: (data, documentId) => User.fromMap(data, documentId),
      );

}

final databaseProvider = Provider<FirestoreRepository>((ref) {
  return FirestoreRepository(ref.watch(firestoreDataSourceProvider));
});

final usersStreamProvider = StreamProvider.autoDispose<List<UserWithConfigurationAndPoint>>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw AssertionError('User can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchUsersWithConfigurations();
});

final pointsStreamProvider = StreamProvider.autoDispose<List<Point>>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw AssertionError('User can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchPoints();
});

final configurationsStreamProvider = StreamProvider.autoDispose<List<Configuration>>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw AssertionError('User can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchConfigurations();
});

final userStreamProvider =
    StreamProvider.autoDispose.family<User, UserID>((ref, userId) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw AssertionError('User can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchUser(userId: userId);
});

