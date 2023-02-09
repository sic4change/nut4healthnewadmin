import 'dart:async';

import 'package:adminnut4health/src/features/users/domain/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../authentication/data/firebase_auth_repository.dart';
import '../../../common_data/firestore_data_source.dart';

String documentIdFromCurrentDate() {
  final iso = DateTime.now().toIso8601String();
  return iso.replaceAll(':', '-').replaceAll('.', '-');
}

class FirestorePath {
  static String user(String uid) => 'users/$uid';
  static String users() => 'users';
}

class FirestoreRepository {
  const FirestoreRepository(this._dataSource);
  final FirestoreDataSource _dataSource;

  Stream<User> watchUser({required UserID userID}) =>
      _dataSource.watchDocument(
        path: FirestorePath.user(userID),
        builder: (data, documentId) => User.fromMap(data, documentId),
      );

}

final databaseProvider = Provider<FirestoreRepository>((ref) {
  return FirestoreRepository(ref.watch(firestoreDataSourceProvider));
});

final userDatabaseStreamProvider =
    StreamProvider.autoDispose.family<User, UserID>((ref, userId) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw AssertionError('Configuration can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchUser(userID: userId);
});

