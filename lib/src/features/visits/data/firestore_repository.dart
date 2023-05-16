import 'dart:async';

import 'package:adminnut4health/src/features/childs/domain/child.dart';
import 'package:adminnut4health/src/features/cases/domain/case.dart';
import 'package:adminnut4health/src/features/cases/domain/caseWithPointChildAndTutor.dart';
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
    await _dataSource.deleteData(path: FirestorePath.visit(visit.caseId));
  }

  Future<void> updateVisit({required Visit visit}) async {
    await _dataSource.updateData(path: FirestorePath.visit(visit.caseId), data: visit.toMap());
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
      );

  Stream<List<Point>> watchPoints() =>
      _dataSource.watchCollection(
        path: FirestorePath.points(),
        builder: (data, documentId) => Point.fromMap(data, documentId),
      );

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
                    active: false,
                    country: "",
                    province: "",
                    phoneCode: "",
                    phoneLength: 0,
                    latitude: 0.0,
                    longitude: 0.0,
                    cases: 0,
                    casesnormopeso: 0,
                    casesmoderada: 0,
                    casessevera: 0);

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

