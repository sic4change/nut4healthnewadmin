import 'dart:async';

import 'package:adminnut4health/src/features/locations/domain/location.dart';
import 'package:adminnut4health/src/features/locations/domain/locationWithRegionAndCountry.dart';
import 'package:adminnut4health/src/features/regions/domain/region.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../authentication/data/firebase_auth_repository.dart';
import '../../../common_data/firestore_data_source.dart';
import '../../countries/domain/country.dart';

import 'package:rxdart/rxdart.dart';

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
}

class FirestoreRepository {
  const FirestoreRepository(this._dataSource);
  final FirestoreDataSource _dataSource;

  Future<void> setLocation({required Location location}) =>
      _dataSource.setData(
        path: FirestorePath.locations(),
        data: location.toMap(),
      );

  Future<void> deleteLocation({required Location location}) async {
    await _dataSource.deleteData(path: FirestorePath.location(location.locationId));
  }

  Future<void> updateLocation({required Location location}) async {
    await _dataSource.updateData(path: FirestorePath.location(location.locationId), data: location.toMap());
  }

  Future<void> addLocation({required Location location}) async {
    await _dataSource.addData(path: FirestorePath.locations(), data: location.toMap());
  }

  Stream<Location> watchLocation({required LocationID locationId}) =>
      _dataSource.watchDocument(
        path: FirestorePath.location(locationId),
        builder: (data, documentId) => Location.fromMap(data, documentId),
      );

  Stream<List<Location>> watchLocations() =>
      _dataSource.watchCollection(
        path: FirestorePath.locations(),
        builder: (data, documentId) => Location.fromMap(data, documentId),
        sort: (a, b) => a.name.compareTo(b.name),
      );

  Stream<List<Country>> watchCountries() =>
      _dataSource.watchCollection(
        path: FirestorePath.countries(),
        builder: (data, documentId) => Country.fromMap(data, documentId),
        sort: (a, b) => a.name.compareTo(b.name),
      );

  Stream<List<Region>> watchRegions() =>
      _dataSource.watchCollection(
        path: FirestorePath.regions(),
        builder: (data, documentId) => Region.fromMap(data, documentId),
        sort: (a, b) => a.name.compareTo(b.name),
      );



  Stream<List<LocationWithRegionAndCountry>> watchLocationsWithRegionsAndCountrys() {
    return CombineLatestStream.combine3(
        watchLocations(),
        watchCountries(),
        watchRegions(),
            (List<Location> locations,
            List<Country> countries,
            List<Region> regions,
            ) {
            final Map<String, Country> countryMap = Map.fromEntries(
              countries.map((country) => MapEntry(country.countryId, country)),
            );

            final Map<String, Region> regionMap = Map.fromEntries(
              regions.map((region) => MapEntry(region.regionId, region)),
            );
            return locations.map((location)  {
              final Country country = countryMap[location.country] ??
                const Country(countryId: '', name: '', code: '', active: false,
                    needValidation: false, cases: 0,
                    casesnormopeso: 0, casesmoderada: 0, casessevera: 0);

              final Region region = regionMap[location.regionId] ??
                const Region(regionId: '', name: '', countryId: '', active: false);

                return LocationWithRegionAndCountry(location, country, region);

            }).toList();
          });
  }

  Future<Location> fetchLocation({required LocationID locationId}) =>
      _dataSource.fetchDocument(
        path: FirestorePath.location(locationId),
        builder: (data, documentId) => Location.fromMap(data, documentId),
      );

  Future<List<Location>> fetchLocations() =>
      _dataSource.fetchCollection(
        path: FirestorePath.locations(),
        builder: (data, documentId) => Location.fromMap(data, documentId),
      );

}

final databaseProvider = Provider<FirestoreRepository>((ref) {
  return FirestoreRepository(ref.watch(firestoreDataSourceProvider));
});

final locationsStreamProvider = StreamProvider.autoDispose<List<LocationWithRegionAndCountry>>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw AssertionError('User can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchLocationsWithRegionsAndCountrys();
});

final countriesStreamProvider = StreamProvider.autoDispose<List<Country>>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw AssertionError('User can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchCountries();
});

final regionsStreamProvider = StreamProvider.autoDispose<List<Region>>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw AssertionError('User can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchRegions();
});


final locationStreamProvider =
    StreamProvider.autoDispose.family<Location, LocationID>((ref, locationId) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw AssertionError('City can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchLocation(locationId: locationId);
});





