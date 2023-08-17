import 'dart:async';

import 'package:adminnut4health/src/features/childs/domain/child.dart';
import 'package:adminnut4health/src/features/cases/domain/case.dart';
import 'package:adminnut4health/src/features/cases/domain/caseWithPointChildAndTutor.dart';
import 'package:adminnut4health/src/features/users/domain/user.dart';
import 'package:adminnut4health/src/features/visits/domain/visit.dart';
import 'package:adminnut4health/src/features/visits/domain/visitCombined.dart';
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
  static String visit(String uid) => 'visits/$uid';
  static String visits() => 'visits';
  static String point(String uid) => 'points/$uid';
  static String points() => 'points';
  static String child(String uid) => 'childs/$uid';
  static String childs() => 'childs';
  static String tutor(String uid) => 'tutors/$uid';
  static String tutors() => 'tutors';
  static String myCase(String uid) => 'cases/$uid';
  static String myCases() => 'cases';
}

class FirestoreRepository {
  const FirestoreRepository(this._dataSource);
  final FirestoreDataSource _dataSource;

  Future<void> setVisit({required Visit visit}) =>
      _dataSource.setData(
        path: FirestorePath.visits(),
        data: visit.toMap(),
      );

  Future<void> deleteVisit({required Visit visit}) async {
    await _dataSource.deleteData(path: FirestorePath.visit(visit.visitId));
  }

  Future<void> updateVisit({required Visit visit}) async {
    await _dataSource.updateData(path: FirestorePath.visit(visit.visitId), data: visit.toMap());
  }

  Future<void> addVisit({required Visit visit}) async {
    await _dataSource.addData(path: FirestorePath.visits(), data: visit.toMap());
  }

  Stream<Visit> watchVisit({required VisitID visitId}) =>
      _dataSource.watchDocument(
        path: FirestorePath.visit(visitId),
        builder: (data, documentId) => Visit.fromMap(data, documentId),
      );

  Stream<List<Visit>> watchVisits() =>
      _dataSource.watchCollection(
        path: FirestorePath.visits(),
        builder: (data, documentId) => Visit.fromMap(data, documentId),
        queryBuilder: (query) {
          if (User.currentRole != 'super-admin') {
            query = query.where('chefValidation', isEqualTo: true).where('regionalValidation', isEqualTo: true);
          }
          return query;
        },
      );

