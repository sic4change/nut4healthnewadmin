import 'dart:async';

import 'package:adminnut4health/src/features/locations/domain/location.dart';
import 'package:adminnut4health/src/features/provinces/domain/ProvinceWithCountryRegionAndLocation.dart';
import 'package:adminnut4health/src/features/regions/domain/region.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../authentication/data/firebase_auth_repository.dart';
import '../../../common_data/firestore_data_source.dart';
import '../../countries/domain/country.dart';

import 'package:rxdart/rxdart.dart';

import '../domain/province.dart';

String documentIdFromCurrentDate() {
  final iso = DateTime.now().toIso8601String();
  return iso.replaceAll(':', '-').replaceAll('.', '-');
}

class FirestorePath {
  static String country(String uid) => 'countries/$uid';
  static String countries() => 'countries';

  static String region(String uid) => 'regions/$uid';
  static String regions() => 'regions';

  static String location(String uid) => 'locations/$uid';
  static String locations() => 'locations';

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

  Stream<List<Region>> watchRegions() =>
      _dataSource.watchCollection(
        path: FirestorePath.regions(),
        builder: (data, documentId) => Region.fromMap(data, documentId),
      );

  Stream<List<Location>> watchLocations() =>
      _dataSource.watchCollection(
        path: FirestorePath.locations(),
        builder: (data, documentId) => Location.fromMap(data, documentId),
      );


  Stream<List<ProvinceWithCountryRegionAndLocation>> watchProvinceWithCountries() {
    return CombineLatestStream.combine4(
        watchProvinces(),
        watchCountries(),
        watchRegions(),
          watchLocations(),
          (List<Province> provinces, List<Country> countries, List<Region> regions, List<Location> locations) {
            final Map<String, Country> countryMap = Map.fromEntries(
              countries.map((country) => MapEntry(country.countryId, country)),
            );

            final Map<String, Region> regionMap = Map.fromEntries(
              regions.map((region) => MapEntry(region.regionId, region)),
            );

            final Map<String, Location> locationMap = Map.fromEntries(
              locations.map((location) => MapEntry(location.locationId, location)),
            );

            return provinces.map((province) {
              final Country country = countryMap[province.country] ?? const Country(countryId: '', name: '', code: '',
                  active: false, needValidation: false, cases: 0, casesnormopeso: 0, casesmoderada: 0, casessevera: 0);

              final Region region = regionMap[province.regionId] ?? const Region(regionId: '', name: '', countryId: '', active: false);

              final Location location = locationMap[province.locationId] ?? const Location(locationId: '', regionId: '', name: '', country: '', active: false);

              return ProvinceWithCountryRegionAndLocation(province, country, region, location);
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

final provincesStreamProvider = StreamProvider.autoDispose<List<ProvinceWithCountryRegionAndLocation>>((ref) {
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

final regionsStreamProvider = StreamProvider.autoDispose<List<Region>>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw AssertionError('Region can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchRegions();
});

final locationsStreamProvider = StreamProvider.autoDispose<List<Location>>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw AssertionError('Location can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchLocations();
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

