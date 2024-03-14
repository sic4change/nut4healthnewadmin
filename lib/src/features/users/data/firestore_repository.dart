import 'dart:async';

import 'package:adminnut4health/src/features/provinces/domain/province.dart';
import 'package:adminnut4health/src/features/regions/domain/region.dart';
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

  static String region(String uid) => 'regions/$uid';
  static String regions() => 'regions';

  static String province(String uid) => 'provinces/$uid';
  static String provinces() => 'provinces';
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

  Stream<List<Region>> watchRegions() =>
      _dataSource.watchCollection(
        path: FirestorePath.regions(),
        builder: (data, documentId) => Region.fromMap(data, documentId),
      );

  Stream<List<Province>> watchProvinces() =>
      _dataSource.watchCollection(
        path: FirestorePath.provinces(),
        builder: (data, documentId) => Province.fromMap(data, documentId),
      );

  Stream<List<UserWithConfigurationAndPoint>> watchUsersWithConfigurations() {
    return CombineLatestStream.combine5(
      watchUsers(),
      watchConfigurations(),
      watchPoints(),
      watchRegions(),
      watchProvinces(),(
        List<User> users,
        List<Configuration> configurations,
        List<Point> points,
        List<Region> regions,
        List<Province> provinces,
        ) {
            final Map<String, Configuration> configurationMap = Map.fromEntries(
              configurations.map((config) => MapEntry(config.id, config)),
            );

            final Map<String, Point> pointMap = Map.fromEntries(
              points.map((point) => MapEntry(point.pointId, point)),
            );

            final Map<String, Region> regionMap = Map.fromEntries(
              regions.map((r) => MapEntry(r.regionId, r)),
            );

            final Map<String, Province> provinceMap = Map.fromEntries(
              provinces.map((p) => MapEntry(p.provinceId, p)),
            );

            return users.map((user) {
              final Configuration configuration = configurationMap[user.configuration]??
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
                  );

              final Point point = pointMap[user.point]??
                  const Point(
                    pointId: "",
                    name: "",
                    pointName: "",
                    pointCode: "",
                    fullName: "",
                    type: "",
                    active: false,
                    country: "",
                    regionId: '',
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
                  );

              final Region region = regionMap[user.regionId]??
                const Region(regionId: '', name: '', countryId: '', active: false);

              final Province province = provinceMap[user.provinceId]??
                const Province(provinceId: '', name: '', country: '', regionId: '', locationId: '', active: false);

              return UserWithConfigurationAndPoint(user, configuration, point, region, province);
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

final regionsStreamProvider = StreamProvider.autoDispose<List<Region>>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw AssertionError('User can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchRegions();
});

final provincesStreamProvider = StreamProvider.autoDispose<List<Province>>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw AssertionError('User can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchProvinces();
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

