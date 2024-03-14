import 'dart:async';

import 'package:adminnut4health/src/features/childs/domain/child.dart';
import 'package:adminnut4health/src/features/cases/domain/case.dart';
import 'package:adminnut4health/src/features/cases/domain/caseWithPointChildAndTutor.dart';
import 'package:adminnut4health/src/features/users/domain/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../authentication/data/firebase_auth_repository.dart';
import '../../../common_data/firestore_data_source.dart';
import '../../points/domain/point.dart';
import '../../tutors/domain/tutor.dart';

import 'package:rxdart/rxdart.dart';

String documentIdFromCurrentDate() {
  final iso = DateTime.now().toIso8601String();
  return iso.replaceAll(':', '-').replaceAll('.', '-');
}

class FirestorePath {
  static String myCase(String uid) => 'cases/$uid';
  static String myCases() => 'cases';
  static String point(String uid) => 'points/$uid';
  static String points() => 'points';
  static String child(String uid) => 'childs/$uid';
  static String childs() => 'childs';
  static String tutor(String uid) => 'tutors/$uid';
  static String tutors() => 'tutors';
}

class FirestoreRepository {
  const FirestoreRepository(this._dataSource);
  final FirestoreDataSource _dataSource;

  Future<void> setCase({required Case myCase}) =>
      _dataSource.setData(
        path: FirestorePath.myCases(),
        data: myCase.toMap(),
      );

  Future<void> deleteCase({required Case myCase}) async {
    await _dataSource.deleteData(path: FirestorePath.myCase(myCase.caseId));
  }

  Future<void> updateCase({required Case myCase}) async {
    await _dataSource.updateData(path: FirestorePath.myCase(myCase.caseId), data: myCase.toMap());
  }

  Future<void> addCase({required Case myCase}) async {
    await _dataSource.addData(path: FirestorePath.myCases(), data: myCase.toMap());
  }

  Stream<Case> watchCase({required CaseID myCaseId}) =>
      _dataSource.watchDocument(
        path: FirestorePath.myCase(myCaseId),
        builder: (data, documentId) => Case.fromMap(data, documentId),
      );

  Stream<List<Case>> watchCases() =>
      _dataSource.watchCollection(
        path: FirestorePath.myCases(),
        builder: (data, documentId) => Case.fromMap(data, documentId),
        queryBuilder: (query) {
          if (User.currentRole != 'super-admin' && User.currentRole != 'donante') {
            query = query.where('chefValidation', isEqualTo: true).where('regionalValidation', isEqualTo: true);
          }
          return query;
        },
      );

  Stream<List<Case>> watchCasesByPoints(List<String> pointsIds) =>
      _dataSource.watchCollection(
        path: FirestorePath.myCases(),
        builder: (data, documentId) => Case.fromMap(data, documentId),
        queryBuilder: (query) {
          query = query.where('point', whereIn: pointsIds);
          if (User.currentRole == 'direccion-regional-salud') {
            query = query.where('chefValidation', isEqualTo: true);
          }
          return query;
        },
      );

  Stream<List<Point>> watchPoints() =>
      _dataSource.watchCollection(
        path: FirestorePath.points(),
        builder: (data, documentId) => Point.fromMap(data, documentId),
      );

  Stream<List<Point>> watchPointsByRegion() {
    Stream<List<Point>> points =  _dataSource.watchCollection(
      path: FirestorePath.points(),
      builder: (data, documentId) => Point.fromMap(data, documentId),
      queryBuilder: (query) => query.where('regionId', isEqualTo: User.currentRegionId),
      sort: (a, b) => a.name.compareTo(b.name),
    );
    return points;
  }

  Stream<List<Point>> watchPointsByProvince() {
    Stream<List<Point>> points =  _dataSource.watchCollection(
      path: FirestorePath.points(),
      builder: (data, documentId) => Point.fromMap(data, documentId),
      queryBuilder: (query) => query.where('province', isEqualTo: User.currentProvinceId),
      sort: (a, b) => a.name.compareTo(b.name),
    );
    return points;
  }

