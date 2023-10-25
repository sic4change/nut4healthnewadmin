import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../authentication/data/firebase_auth_repository.dart';
import '../../../common_data/firestore_data_source.dart';
import '../../countries/domain/country.dart';

import 'package:rxdart/rxdart.dart';

import '../domain/region_full.dart';
import '../domain/region.dart';

String documentIdFromCurrentDate() {
  final iso = DateTime.now().toIso8601String();
  return iso.replaceAll(':', '-').replaceAll('.', '-');
}

class FirestorePath {
  static String country(String uid) => 'countries/$uid';
  static String countries() => 'countries';
  static String region(String uid) => 'regions/$uid';
  static String regions() => 'regions';
}

class FirestoreRepository {
  const FirestoreRepository(this._dataSource);
  final FirestoreDataSource _dataSource;

  Future<void> setRegion({required Region region}) =>
      _dataSource.setData(
        path: FirestorePath.regions(),
        data: region.toMap(),
      );

  Future<void> deleteRegion({required Region region}) async {
    await _dataSource.deleteData(path: FirestorePath.region(region.regionId));
  }

  Future<void> updateRegion({required Region region}) async {
    await _dataSource.updateData(path: FirestorePath.region(region.regionId), data: region.toMap());
  }

  Future<void> addRegion({required Region region}) async {
    await _dataSource.addData(path: FirestorePath.regions(), data: region.toMap());
  }

  Stream<Region> watchRegion({required RegionID regionId}) =>
      _dataSource.watchDocument(
        path: FirestorePath.region(regionId),
        builder: (data, documentId) => Region.fromMap(data, documentId),
      );

  Stream<List<Region>> watchRegions() =>
      _dataSource.watchCollection(
        path: FirestorePath.regions(),
        builder: (data, documentId) => Region.fromMap(data, documentId),
      );

  Stream<List<Country>> watchCountries() =>
      _dataSource.watchCollection(
        path: FirestorePath.countries(),
        builder: (data, documentId) => Country.fromMap(data, documentId),
      );


  Stream<List<RegionFull>> watchRegionWithCountries() {
    return CombineLatestStream.combine2(
        watchRegions(),
        watchCountries(),
          (List<Region> regions, List<Country> countries) {
            final Map<String, Country> countryMap = Map.fromEntries(
              countries.map((country) => MapEntry(country.countryId, country)),
            );
            return regions.map((region) {
              try {
                final Country country = countryMap[region.countryId]!;
                return RegionFull(region, country);
              } catch(e) {
                const Country country = Country(countryId: '', name: '', code: '',
                    active: false, needValidation: false, cases: 0, casesnormopeso: 0, casesmoderada: 0,
                casessevera: 0);
                return RegionFull(region, country);
              }
            }).toList();
          });
  }

  Future<Region> fetchRegion({required RegionID regionId}) =>
      _dataSource.fetchDocument(
        path: FirestorePath.region(regionId),
        builder: (data, documentId) => Region.fromMap(data, documentId),
      );

  Future<List<Region>> fetchRegions() =>
      _dataSource.fetchCollection(
        path: FirestorePath.regions(),
        builder: (data, documentId) => Region.fromMap(data, documentId),
      );

}

final databaseProvider = Provider<FirestoreRepository>((ref) {
  return FirestoreRepository(ref.watch(firestoreDataSourceProvider));
});

final regionsStreamProvider = StreamProvider.autoDispose<List<RegionFull>>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw AssertionError('Region can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchRegionWithCountries();
});

final countriesStreamProvider = StreamProvider.autoDispose<List<Country>>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw AssertionError('Country can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchCountries();
});


final regionStreamProvider =
    StreamProvider.autoDispose.family<Region, RegionID>((ref, regionId) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw AssertionError('Region can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchRegion(regionId: regionId);
});

