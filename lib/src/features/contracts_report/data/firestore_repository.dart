import 'dart:async';

import 'package:adminnut4health/src/features/cases/domain/case.dart';
import 'package:adminnut4health/src/features/contracts_report/domain/case_full.dart';
import 'package:adminnut4health/src/features/contracts_report/domain/diagnosis_comunitary_crenam_by_region_and_date_inform.dart';
import 'package:adminnut4health/src/features/countries/domain/country.dart';
import 'package:adminnut4health/src/features/locations/domain/location.dart';
import 'package:adminnut4health/src/features/provinces/domain/province.dart';
import 'package:adminnut4health/src/features/regions/domain/region.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';

import '../../authentication/data/firebase_auth_repository.dart';
import '../../../common_data/firestore_data_source.dart';

import '../../childs/domain/child.dart';
import '../../points/domain/point.dart';
import '../../visits/domain/visit.dart';
import '../domain/PointWithVisitAndChild.dart';
import '../domain/child_inform.dart';
import '../domain/contract.dart';
import '../domain/main_inform.dart';

String documentIdFromCurrentDate() {
  final iso = DateTime.now().toIso8601String();
  return iso.replaceAll(':', '-').replaceAll('.', '-');
}

class FirestorePath {
  static String contracts() => 'contracts';
  static String points() => 'points';
  static String cases() => 'cases';
  static String visits() => 'visits';
  static String childs() => 'childs';
  static String countries() => 'countries';
  static String regions() => 'regions';
  static String locations() => 'locations';
  static String provinces() => 'provinces';
}

class FirestoreRepository {
  const FirestoreRepository(this._dataSource);
  final FirestoreDataSource _dataSource;

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

  Stream<List<Region>> watchRegionsByCountry({required CountryID countryId}) {
    return _dataSource.watchCollection(
        path: FirestorePath.regions(),
        builder: (data, documentId) => Region.fromMap(data, documentId),
        queryBuilder: (query) {
          if (countryId.isNotEmpty) {
            query = query.where('countryId', isEqualTo: countryId);
          }
          return query;
        },
      sort: (a, b) => a.name.compareTo(b.name),
    );
  }

  Stream<List<Location>> watchLocationsByCountryAndRegion({required CountryID countryId, required String regionId}) {
    return _dataSource.watchCollection(
      path: FirestorePath.locations(),
      builder: (data, documentId) => Location.fromMap(data, documentId),
      queryBuilder: (query) {
        if (countryId.isNotEmpty) {
          query = query.where('country', isEqualTo: countryId);
        }
        if (regionId.isNotEmpty) {
          query = query.where('regionId', isEqualTo: regionId);
        }
        return query;
      },
      sort: (a, b) => a.name.compareTo(b.name),
    );
  }

  Stream<List<Province>> watchProvincesByLocation({required CountryID countryId, required String regionId,  required String locationId}) {
    return _dataSource.watchCollection(
      path: FirestorePath.provinces(),
      builder: (data, documentId) => Province.fromMap(data, documentId),
      queryBuilder: (query) {
        if (countryId.isNotEmpty) {
          query = query.where('country', isEqualTo: countryId);
        }
        if (regionId.isNotEmpty) {
          query = query.where('regionId', isEqualTo: regionId);
        }
        if (locationId.isNotEmpty) {
          query = query.where('locationId', isEqualTo: locationId);
        }
        return query;
      },
      sort: (a, b) => a.name.compareTo(b.name),
    );
  }

  Stream<List<Point>> watchPointsByLocation({
    required CountryID countryId,
    required String regionId,
    required String locationId,
    required String provinceId,
    required String pointType,
  }) {
    return _dataSource.watchCollection(
      path: FirestorePath.points(),
      builder: (data, documentId) => Point.fromMap(data, documentId),
      queryBuilder: (query) {
        if (countryId.isNotEmpty) {
          query = query.where('country', isEqualTo: countryId);
        }
        if (regionId.isNotEmpty) {
          query = query.where('regionId', isEqualTo: regionId);
        }
        if (locationId.isNotEmpty) {
          query = query.where('location', isEqualTo: locationId);
        }
        if (provinceId.isNotEmpty) {
          query = query.where('province', isEqualTo: provinceId);
        }
        if (pointType.isNotEmpty) {
          query = query.where('type', isEqualTo: pointType);
        }
        return query;
      },
      sort: (a, b) => a.name.compareTo(b.name),
    );
  }