  Stream<List<Child>> watchChilds() =>
      _dataSource.watchCollection(
        path: FirestorePath.childs(),
        builder: (data, documentId) => Child.fromMap(data, documentId),
      );

  Stream<List<Tutor>> watchTutors() =>
      _dataSource.watchCollection(
        path: FirestorePath.tutors(),
        builder: (data, documentId) => Tutor.fromMap(data, documentId),
      );

  Stream<List<CaseWithPointChildAndTutor>> watchCasesWithPointChildAndTutor() {
    return CombineLatestStream.combine4(
      watchCases(),
      watchPoints(),
      watchChilds(),
      watchTutors(),
          (List<Case> myCases, List<Point> points, List<Child> childs, List<Tutor> tutors) {
            final Map<String, Point> pointMap = Map.fromEntries(
              points.map((point) => MapEntry(point.pointId, point)),
            );

            final Map<String, Child> childMap = Map.fromEntries(
              childs.map((child) => MapEntry(child.childId, child)),
            );

            final Map<String, Tutor> tutorMap = Map.fromEntries(
              tutors.map((tutor) => MapEntry(tutor.tutorId, tutor)),
            );

            return myCases.map((myCase) {
                final point = pointMap[myCase.pointId] ?? const Point(
                    pointId: "",
                    name: "",
                    pointName: "",
                    pointCode: "",
                    fullName: "",
                    type: "",
                    active: false,
                    country: "",
                    regionId: '',
                    location: "",
                    province: "",
                    phoneCode: "",
                    phoneLength: 0,
                    latitude: 0.0,
                    longitude: 0.0,
                    language: "",
                    cases: 0,
                    casesnormopeso: 0,
                    casesmoderada: 0,
                    casessevera: 0,
                    transactionHash: "",
                );

                final child = childMap[myCase.childId] ?? Child(
                  childId: "",
                  tutorId: "",
                  pointId: "",
                  name: "",
                  surnames: "",
                  birthdate: DateTime.now(),
                  code : "",
                  createDate: DateTime.now(),
                  lastDate: DateTime.now(),
                  ethnicity: "",
                  sex: "",
                  observations: "",
                  chefValidation: false,
                  regionalValidation: false,
                );

                final tutor = tutorMap[myCase.tutorId]?? Tutor(
                  tutorId: "",
                  pointId: "",
                  name: "",
                  surnames: "",
                  address: "",
                  phone: "",
                  birthdate: DateTime.now(),
                  createDate: DateTime.now(),
                  ethnicity: "",
                  sex: "",
                  maleRelation: "",
                  womanStatus: "",
                  babyAge: 0,
                  armCircunference: 0.0,
                  status: "",
                  weeks: 0,
                  childMinor: "",
                  observations: "",
                  active: false,
                  chefValidation: false,
                  regionalValidation: false,
                );

                return CaseWithPointChildAndTutor(myCase, point, child, tutor);
            }).toList();
          });
  }
  
