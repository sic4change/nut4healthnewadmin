import 'dart:async';

import 'package:adminnut4health/src/features/treatments/domain/treatment.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../authentication/data/firebase_auth_repository.dart';
import '../../../common_data/firestore_data_source.dart';

String documentIdFromCurrentDate() {
  final iso = DateTime.now().toIso8601String();
  return iso.replaceAll(':', '-').replaceAll('.', '-');
}

class FirestorePath {
  static String treatment(String uid) => 'treatments/$uid';
  static String treatments() => 'treatments';
}

class FirestoreRepository {
  const FirestoreRepository(this._dataSource);
  final FirestoreDataSource _dataSource;

  Future<void> setTreatment({required Treatment treatment}) =>
      _dataSource.setData(
        path: FirestorePath.treatments(),
        data: treatment.toMap(),
      );

  Future<void> deleteTreatment({required Treatment treatment}) async {
    await _dataSource.deleteData(path: FirestorePath.treatment(treatment.treatmentId));
  }

  Future<void> updateTreatment({required Treatment treatment}) async {
    await _dataSource.updateData(path: FirestorePath.treatment(treatment.treatmentId), data: treatment.toMap());
  }

  Future<void> addTreatment({required Treatment treatment}) async {
    await _dataSource.addData(path: FirestorePath.treatments(), data: treatment.toMap());
  }

  Stream<Treatment> watchTreatment({required TreatmentID treatmentId}) =>
      _dataSource.watchDocument(
        path: FirestorePath.treatment(treatmentId),
        builder: (data, documentId) => Treatment.fromMap(data, documentId),
      );

  Stream<List<Treatment>> watchTreatments() =>
      _dataSource.watchCollection(
        path: FirestorePath.treatments(),
        builder: (data, documentId) => Treatment.fromMap(data, documentId),
      );

  Future<Treatment> fetchTreatment({required TreatmentID treatmentId}) =>
      _dataSource.fetchDocument(
        path: FirestorePath.treatment(treatmentId),
        builder: (data, documentId) => Treatment.fromMap(data, documentId),
      );

  Future<List<Treatment>> fetchTreatments() =>
      _dataSource.fetchCollection(
        path: FirestorePath.treatments(),
        builder: (data, documentId) => Treatment.fromMap(data, documentId),
      );

}

final databaseProvider = Provider<FirestoreRepository>((ref) {
  return FirestoreRepository(ref.watch(firestoreDataSourceProvider));
});

final treatmentsStreamProvider = StreamProvider.autoDispose<List<Treatment>>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw AssertionError('User can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchTreatments();
});

final treatmentStreamProvider =
    StreamProvider.autoDispose.family<Treatment, TreatmentID>((ref, treatmentId) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw AssertionError('User can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchTreatment(treatmentId: treatmentId);
});