  Stream<List<Point>> watchPointsByLocationAndPoint({
    required CountryID countryId,
    required String regionId,
    required String locationId,
    required String provinceId,
    required String pointType,
    required String pointId,
  }) {
    return _dataSource.watchCollection(
      path: FirestorePath.points(),
      builder: (data, documentId) => Point.fromMap(data, documentId),
      queryBuilder: (query) {
        if (countryId.isNotEmpty) {
          query = query.where('country', isEqualTo: countryId);
        }
        if (regionId.isNotEmpty) {
          query = query.where('regionId', isEqualTo: regionId);
        }
        if (locationId.isNotEmpty) {
          query = query.where('location', isEqualTo: locationId);
        }
        if (provinceId.isNotEmpty) {
          query = query.where('province', isEqualTo: provinceId);
        }
        if (pointType.isNotEmpty) {
          query = query.where('type', isEqualTo: pointType);
        }
        if (pointId.isNotEmpty) {
          query = query.where('pointId', isEqualTo: pointId);
        }
        return query;
      },
      sort: (a, b) => a.name.compareTo(b.name),
    );
  }

  Stream<List<Contract>> watchContracts(int start, int end) {
    Stream<List<Contract>> contracts = _dataSource.watchCollection(
      path: FirestorePath.contracts(),
      builder: (data, documentId) => Contract.fromMap(data, documentId),
      queryBuilder: (query) {
        query = query.where('creationDateMiliseconds', isGreaterThanOrEqualTo: start)
            .where('creationDateMiliseconds', isLessThanOrEqualTo: end);
        return query;
      },
    );
    return contracts;
  }

  Stream<List<Point>> watchComunitaryCrenamPointsByCountryAndRegion(String countryId, String regionId) {
    Stream<List<Point>> points =  _dataSource.watchCollection(
      path: FirestorePath.points(),
      builder: (data, documentId) => Point.fromMap(data, documentId),
      queryBuilder: (query) {
        query = query.where('type', isEqualTo: 'Otro');
        if (countryId.isNotEmpty) {
          query = query.where('country', isEqualTo: countryId);
        }
        if (regionId.isNotEmpty) {
          query = query.where('regionId', isEqualTo: regionId);
        }
        return query.orderBy('fullName');
      }
    );
    return points;
  }

  Stream<List<Point>> watchPointsByCountryAndRegion(String countryId, String regionId) {
    Stream<List<Point>> points =  _dataSource.watchCollection(
        path: FirestorePath.points(),
        builder: (data, documentId) => Point.fromMap(data, documentId),
        queryBuilder: (query) {
          if (countryId.isNotEmpty) {
            query = query.where('country', isEqualTo: countryId);
          }
          if (regionId.isNotEmpty) {
            query = query.where('regionId', isEqualTo: regionId);
          }
          return query.orderBy('fullName');
        }
    );
    return points;
  }

  Stream<List<Child>> watchChilds() {
    Stream<List<Child>> childs =  _dataSource.watchCollection(
      path: FirestorePath.childs(),
      builder: (data, documentId) => Child.fromMap(data, documentId),
      queryBuilder: (query) => query
          .orderBy('name'),
    );
    return childs;
  }

  Stream<List<Visit>> watchVisits(int start, int end) {
    Stream<List<Visit>> visits =  _dataSource.watchCollection(
      path: FirestorePath.visits(),
      builder: (data, documentId) => Visit.fromMap(data, documentId),
      queryBuilder: (query) {
        query = query.where('createdate', isGreaterThanOrEqualTo: DateTime.fromMillisecondsSinceEpoch(start))
            .where('createdate', isLessThanOrEqualTo: DateTime.fromMillisecondsSinceEpoch(end));
        return query;
      },
    );
    return visits;
  }

