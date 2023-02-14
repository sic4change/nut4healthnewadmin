import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../authentication/data/firebase_auth_repository.dart';
import '../../../common_data/firestore_data_source.dart';
import '../../countries/domain/country.dart';

import 'package:rxdart/rxdart.dart';

import '../domain/ProvinceWithCountry.dart';
import '../domain/province.dart';

String documentIdFromCurrentDate() {
  final iso = DateTime.now().toIso8601String();
  return iso.replaceAll(':', '-').replaceAll('.', '-');
}

class FirestorePath {
  static String country(String uid) => 'countries/$uid';
  static String countries() => 'countries';
  static String province(String uid) => 'provinces/$uid';
  static String provinces() => 'provinces';
}

class FirestoreRepository {
  const FirestoreRepository(this._dataSource);
  final FirestoreDataSource _dataSource;

  Future<void> setProvince({required Province province}) =>
      _dataSource.setData(
        path: FirestorePath.provinces(),
        data: province.toMap(),
      );

  Future<void> deleteProvince({required Province province}) async {
    await _dataSource.deleteData(path: FirestorePath.province(province.provinceId));
  }

  Future<void> updateProvince({required Province province}) async {
    await _dataSource.updateData(path: FirestorePath.province(province.provinceId), data: province.toMap());
  }

  Future<void> addProvince({required Province province}) async {
    await _dataSource.addData(path: FirestorePath.provinces(), data: province.toMap());
  }

  Stream<Province> watchProvince({required ProvinceID provinceId}) =>
      _dataSource.watchDocument(
        path: FirestorePath.province(provinceId),
        builder: (data, documentId) => Province.fromMap(data, documentId),
      );

  Stream<List<Province>> watchProvinces() =>
      _dataSource.watchCollection(
        path: FirestorePath.provinces(),
        builder: (data, documentId) => Province.fromMap(data, documentId),
      );

  Stream<List<Country>> watchCountries() =>
      _dataSource.watchCollection(
        path: FirestorePath.countries(),
        builder: (data, documentId) => Country.fromMap(data, documentId),
      );


  Stream<List<ProvinceWithCountry>> watchProvinceWithCountries() {
    return CombineLatestStream.combine2(
        watchProvinces(),
        watchCountries(),
          (List<Province> provinces, List<Country> countries) {
            final Map<String, Country> countryMap = Map.fromEntries(
              countries.map((country) => MapEntry(country.countryId, country)),
            );
            return provinces.map((province) {
              try {
                final Country country = countryMap[province.country]!;
                return ProvinceWithCountry(province, country);
              } catch(e) {
                const Country country = Country(countryId: '', name: '', code: '', active: false);
                return ProvinceWithCountry(province, country);
              }
            }).toList();
          });
  }

  Future<Province> fetchProvince({required ProvinceID provinceId}) =>
      _dataSource.fetchDocument(
        path: FirestorePath.province(provinceId),
        builder: (data, documentId) => Province.fromMap(data, documentId),
      );

  Future<List<Province>> fetchProvinces() =>
      _dataSource.fetchCollection(
        path: FirestorePath.provinces(),
        builder: (data, documentId) => Province.fromMap(data, documentId),
      );

}

final databaseProvider = Provider<FirestoreRepository>((ref) {
  return FirestoreRepository(ref.watch(firestoreDataSourceProvider));
});

final provincesStreamProvider = StreamProvider.autoDispose<List<ProvinceWithCountry>>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw AssertionError('Province can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchProvinceWithCountries();
});

final countriesStreamProvider = StreamProvider.autoDispose<List<Country>>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw AssertionError('Country can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchCountries();
});


final provinceStreamProvider =
    StreamProvider.autoDispose.family<Province, ProvinceID>((ref, provinceId) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw AssertionError('Province can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchProvince(provinceId: provinceId);
});