  Stream<List<CaseWithPointChildAndTutor>> watchCasesFullByPoints(List<String> pointsIds) {
    return CombineLatestStream.combine4(
      watchCasesByPoints(pointsIds),
      watchPoints(),
      watchChilds(),
      watchTutors(),
          (List<Case> myCases, List<Point> points, List<Child> childs, List<Tutor> tutors) {
            final Map<String, Point> pointMap = Map.fromEntries(
              points.map((point) => MapEntry(point.pointId, point)),
            );

            final Map<String, Child> childMap = Map.fromEntries(
              childs.map((child) => MapEntry(child.childId, child)),
            );

            final Map<String, Tutor> tutorMap = Map.fromEntries(
              tutors.map((tutor) => MapEntry(tutor.tutorId, tutor)),
            );

            return myCases.map((myCase) {
                final point = pointMap[myCase.pointId] ?? const Point(
                    pointId: "",
                    name: "",
                    fullName: "",
                    pointName: "",
                    pointCode: "",
                    type: "",
                    active: false,
                    country: "",
                    regionId: '',
                    location: "",
                    province: "",
                    phoneCode: "",
                    phoneLength: 0,
                    latitude: 0.0,
                    longitude: 0.0,
                    language: "",
                    cases: 0,
                    casesnormopeso: 0,
                    casesmoderada: 0,
                    casessevera: 0,
                    transactionHash: "",
                );

                final child = childMap[myCase.childId] ?? Child(
                  childId: "",
                  tutorId: "",
                  pointId: "",
                  name: "",
                  surnames: "",
                  birthdate: DateTime.now(),
                  code : "",
                  createDate: DateTime.now(),
                  lastDate: DateTime.now(),
                  ethnicity: "",
                  sex: "",
                  observations: "",
                  chefValidation: false,
                  regionalValidation: false,
                );

                final tutor = tutorMap[myCase.tutorId]?? Tutor(
                  tutorId: "",
                  pointId: "",
                  name: "",
                  surnames: "",
                  address: "",
                  phone: "",
                  birthdate: DateTime.now(),
                  createDate: DateTime.now(),
                  ethnicity: "",
                  sex: "",
                  maleRelation: "",
                  womanStatus: "",
                  babyAge: 0,
                  armCircunference: 0.0,
                  status: "",
                  weeks: 0,
                  childMinor: "",
                  observations: "",
                  active: false,
                  chefValidation: false,
                  regionalValidation: false,
                );

                return CaseWithPointChildAndTutor(myCase, point, child, tutor);
            }).toList();
          });
  }

  Future<Case> fetchCase({required CaseID myCaseId}) =>
      _dataSource.fetchDocument(
        path: FirestorePath.myCase(myCaseId),
        builder: (data, documentId) => Case.fromMap(data, documentId),
      );

  Future<List<Case>> fetchCases() =>
      _dataSource.fetchCollection(
        path: FirestorePath.myCases(),
        builder: (data, documentId) => Case.fromMap(data, documentId),
      );

}

final databaseProvider = Provider<FirestoreRepository>((ref) {
  return FirestoreRepository(ref.watch(firestoreDataSourceProvider));
});

final casesStreamProvider = StreamProvider.autoDispose<List<CaseWithPointChildAndTutor>>((ref) {
  final myCase = ref.watch(authStateChangesProvider).value;
  if (myCase == null) {
    throw AssertionError('Case can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchCasesWithPointChildAndTutor();
});

final casesByPointsStreamProvider = StreamProvider.autoDispose.family<List<CaseWithPointChildAndTutor>, List<String>>((ref, pointsIds) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw AssertionError('User can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchCasesFullByPoints(pointsIds);
});

final tutorsStreamProvider = StreamProvider.autoDispose<List<Tutor>>((ref) {
  final myCase = ref.watch(authStateChangesProvider).value;
  if (myCase == null) {
    throw AssertionError('Case can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchTutors();
});

final pointsStreamProvider = StreamProvider.autoDispose<List<Point>>((ref) {
  final myCase = ref.watch(authStateChangesProvider).value;
  if (myCase == null) {
    throw AssertionError('Case can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchPoints();
});

final pointsByRegionStreamProvider = StreamProvider.autoDispose<List<Point>>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw AssertionError('User can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchPointsByRegion();
});

final pointsByProvinceStreamProvider = StreamProvider.autoDispose<List<Point>>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw AssertionError('User can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchPointsByProvince();
});

final caseStreamProvider =
    StreamProvider.autoDispose.family<Case, CaseID>((ref, myCaseId) {
  final myCase = ref.watch(authStateChangesProvider).value;
  if (myCase == null) {
    throw AssertionError('Case can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchCase(myCaseId: myCaseId);
});