  Stream<List<Case>> watchCasesByDate(int start, int end) {
    Stream<List<Case>> cases =  _dataSource.watchCollection(
      path: FirestorePath.cases(),
      builder: (data, documentId) => Case.fromMap(data, documentId),
      queryBuilder: (query) {
        query = query.where('createdate', isGreaterThanOrEqualTo: DateTime.fromMillisecondsSinceEpoch(start))
            .where('createdate', isLessThanOrEqualTo: DateTime.fromMillisecondsSinceEpoch(end));
        return query;
      },
    );
    return cases;
  }

  Stream<List<Case>> _watchOpenCasesBeforeDate(int start) {
    Stream<List<Case>> cases =  _dataSource.watchCollection(
      path: FirestorePath.cases(),
      builder: (data, documentId) => Case.fromMap(data, documentId),
      queryBuilder: (query) {
        query = query.where('createdate', isLessThanOrEqualTo: DateTime.fromMillisecondsSinceEpoch(start))
            .where('closedReason', isEqualTo: "");
        return query;
      },
    );
    return cases;
  }

  Stream<List<VisitWithChildAndPoint>> watchVisitWithChildAndCommunityCrenamPoint(int start, int end, String countryId, String regionId) {
    final emptyPoint = Point.getEmptyPoint();
    final emptyChild = Child.getEmptyChild();
    return CombineLatestStream.combine3(
        watchVisits(start, end), watchChilds(), watchComunitaryCrenamPointsByCountryAndRegion(countryId, regionId),
            (List<Visit> visits, List<Child> childs, List<Point> points) {
          var visitWithChildAndPointList = visits.map((visit) {
            final Map<String, Child> childMap = Map.fromEntries(
              childs.map((child) => MapEntry(child.childId, child)),
            );
            final child = childMap[visit.childId] ?? emptyChild;
            final Map<String, Point> pointMap = Map.fromEntries(
              points.map((point) => MapEntry(point.pointId, point)),
            );
            final point = pointMap[visit.pointId] ?? emptyPoint;
            return VisitWithChildAndPoint(visit, child, point);
          }).where((item) =>
          item.point != emptyPoint
          ).toList();

          var groupedByCaseId = <String, List<VisitWithChildAndPoint>>{};
          for (var visit in visitWithChildAndPointList) {
            groupedByCaseId.putIfAbsent(visit.visit.caseId, () => []).add(visit);
          }

          List<VisitWithChildAndPoint> oldestVisits = [];
          groupedByCaseId.forEach((caseId, visits) {
            VisitWithChildAndPoint oldestVisit = visits.reduce((a, b) => a.visit.createDate.isBefore(b.visit.createDate) ? a : b);
            oldestVisits.add(oldestVisit);
          });

          return oldestVisits;
        });
  }

  Stream<List<CaseFull>> watchCasesByDateAndLocation(int start, int end,
      String countryId, String regionId, String locationId, String provinceId,
      String pointType, String pointId) {
    final emptyPoint = Point.getEmptyPoint();
    final emptyChild = Child.getEmptyChild();

    return CombineLatestStream.combine3(
        watchCasesByDate(start, end),
        watchChilds(),
        watchPointsByLocationAndPoint(countryId: countryId, regionId: regionId,
            locationId: locationId, provinceId: provinceId, pointType: pointType,
            pointId: pointId),
            (List<Case> cases, List<Child> childs, List<Point> points) {
          var casesList = cases.map((myCase) {
            final Map<String, Child> childMap = Map.fromEntries(
              childs.map((child) => MapEntry(child.childId, child)),
            );
            final child = childMap[myCase.childId] ?? emptyChild;
            final Map<String, Point> pointMap = Map.fromEntries(
              points.map((point) => MapEntry(point.pointId, point)),
            );
            final point = pointMap[myCase.pointId] ?? emptyPoint;
            return CaseFull(myCase, point, child);
          }).where((item) =>
          item.point != emptyPoint
          ).toList();

          return casesList;
        });
  }

