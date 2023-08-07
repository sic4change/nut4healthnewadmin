import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';

import '../../authentication/data/firebase_auth_repository.dart';
import '../../../common_data/firestore_data_source.dart';
import '../../countries/domain/country.dart';
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
    ).map((event) => event.where((element) => element.country == countryId).toList());
  }

  Stream<List<Country>> watchCountries() =>
      _dataSource.watchCollection(
        path: FirestorePath.countries(),
        builder: (data, documentId) => Country.fromMap(data, documentId),
      );

  Stream<List<Province>> watchProvinces() =>
      _dataSource.watchCollection(
        path: FirestorePath.provinces(),
        builder: (data, documentId) => Province.fromMap(data, documentId),
      );


  Stream<List<PointWithProvinceAndCountry>> watchPointsWithProvincesAndCountrys() {
    return CombineLatestStream.combine3(watchPoints(), watchProvinces(), watchCountries(),
            (List<Point> points, List<Province> provinces, List<Country> countries) {
          final Map<String, Province> provinceMap = Map.fromEntries(
            provinces.map((province) => MapEntry(province.provinceId, province)),
          );
          final Map<String, Country> countryMap = Map.fromEntries(
            countries.map((country) => MapEntry(country.countryId, country)),
          );
          return points.map((point)  {
            try {
              final Province province = provinceMap[point.province]!;
              final Country country = countryMap[point.country]!;
              return PointWithProvinceAndCountry(point, province, country);
            } catch(e) {
              const Province province = Province(provinceId: '', name: '', country: '', regionId: '',
                  active: false);
              const Country country = Country(countryId: '', name: '', code: '',
                  active: false, cases: 0, casesnormopeso: 0, casesmoderada: 0,
                  casessevera: 0);
              return PointWithProvinceAndCountry(point, province, country);
            }
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

final pointStreamProvider =
    StreamProvider.autoDispose.family<Point, PointID>((ref, pointId) {
  final point = ref.watch(authStateChangesProvider).value;
  if (point == null) {
    throw AssertionError('Point can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchPoint(pointId: pointId);
});

