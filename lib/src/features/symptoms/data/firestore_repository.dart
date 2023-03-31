import 'dart:async';

import 'package:adminnut4health/src/features/symptoms/domain/symptom.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../authentication/data/firebase_auth_repository.dart';
import '../../../common_data/firestore_data_source.dart';

String documentIdFromCurrentDate() {
  final iso = DateTime.now().toIso8601String();
  return iso.replaceAll(':', '-').replaceAll('.', '-');
}

class FirestorePath {
  static String symptom(String uid) => 'symtoms/$uid';
  static String symptoms() => 'symtoms';
}

class FirestoreRepository {
  const FirestoreRepository(this._dataSource);
  final FirestoreDataSource _dataSource;

  Future<void> setSymptom({required Symptom symptom}) =>
      _dataSource.setData(
        path: FirestorePath.symptoms(),
        data: symptom.toMap(),
      );

  Future<void> deleteSymptom({required Symptom symptom}) async {
    await _dataSource.deleteData(path: FirestorePath.symptom(symptom.symptomId));
  }

  Future<void> updateSymptom({required Symptom symptom}) async {
    await _dataSource.updateData(path: FirestorePath.symptom(symptom.symptomId), data: symptom.toMap());
  }

  Future<void> addSymptom({required Symptom symptom}) async {
    await _dataSource.addData(path: FirestorePath.symptoms(), data: symptom.toMap());
  }

  Stream<Symptom> watchSymptom({required SymptomID symptomId}) =>
      _dataSource.watchDocument(
        path: FirestorePath.symptom(symptomId),
        builder: (data, documentId) => Symptom.fromMap(data, documentId),
      );

  Stream<List<Symptom>> watchSymptoms() =>
      _dataSource.watchCollection(
        path: FirestorePath.symptoms(),
        builder: (data, documentId) => Symptom.fromMap(data, documentId),
      );

  Future<Symptom> fetchSymptom({required SymptomID symptomId}) =>
      _dataSource.fetchDocument(
        path: FirestorePath.symptom(symptomId),
        builder: (data, documentId) => Symptom.fromMap(data, documentId),
      );

  Future<List<Symptom>> fetchSymptoms() =>
      _dataSource.fetchCollection(
        path: FirestorePath.symptoms(),
        builder: (data, documentId) => Symptom.fromMap(data, documentId),
      );

}

final databaseProvider = Provider<FirestoreRepository>((ref) {
  return FirestoreRepository(ref.watch(firestoreDataSourceProvider));
});

final symptomsStreamProvider = StreamProvider.autoDispose<List<Symptom>>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw AssertionError('User can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchSymptoms();
});

final symptomStreamProvider =
    StreamProvider.autoDispose.family<Symptom, SymptomID>((ref, symptomId) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw AssertionError('User can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchSymptom(symptomId: symptomId);
});