  Stream<List<CaseFull>> watchOpenCasesByLocationBeforeDate(int start, String countryId,
      String regionId, String locationId, String provinceId, String pointType, String pointId) {
    final emptyPoint = Point.getEmptyPoint();
    final emptyChild = Child.getEmptyChild();

    return CombineLatestStream.combine3(
        _watchOpenCasesBeforeDate(start),
        watchChilds(),
        watchPointsByLocationAndPoint(countryId: countryId, regionId: regionId,
            locationId: locationId, provinceId: provinceId, pointType: pointType,
            pointId: pointId),
            (List<Case> cases, List<Child> childs, List<Point> points) {
          var casesList = cases.map((myCase) {
            final Map<String, Child> childMap = Map.fromEntries(
              childs.map((child) => MapEntry(child.childId, child)),
            );
            final child = childMap[myCase.childId] ?? emptyChild;
            final Map<String, Point> pointMap = Map.fromEntries(
              points.map((point) => MapEntry(point.pointId, point)),
            );
            final point = pointMap[myCase.pointId] ?? emptyPoint;
            return CaseFull(myCase, point, child);
          }).where((item) =>
          item.point != emptyPoint
          ).toList();

          return casesList;
        });
  }

  Stream<List<MainInform>> watchMainInform(int start, int end) {
    return watchContracts(start, end).map((contracts) {
      Map<String, Map<String, int>> addressCount = {};

      for (var contract in contracts) {
        String key = contract.childAddress!.toUpperCase().trim();
        addressCount.putIfAbsent(
            key,
            () => {
                  'records': 0,
                  'fefas': 0,
                  'childs': 0,
                  'childsMAS': 0,
                  'childsMAM': 0,
                  'childsPN': 0,
                  'fefasfe': 0,
                  'fefasfemas': 0,
                  'fefasfemam': 0,
                  'fefasfepn': 0,
                  'fefasfa': 0,
                  'fefasfamas': 0,
                  'fefasfamam': 0,
                  'fefasfapn': 0,
                  'fefasfea': 0,
                  'fefasfeamas': 0,
                  'fefasfeamam': 0,
                  'fefasfeapn': 0,
                });

        int currentRecord = addressCount[key]!['records']!;
        addressCount[key]!['records'] = currentRecord + 1;

        if (contract.code!.endsWith('-99')) {
          int currentFefas = addressCount[key]!['fefas']!;
          int currentFe = addressCount[key]!['fefasfe']!;
          int currentFeMas = addressCount[key]!['fefasfemas']!;
          int currentFeMam = addressCount[key]!['fefasfemam']!;
          int currentFePn = addressCount[key]!['fefasfepn']!;
          int currentFa = addressCount[key]!['fefasfa']!;
          int currentFaMas = addressCount[key]!['fefasfamas']!;
          int currentFaMam = addressCount[key]!['fefasfamam']!;
          int currentFaPn = addressCount[key]!['fefasfapn']!;
          int currentFea = addressCount[key]!['fefasfea']!;
          int currentFeaMas = addressCount[key]!['fefasfeamas']!;
          int currentFeaMam = addressCount[key]!['fefasfeamam']!;
          int currentFeaPn = addressCount[key]!['fefasfeapn']!;
          addressCount[key]!['fefas'] = currentFefas + 1;
          if (contract.tutorStatus != null &&
              contract.tutorStatus!.isNotEmpty &&
              (contract.tutorStatus! == 'Embarazada' ||
                  contract.tutorStatus! == 'Enceinte' ||
                  contract.tutorStatus! == 'حامل')) {
            addressCount[key]!['fefasfe'] = currentFe + 1;
            if (contract.percentage! < 50) {
              addressCount[key]!['fefasfepn'] = currentFePn + 1;
            } else if (contract.percentage! == 50) {
              addressCount[key]!['fefasfemam'] =
                  currentFeMam + 1;
            } else if (contract.percentage! > 50) {
              addressCount[key]!['fefasfemas'] = currentFeMas + 1;
            }
          } else if (contract.tutorStatus != null &&
              contract.tutorStatus!.isNotEmpty &&
              (contract.tutorStatus! == 'Lactante' ||
                  contract.tutorStatus! == 'Allaitante' ||
                  contract.tutorStatus! == ' المرضعة')) {
            addressCount[key]!['fefasfa'] = currentFa + 1;
            if (contract.percentage! < 50) {
              addressCount[key]!['fefasfapn'] = currentFaPn + 1;
            } else if (contract.percentage! == 50) {
              addressCount[key]!['fefasfamam'] =
                  currentFaMam + 1;
            } else if (contract.percentage! > 50) {
              addressCount[key]!['fefasfamas'] = currentFaMas + 1;
            }
          } else if (contract.tutorStatus != null &&
              contract.tutorStatus!.isNotEmpty &&
              (contract.tutorStatus! == 'Embarazada y lactante' ||
                  contract.tutorStatus! == 'Enceinte et allaitante' ||
                  contract.tutorStatus! == 'الحامل و المرضعة ')) {
            addressCount[key]!['fefasfea'] = currentFea + 1;
            if (contract.percentage! < 50) {
              addressCount[key]!['fefasfeapn'] = currentFeaPn + 1;
            } else if (contract.percentage! == 50) {
              addressCount[key]!['fefasfeamam'] = currentFeaMam + 1;
            } else if (contract.percentage! > 50) {
              addressCount[key]!['fefasfeamas'] = currentFeaMas + 1;
            }
          }
        } else {
          int currentChilds = addressCount[key]!['childs']!;
          int currentChildMAS = addressCount[key]!['childsMAS']!;
          int currentChildMAM = addressCount[key]!['childsMAM']!;
          int currentChildPN = addressCount[key]!['childsPN']!;
          addressCount[key]!['childs'] = currentChilds + 1;
          if (contract.percentage! < 50) {
            addressCount[key]!['childsPN'] = currentChildPN + 1;
          } else if (contract.percentage! == 50) {
            addressCount[key]!['childsMAM'] = currentChildMAM + 1;
          } else if (contract.percentage! > 50) {
            addressCount[key]!['childsMAS'] = currentChildMAS + 1;
          }
        }
      }

      List<MainInform> mainInfoList = addressCount.entries.map((entry) {
        var data = entry.value;
        return MainInform(
          place: entry.key,
          records: data['records']!,
          fefas: data['fefas']!,
          childs: data['childs']!,
          childsMAS: data['childsMAS']!,
          childsMAM: data['childsMAM']!,
          childsPN: data['childsPN']!,
          fefasfe: data['fefasfe']!,
          fefasfemas: data['fefasfemas']!,
          fefasfemam: data['fefasfemam']!,
          fefasfepn: data['fefasfepn']!,
          fefasfa: data['fefasfa']!,
          fefasfamas: data['fefasfamas']!,
          fefasfamam: data['fefasfamam']!,
          fefasfapn: data['fefasfapn']!,
          fefasfea: data['fefasfea']!,
          fefasfeamas: data['fefasfeamas']!,
          fefasfeamam: data['fefasfeamam']!,
          fefasfeapn: data['fefasfeapn']!,
        );
      }).toList();

      mainInfoList.sort((a, b) => a.place.compareTo(b.place));

      return mainInfoList;
    });
  }

