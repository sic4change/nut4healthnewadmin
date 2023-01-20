import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../authentication/data/firebase_auth_repository.dart';
import '../../../common_data/firestore_data_source.dart';
import '../domain/user.dart';

String documentIdFromCurrentDate() {
  final iso = DateTime.now().toIso8601String();
  return iso.replaceAll(':', '-').replaceAll('.', '-');
}

class FirestorePath {
  static String user(String uid) => 'tests/$uid';
  static String users() => 'tests';
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

  Future<List<User>> fetchUsers() =>
      _dataSource.fetchCollection(
        path: FirestorePath.users(),
        builder: (data, documentId) => User.fromMap(data, documentId),
      );

}

final databaseProvider = Provider<FirestoreRepository>((ref) {
  return FirestoreRepository(ref.watch(firestoreDataSourceProvider));
});

final usersStreamProvider = StreamProvider.autoDispose<List<User>>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw AssertionError('User can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchUsers();
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

