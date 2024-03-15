import 'dart:async';

import 'package:adminnut4health/src/features/regions/domain/region.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';

import '../../authentication/data/firebase_auth_repository.dart';
import '../../../common_data/firestore_data_source.dart';
import '../../countries/domain/country.dart';
import '../../locations/domain/location.dart';
import '../../provinces/domain/province.dart';
import '../domain/point.dart';
import '../domain/pointWithProvinceAndCountry.dart';

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

  static String point(String uid) => 'points/$uid';
  static String points() => 'points';
}

class FirestoreRepository {
  const FirestoreRepository(this._dataSource);
  final FirestoreDataSource _dataSource;

  Future<void> setPoint({required Point point}) =>
      _dataSource.setData(
        path: FirestorePath.points(),
        data: point.toMap(),
      );

  Future<void> deletePoint({required Point point}) async {
    await _dataSource.deleteData(path: FirestorePath.point(point.pointId));
  }

  Future<void> updatePoint({required Point point}) async {
    await _dataSource.updateData(path: FirestorePath.point(point.pointId), data: point.toMap());
  }

  Future<void> addPoint({required Point point}) async {
    await _dataSource.addData(path: FirestorePath.points(), data: point.toMap());
  }

  Stream<Point> watchPoint({required PointID pointId}) =>
      _dataSource.watchDocument(
        path: FirestorePath.point(pointId),
        builder: (data, documentId) => Point.fromMap(data, documentId),
      );

  Stream<List<Point>> watchPoints() =>
      _dataSource.watchCollection(
        path: FirestorePath.points(),
        builder: (data, documentId) => Point.fromMap(data, documentId),
        sort: (a, b) => a.name.compareTo(b.name),
      );

  Future<List<Point>> fetchPoints() =>
      _dataSource.fetchCollection(
        path: FirestorePath.points(),
        builder: (data, documentId) => Point.fromMap(data, documentId),
      );

  Future<Point> fetchPoint({required PointID pointId}) =>
      _dataSource.fetchDocument(
        path: FirestorePath.point(pointId),
        builder: (data, documentId) => Point.fromMap(data, documentId),
      );

  Stream<List<Province>> watchProvincesInCountry({required CountryID countryId}) {
    return _dataSource.watchCollection(
      path: FirestorePath.provinces(),
      builder: (data, documentId) => Province.fromMap(data, documentId),
      sort: (a, b) => a.name.compareTo(b.name),
    ).map((event) => event.where((element) => element.country == countryId).toList());
  }

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

  Stream<List<Location>> watchLocations() =>
      _dataSource.watchCollection(
        path: FirestorePath.locations(),
        builder: (data, documentId) => Location.fromMap(data, documentId),
        sort: (a, b) => a.name.compareTo(b.name),
      );

  Stream<List<Province>> watchProvinces() =>
      _dataSource.watchCollection(
        path: FirestorePath.provinces(),
        builder: (data, documentId) => Province.fromMap(data, documentId),
        sort: (a, b) => a.name.compareTo(b.name),
      );


  Stream<List<PointWithProvinceAndCountry>> watchPointsWithProvincesAndCountrys() {
    return CombineLatestStream.combine5(
        watchPoints(),
        watchProvinces(),
        watchCountries(),
        watchRegions(),
            watchLocations(),
            (List<Point> points,
             List<Province> provinces,
             List<Country> countries,
             List<Region> regions,
            List<Location> locations,
            ) {
          final Map<String, Province> provinceMap = Map.fromEntries(
            provinces.map((province) => MapEntry(province.provinceId, province)),
          );

          final Map<String, Country> countryMap = Map.fromEntries(
            countries.map((country) => MapEntry(country.countryId, country)),
          );

          final Map<String, Region> regionMap = Map.fromEntries(
            regions.map((region) => MapEntry(region.regionId, region)),
          );

          final Map<String, Location> locationMap = Map.fromEntries(
            locations.map((location) => MapEntry(location.locationId, location)),
          );

          return points.map((point)  {
            final Province province = provinceMap[point.province]??
              const Province(provinceId: '', name: '', country: '', regionId: '', locationId: '', active: false);

            final Country country = countryMap[point.country]?? const Country(countryId: '', name: '', code: '',
                active: false, needValidation: false, cases: 0, casesnormopeso: 0, casesmoderada: 0, casessevera: 0);

            final Region region = regionMap[point.regionId]?? const Region(regionId: '', name: '', countryId: '', active: false);

            final Location location = locationMap[point.location]?? const Location(locationId: '', regionId: '', name: '', country: '', active: false);

            return PointWithProvinceAndCountry(point, province, country, region, location);
          }).toList();
        });
  }

}

final databaseProvider = Provider<FirestoreRepository>((ref) {
  return FirestoreRepository(ref.watch(firestoreDataSourceProvider));
});

final pointsStreamProvider = StreamProvider.autoDispose<List<PointWithProvinceAndCountry>>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw AssertionError('User can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchPointsWithProvincesAndCountrys();
});

final locationsStreamProvider = StreamProvider.autoDispose<List<Location>>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw AssertionError('User can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchLocations();
});

final provincesStreamProvider = StreamProvider.autoDispose<List<Province>>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw AssertionError('User can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchProvinces();
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

final pointStreamProvider =
    StreamProvider.autoDispose.family<Point, PointID>((ref, pointId) {
  final point = ref.watch(authStateChangesProvider).value;
  if (point == null) {
    throw AssertionError('Point can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchPoint(pointId: pointId);
});