  int calculateAgeInMonths(int birthdateMilliseconds) {
    DateTime birthDate = DateTime.fromMillisecondsSinceEpoch(birthdateMilliseconds);
    DateTime currentDate = DateTime.now();
    int monthDiff = (currentDate.year - birthDate.year) * 12 + currentDate.month - birthDate.month;

    if (currentDate.day < birthDate.day) {
      monthDiff--;
    }

    return monthDiff;
  }


  Stream<List<ChildInform>> watchChildInform(int start, int end) {
    return watchContracts(start, end).map((contracts) {
      Map<String, Map<String, int>> addressAndAgeCount = {};

      for (var contract in contracts) {
        for (String ageGroup in ['6 - 23 (m)', '24 - 59 (m)']) {
          String key = '${contract.childAddress!.toUpperCase().trim()}_$ageGroup';
          addressAndAgeCount.putIfAbsent(
              key,
                  () => {
                    'records': 0,
                    'male': 0,
                    'female': 0,
                    'malemas': 0,
                    'malemam': 0,
                    'malepn': 0,
                    'femalemas': 0,
                    'femalemam': 0,
                    'femalepn': 0,
              });
        }
      }

      for (var contract in contracts) {
        int ageInMonths = calculateAgeInMonths(contract.childBirthdate!.millisecondsSinceEpoch);
        String ageGroup;

        if (ageInMonths <= 2) {
          continue;
        } else if (ageInMonths <= 23) {
          ageGroup = "6 - 23 (m)";
        } else {
          ageGroup = "24 - 59 (m)";
        }

        String key = '${contract.childAddress!.toUpperCase().trim()}_$ageGroup';

        if (!contract.code!.endsWith('-99')) {
          int currentRecord = addressAndAgeCount[key]!['records']!;
          addressAndAgeCount[key]!['records'] = currentRecord + 1;
          int currentMale = addressAndAgeCount[key]!['male']!;
          int currentFemale = addressAndAgeCount[key]!['female']!;
          if (contract.sex == 'M') {
            addressAndAgeCount[key]!['male'] = currentMale + 1;
            int currentMaleMas = addressAndAgeCount[key]!['malemas']!;
            int currentMaleMam = addressAndAgeCount[key]!['malemam']!;
            int currentMalePn = addressAndAgeCount[key]!['malepn']!;
            if (contract.percentage! < 50) {
              addressAndAgeCount[key]!['malepn'] = currentMalePn + 1;
            } else if (contract.percentage! == 50) {
              addressAndAgeCount[key]!['malemam'] = currentMaleMam + 1;
            } else if (contract.percentage! > 50) {
              addressAndAgeCount[key]!['malemas'] = currentMaleMas + 1;
            }
          } else if (contract.sex == 'F') {
            addressAndAgeCount[key]!['female'] = currentFemale + 1;
            int currentFemaleMas = addressAndAgeCount[key]!['femalemas']!;
            int currentFemaleMam = addressAndAgeCount[key]!['femalemam']!;
            int currentFemalePn = addressAndAgeCount[key]!['femalepn']!;
            if (contract.percentage! < 50) {
              addressAndAgeCount[key]!['femalepn'] = currentFemalePn + 1;
            } else if (contract.percentage! == 50) {
              addressAndAgeCount[key]!['femalemam'] = currentFemaleMam + 1;
            } else if (contract.percentage! > 50) {
              addressAndAgeCount[key]!['femalemas'] = currentFemaleMas + 1;
            }
          }
        }
      }

      List<ChildInform> mainInfoList = addressAndAgeCount.entries.map((entry) {
        var data = entry.value;
        return ChildInform(
          place: entry.key.split('_')[0],
          ageGroup: entry.key.split('_')[1],
          records: data['records']!,
          male: data['male']!,
          malemas: data['malemas']!,
          malemam: data['malemam']!,
          malepn: data['malepn']!,
          female: data['female']!,
          femalemas: data['femalemas']!,
          femalemam: data['femalemam']!,
          femalepn: data['femalepn']!,
        );
      }).toList();

      mainInfoList.sort((a, b) {
        int placeComparison = a.place.compareTo(b.place);
        if (placeComparison != 0) {
          return placeComparison;
        }
        return a.ageGroup.compareTo(b.ageGroup);
      });

      return mainInfoList;
    });
  }



}

