import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../authentication/data/firebase_auth_repository.dart';
import '../../../common_data/firestore_data_source.dart';
import '../../configurations/domain/configuration.dart';
import '../domain/UserWithConfiguration.dart';
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

  Stream<List<UserWithConfiguration>> watchUsersWithConfigurations() {
    return CombineLatestStream.combine2(
      watchUsers(),
      watchConfigurations(),
          (List<User> users, List<Configuration> configurations) {
        final Map<String, Configuration> configurationMap = Map.fromEntries(
          configurations.map((config) => MapEntry(config.id, config)),
        );
        return users.map((user) {
          try {
            final Configuration configuration =
            configurationMap[user.configuration]!;
            return UserWithConfiguration(user, configuration);
          } catch(e) {
            return UserWithConfiguration(user,Configuration(
                id: '',
                name: '',
                money: '',
                payByConfirmation: 0,
                payByDiagnosis: 0,
                pointByConfirmation: 0,
                pointsByDiagnosis: 0,
                monthlyPayment: 0));
          }
        }).toList();
      },
    );
  }

  Future<List<User>> fetchUsers() =>
      _dataSource.fetchCollection(
        path: FirestorePath.users(),
        builder: (data, documentId) => User.fromMap(data, documentId),
      );

}

final databaseProvider = Provider<FirestoreRepository>((ref) {
  return FirestoreRepository(ref.watch(firestoreDataSourceProvider));
});

final usersStreamProvider = StreamProvider.autoDispose<List<UserWithConfiguration>>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw AssertionError('User can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchUsersWithConfigurations();
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

