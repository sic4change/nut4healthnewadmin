import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../authentication/data/firebase_auth_repository.dart';
import '../../../common_data/firestore_data_source.dart';

import '../domain/country.dart';

String documentIdFromCurrentDate() {
  final iso = DateTime.now().toIso8601String();
  return iso.replaceAll(':', '-').replaceAll('.', '-');
}

class FirestorePath {
  static String country(String uid) => 'countries/$uid';
  static String countries() => 'countries';
}

class FirestoreRepository {
  const FirestoreRepository(this._dataSource);
  final FirestoreDataSource _dataSource;

  Future<void> setCountry({required Country country}) =>
      _dataSource.setData(
        path: FirestorePath.countries(),
        data: country.toMap(),
      );

  Future<void> deleteCountry({required Country country}) async {
    await _dataSource.deleteData(path: FirestorePath.country(country.countryId));
  }

  Future<void> updateCountry({required Country country}) async {
    await _dataSource.updateData(path: FirestorePath.country(country.countryId), data: country.toMap());
  }

  Future<void> addCountry({required Country country}) async {
    await _dataSource.addData(path: FirestorePath.countries(), data: country.toMap());
  }

  Stream<Country> watchCountry({required CountryID countryId}) =>
      _dataSource.watchDocument(
        path: FirestorePath.country(countryId),
        builder: (data, documentId) => Country.fromMap(data, documentId),
      );

  Stream<List<Country>> watchCountrys() =>
      _dataSource.watchCollection(
        path: FirestorePath.countries(),
        builder: (data, documentId) => Country.fromMap(data, documentId),
      );


  Future<Country> fetchCountry({required CountryID countryId}) =>
      _dataSource.fetchDocument(
        path: FirestorePath.country(countryId),
        builder: (data, documentId) => Country.fromMap(data, documentId),
      );

  Future<List<Country>> fetchCountries() =>
      _dataSource.fetchCollection(
        path: FirestorePath.countries(),
        builder: (data, documentId) => Country.fromMap(data, documentId),
      );

}

final databaseProvider = Provider<FirestoreRepository>((ref) {
  return FirestoreRepository(ref.watch(firestoreDataSourceProvider));
});

final countriesStreamProvider = StreamProvider.autoDispose<List<Country>>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw AssertionError('User can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchCountrys();
});

final countrynStreamProvider =
    StreamProvider.autoDispose.family<Country, CountryID>((ref, countryId) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw AssertionError('User can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchCountry(countryId: countryId);
});