final databaseProvider = Provider<FirestoreRepository>((ref) {
  return FirestoreRepository(ref.watch(firestoreDataSourceProvider));
});


final mainInformMauritane2024StreamProvider = StreamProvider.family.autoDispose<List<MainInform>, Tuple2<int, int>>((ref, rangeDate) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw AssertionError('User can\'t be null');
  }

  final database = ref.watch(databaseProvider);
  final start = rangeDate.value1;
  final end = rangeDate.value2;

  return database.watchMainInform(start, end);
});

final childInformMauritane2024StreamProvider = StreamProvider.family.autoDispose<List<ChildInform>, Tuple2<int, int>>((ref, range) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw AssertionError('User can\'t be null');
  }

  final database = ref.watch(databaseProvider);
  final start = range.value1;
  final end = range.value2;

  return database.watchChildInform(start,end);
});

final visitWithChildAndCommunityCrenamPoinStreamProvider = StreamProvider.family.autoDispose<List<VisitWithChildAndPoint>, Tuple4<int, int, String, String>>((ref, range) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw AssertionError('User can\'t be null');
  }

  final database = ref.watch(databaseProvider);
  final start = range.value1;
  final end = range.value2;
  final countryId = range.value3;
  final regionId = range.value4;

  return database.watchVisitWithChildAndCommunityCrenamPoint(start, end, countryId, regionId);
});

