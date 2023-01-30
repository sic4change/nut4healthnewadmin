import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../authentication/data/firebase_auth_repository.dart';
import '../../../common_data/firestore_data_source.dart';
import '../domain/configuration.dart';

String documentIdFromCurrentDate() {
  final iso = DateTime.now().toIso8601String();
  return iso.replaceAll(':', '-').replaceAll('.', '-');
}

class FirestorePath {
  static String configuration(String uid) => 'configurations/$uid';
  static String configurations() => 'configurations';
}

class FirestoreRepository {
  const FirestoreRepository(this._dataSource);
  final FirestoreDataSource _dataSource;

  Future<void> setConfiguration({required Configuration configuration}) =>
      _dataSource.setData(
        path: FirestorePath.configurations(),
        data: configuration.toMap(),
      );

  Future<void> deleteConfiguration({required Configuration configuration}) async {
    await _dataSource.deleteData(path: FirestorePath.configuration(configuration.id));
  }

  Future<void> updateConfiguration({required Configuration configuration}) async {
    await _dataSource.updateData(path: FirestorePath.configuration(configuration.id), data: configuration.toMap());
  }

  Future<void> addConfiguration({required Configuration configuration}) async {
    await _dataSource.addData(path: FirestorePath.configurations(), data: configuration.toMap());
  }

  Stream<Configuration> watchConfiguration({required ConfigurationID configurationId}) =>
      _dataSource.watchDocument(
        path: FirestorePath.configuration(configurationId),
        builder: (data, documentId) => Configuration.fromMap(data, documentId),
      );

  Stream<List<Configuration>> watchConfigurations() =>
      _dataSource.watchCollection(
        path: FirestorePath.configurations(),
        builder: (data, documentId) => Configuration.fromMap(data, documentId),
      );

  Future<List<Configuration>> fetchConfigurations() =>
      _dataSource.fetchCollection(
        path: FirestorePath.configurations(),
        builder: (data, documentId) => Configuration.fromMap(data, documentId),
      );

}

final databaseProvider = Provider<FirestoreRepository>((ref) {
  return FirestoreRepository(ref.watch(firestoreDataSourceProvider));
});

final configurationsStreamProvider = StreamProvider.autoDispose<List<Configuration>>((ref) {
  final configuration = ref.watch(authStateChangesProvider).value;
  if (configuration == null) {
    throw AssertionError('Configuration can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchConfigurations();
});

final configurationStreamProvider =
    StreamProvider.autoDispose.family<Configuration, ConfigurationID>((ref, configurationId) {
  final configuration = ref.watch(authStateChangesProvider).value;
  if (configuration == null) {
    throw AssertionError('Configuration can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchConfiguration(configurationId: configurationId);
});