  Stream<List<Visit>> watchVisitsByPoints(List<String> pointsIds) =>
      _dataSource.watchCollection(
        path: FirestorePath.visits(),
        builder: (data, documentId) => Visit.fromMap(data, documentId),
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

  Stream<List<Case>> watchCases() =>
      _dataSource.watchCollection(
        path: FirestorePath.myCases(),
        builder: (data, documentId) => Case.fromMap(data, documentId),
      );

  Stream<List<VisitCombined>> watchVisitsWithPointChildAndTutor() {
    return CombineLatestStream.combine5(
        watchVisits(),
        watchPoints(),
        watchChilds(),
        watchTutors(),
        watchCases(),
            (List<Visit> visits,
            List<Point> points,
            List<Child> childs,
            List<Tutor> tutors,
            List<Case> cases) {
            final Map<String, Point> pointMap = Map.fromEntries(
              points.map((point) => MapEntry(point.pointId, point)),
            );

            final Map<String, Child> childMap = Map.fromEntries(
              childs.map((child) => MapEntry(child.childId, child)),
            );

            final Map<String, Tutor> tutorMap = Map.fromEntries(
              tutors.map((tutor) => MapEntry(tutor.tutorId, tutor)),
            );

            final Map<String, Case> caseMap = Map.fromEntries(
              cases.map((myCase) => MapEntry(myCase.caseId, myCase)),
            );

            return visits.map((visit) {
                final point = pointMap[visit.pointId] ?? const Point(
                    pointId: "",
                    name: "",
                    fullName: "",
                    type: "",
                    active: false,
                    country: "",
                    regionId: '',
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

                final child = childMap[visit.childId] ?? Child(
                  childId: "",
                  tutorId: "",
                  pointId: "",
                  name: "",
                  surnames: "",
                  birthdate: DateTime.now(),
                  code: "",
                  createDate: DateTime.now(),
                  lastDate: DateTime.now(),
                  ethnicity: "",
                  sex: "",
                  observations: "",
                  chefValidation: false,
                  regionalValidation: false,
                );

                final tutor = tutorMap[visit.tutorId]?? Tutor(
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
                  armCircunference: 0.0,
                  status: "",
                  babyAge: 0,
                  weeks: 0,
                  childMinor: "",
                  observations: "",
                  active: false,
                  chefValidation: false,
                  regionalValidation: false,
                );

                final myCase = caseMap[visit.caseId]?? Case(
                  caseId: "",
                  pointId: "",
                  childId: "",
                  tutorId: "",
                  name: "",
                  createDate: DateTime.now(),
                  lastDate: DateTime.now(),
                  observations: "",
                  status: "",
                  visits: 0,
                  chefValidation: false,
                  regionalValidation: false,
                );

                return VisitCombined(visit, point, child, tutor, myCase);
            }).toList();
          });
  }

  Stream<List<VisitCombined>> watchVisitsFullByPoints(List<String> pointsIds) {
    return CombineLatestStream.combine5(
        watchVisitsByPoints(pointsIds),
        watchPoints(),
        watchChilds(),
        watchTutors(),
        watchCases(),
            (List<Visit> visits,
            List<Point> points,
            List<Child> childs,
            List<Tutor> tutors,
            List<Case> cases) {
            final Map<String, Point> pointMap = Map.fromEntries(
              points.map((point) => MapEntry(point.pointId, point)),
            );

            final Map<String, Child> childMap = Map.fromEntries(
              childs.map((child) => MapEntry(child.childId, child)),
            );

            final Map<String, Tutor> tutorMap = Map.fromEntries(
              tutors.map((tutor) => MapEntry(tutor.tutorId, tutor)),
            );

            final Map<String, Case> caseMap = Map.fromEntries(
              cases.map((myCase) => MapEntry(myCase.caseId, myCase)),
            );

            return visits.map((visit) {
                final point = pointMap[visit.pointId] ?? const Point(
                    pointId: "",
                    name: "",
                    fullName: "",
                    type: "",
                    active: false,
                    country: "",
                    regionId: '',
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

                final child = childMap[visit.childId] ?? Child(
                  childId: "",
                  tutorId: "",
                  pointId: "",
                  name: "",
                  surnames: "",
                  birthdate: DateTime.now(),
                  code: "",
                  createDate: DateTime.now(),
                  lastDate: DateTime.now(),
                  ethnicity: "",
                  sex: "",
                  observations: "",
                  chefValidation: false,
                  regionalValidation: false,
                );

                final tutor = tutorMap[visit.tutorId]?? Tutor(
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
                  armCircunference: 0.0,
                  status: "",
                  babyAge: 0,
                  weeks: 0,
                  childMinor: "",
                  observations: "",
                  active: false,
                  chefValidation: false,
                  regionalValidation: false,
                );

                final myCase = caseMap[visit.caseId]?? Case(
                  caseId: "",
                  pointId: "",
                  childId: "",
                  tutorId: "",
                  name: "",
                  createDate: DateTime.now(),
                  lastDate: DateTime.now(),
                  observations: "",
                  status: "",
                  visits: 0,
                  chefValidation: false,
                  regionalValidation: false,
                );

                return VisitCombined(visit, point, child, tutor, myCase);
            }).toList();
          });
  }

  Future<Visit> fetchVisit({required VisitID visitId}) =>
      _dataSource.fetchDocument(
        path: FirestorePath.visit(visitId),
        builder: (data, documentId) => Visit.fromMap(data, documentId),
      );

  Future<List<Visit>> fetchVisits() =>
      _dataSource.fetchCollection(
        path: FirestorePath.visits(),
        builder: (data, documentId) => Visit.fromMap(data, documentId),
      );

}

final databaseProvider = Provider<FirestoreRepository>((ref) {
  return FirestoreRepository(ref.watch(firestoreDataSourceProvider));
});

final visitsStreamProvider = StreamProvider.autoDispose<List<VisitCombined>>((ref) {
  final visit = ref.watch(authStateChangesProvider).value;
  if (visit == null) {
    throw AssertionError('Visit can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchVisitsWithPointChildAndTutor();
});

final visitsByPointsStreamProvider = StreamProvider.autoDispose.family<List<VisitCombined>, List<String>>((ref, pointsIds) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw AssertionError('User can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchVisitsFullByPoints(pointsIds);
});

final tutorsStreamProvider = StreamProvider.autoDispose<List<Tutor>>((ref) {
  final visit = ref.watch(authStateChangesProvider).value;
  if (visit == null) {
    throw AssertionError('Visit can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchTutors();
});

final pointsStreamProvider = StreamProvider.autoDispose<List<Point>>((ref) {
  final visit = ref.watch(authStateChangesProvider).value;
  if (visit == null) {
    throw AssertionError('Visit can\'t be null');
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

final casesStreamProvider = StreamProvider.autoDispose<List<Case>>((ref) {
  final myCase = ref.watch(authStateChangesProvider).value;
  if (myCase == null) {
    throw AssertionError('Case can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchCases();
});

final visitStreamProvider =
    StreamProvider.autoDispose.family<Visit, VisitID>((ref, visitId) {
  final visit = ref.watch(authStateChangesProvider).value;
  if (visit == null) {
    throw AssertionError('Visit can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchVisit(visitId: visitId);
});

