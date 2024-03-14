import 'dart:async';

import 'package:adminnut4health/src/features/regions/domain/region.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../authentication/data/firebase_auth_repository.dart';
import '../../../common_data/firestore_data_source.dart';
import '../../countries/domain/country.dart';

import 'package:rxdart/rxdart.dart';

import '../../provinces/domain/province.dart';
import '../domain/CityWithProvinceAndCountry.dart';
import '../domain/city.dart';

String documentIdFromCurrentDate() {
  final iso = DateTime.now().toIso8601String();
  return iso.replaceAll(':', '-').replaceAll('.', '-');
}

class FirestorePath {
  static String country(String uid) => 'countries/$uid';
  static String countries() => 'countries';

  static String region(String uid) => 'regions/$uid';
  static String regions() => 'regions';

  static String province(String uid) => 'provinces/$uid';
  static String provinces() => 'provinces';

  static String city(String uid) => 'cities/$uid';
  static String cities() => 'cities';
}

class FirestoreRepository {
  const FirestoreRepository(this._dataSource);
  final FirestoreDataSource _dataSource;

  Future<void> setCity({required City city}) =>
      _dataSource.setData(
        path: FirestorePath.cities(),
        data: city.toMap(),
      );

  Future<void> deleteCity({required City city}) async {
    await _dataSource.deleteData(path: FirestorePath.city(city.cityId));
  }

  Future<void> updateCity({required City city}) async {
    await _dataSource.updateData(path: FirestorePath.city(city.cityId), data: city.toMap());
  }

  Future<void> addCity({required City city}) async {
    await _dataSource.addData(path: FirestorePath.cities(), data: city.toMap());
  }

  Stream<City> watchCity({required CityID cityId}) =>
      _dataSource.watchDocument(
        path: FirestorePath.city(cityId),
        builder: (data, documentId) => City.fromMap(data, documentId),
      );

  Stream<List<City>> watchCities() =>
      _dataSource.watchCollection(
        path: FirestorePath.cities(),
        builder: (data, documentId) => City.fromMap(data, documentId),
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

  Stream<List<Region>> watchRegions() =>
      _dataSource.watchCollection(
        path: FirestorePath.regions(),
        builder: (data, documentId) => Region.fromMap(data, documentId),
      );

  Stream<List<Province>> watchProvinces() =>
      _dataSource.watchCollection(
        path: FirestorePath.provinces(),
        builder: (data, documentId) => Province.fromMap(data, documentId),
      );


  Stream<List<CityWithProvinceAndCountry>> watchCitiesWithProvincesAndCountrys() {
    return CombineLatestStream.combine4(
        watchCities(),
        watchProvinces(),
        watchCountries(),
        watchRegions(),
            (List<City> cities,
            List<Province> provinces,
            List<Country> countries,
            List<Region> regions,
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
            return cities.map((city)  {
              final Country country = countryMap[city.country] ??
                const Country(countryId: '', name: '', code: '', active: false,
                    needValidation: false, cases: 0,
                    casesnormopeso: 0, casesmoderada: 0, casessevera: 0);

              final Region region = regionMap[city.regionId] ??
                const Region(regionId: '', name: '', countryId: '', active: false);

              final Province province = provinceMap[city.province]??
                const Province(provinceId: '', name: '', country: '', regionId: '', locationId: '', active: false);

                return CityWithProvinceAndCountry(city, province, country, region);

            }).toList();
          });
  }

  Future<City> fetchCity({required CityID cityId}) =>
      _dataSource.fetchDocument(
        path: FirestorePath.city(cityId),
        builder: (data, documentId) => City.fromMap(data, documentId),
      );

  Future<List<City>> fetchCities() =>
      _dataSource.fetchCollection(
        path: FirestorePath.cities(),
        builder: (data, documentId) => City.fromMap(data, documentId),
      );

}

final databaseProvider = Provider<FirestoreRepository>((ref) {
  return FirestoreRepository(ref.watch(firestoreDataSourceProvider));
});

final citiesStreamProvider = StreamProvider.autoDispose<List<CityWithProvinceAndCountry>>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw AssertionError('User can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchCitiesWithProvincesAndCountrys();
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


final cityStreamProvider =
    StreamProvider.autoDispose.family<City, CityID>((ref, cityId) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw AssertionError('City can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchCity(cityId: cityId);
});





