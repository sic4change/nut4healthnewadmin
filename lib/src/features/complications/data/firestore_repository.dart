import 'dart:async';

import 'package:adminnut4health/src/features/complications/domain/complication.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../authentication/data/firebase_auth_repository.dart';
import '../../../common_data/firestore_data_source.dart';

String documentIdFromCurrentDate() {
  final iso = DateTime.now().toIso8601String();
  return iso.replaceAll(':', '-').replaceAll('.', '-');
}

class FirestorePath {
  static String complication(String uid) => 'complications/$uid';
  static String complications() => 'complications';
}

class FirestoreRepository {
  const FirestoreRepository(this._dataSource);
  final FirestoreDataSource _dataSource;

  Future<void> setComplication({required Complication complication}) =>
      _dataSource.setData(
        path: FirestorePath.complications(),
        data: complication.toMap(),
      );

  Future<void> deleteComplication({required Complication complication}) async {
    await _dataSource.deleteData(path: FirestorePath.complication(complication.complicationId));
  }

  Future<void> updateComplication({required Complication complication}) async {
    await _dataSource.updateData(path: FirestorePath.complication(complication.complicationId), data: complication.toMap());
  }

  Future<void> addComplication({required Complication complication}) async {
    await _dataSource.addData(path: FirestorePath.complications(), data: complication.toMap());
  }

  Stream<Complication> watchComplication({required ComplicationID complicationId}) =>
      _dataSource.watchDocument(
        path: FirestorePath.complication(complicationId),
        builder: (data, documentId) => Complication.fromMap(data, documentId),
      );

  Stream<List<Complication>> watchComplications() =>
      _dataSource.watchCollection(
        path: FirestorePath.complications(),
        builder: (data, documentId) => Complication.fromMap(data, documentId),
      );

  Future<Complication> fetchComplication({required ComplicationID complicationId}) =>
      _dataSource.fetchDocument(
        path: FirestorePath.complication(complicationId),
        builder: (data, documentId) => Complication.fromMap(data, documentId),
      );

  Future<List<Complication>> fetchComplications() =>
      _dataSource.fetchCollection(
        path: FirestorePath.complications(),
        builder: (data, documentId) => Complication.fromMap(data, documentId),
      );

}

final databaseProvider = Provider<FirestoreRepository>((ref) {
  return FirestoreRepository(ref.watch(firestoreDataSourceProvider));
});

final complicationsStreamProvider = StreamProvider.autoDispose<List<Complication>>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw AssertionError('User can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchComplications();
});

final complicationStreamProvider =
    StreamProvider.autoDispose.family<Complication, ComplicationID>((ref, complicationId) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw AssertionError('User can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchComplication(complicationId: complicationId);
});