final casesByDateAndLocationStreamProvider = StreamProvider.family.autoDispose<List<CaseFull>,
    Tuple8<int, int, String, String, String, String, String, String>>((ref, range) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw AssertionError('User can\'t be null');
  }

  final database = ref.watch(databaseProvider);
  final start = range.value1;
  final end = range.value2;
  final countryId = range.value3;
  final regionId = range.value4;
  final locationId = range.value5;
  final provinceId = range.value6;
  final pointType = range.value7;
  final pointId = range.value8;

  return database.watchCasesByDateAndLocation(start, end, countryId, regionId, locationId, provinceId, pointType, pointId);
});

final openCasesBeforeStartDateStreamProvider = StreamProvider.family.autoDispose<List<CaseFull>,
    Tuple7<int, String, String, String, String, String, String>>((ref, range) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw AssertionError('User can\'t be null');
  }

  final database = ref.watch(databaseProvider);
  final start = range.value1;
  final countryId = range.value2;
  final regionId = range.value3;
  final locationId = range.value4;
  final provinceId = range.value5;
  final pointType = range.value6;
  final pointId = range.value7;

  return database.watchOpenCasesByLocationBeforeDate(start, countryId, regionId, locationId, provinceId, pointType, pointId);
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

final regionsByCountryStreamProvider = StreamProvider.family.autoDispose<List<Region>, String>((ref, countryId) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw AssertionError('User can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchRegionsByCountry(countryId: countryId);
});

final locationsByCountryAndRegionStreamProvider = StreamProvider.family.autoDispose<List<Location>, Tuple2<String, String>>((ref, locationFilter) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw AssertionError('User can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  final countryId = locationFilter.value1;
  final regionId = locationFilter.value2;

  return database.watchLocationsByCountryAndRegion(countryId: countryId, regionId: regionId);
});

final provincesByLocationStreamProvider = StreamProvider.family.autoDispose<List<Province>, Tuple3<String, String, String>>((ref, provinceFilter) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw AssertionError('User can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  final countryId = provinceFilter.value1;
  final regionId = provinceFilter.value2;
  final locationId = provinceFilter.value3;

  return database.watchProvincesByLocation(countryId: countryId, regionId: regionId, locationId: locationId);
});

final pointsByLocationStreamProvider = StreamProvider.family.autoDispose<List<Point>, Tuple5<String, String, String, String, String>>((ref, pointFilter) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw AssertionError('User can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  final countryId = pointFilter.value1;
  final regionId = pointFilter.value2;
  final locationId = pointFilter.value3;
  final provinceId = pointFilter.value4;
  final pointType = pointFilter.value5;

  return database.watchPointsByLocation(countryId: countryId, regionId: regionId, locationId: locationId, provinceId: provinceId, pointType: pointType);
});









