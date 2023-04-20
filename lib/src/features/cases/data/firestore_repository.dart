import 'dart:async';

import 'package:adminnut4health/src/features/childs/domain/child.dart';
import 'package:adminnut4health/src/features/cases/domain/case.dart';
import 'package:adminnut4health/src/features/cases/domain/caseWithPointChildAndTutor.dart';
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
                    fullName: "",
                    active: false,
                    country: "",
                    province: "",
                    phoneCode: "",
                    latitude: 0.0,
                    longitude: 0.0,
                    cases: 0,
                    casesnormopeso: 0,
                    casesmoderada: 0,
                    casessevera: 0);

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
                  weight: 0.0,
                  height: 0.0,
                  status: "",
                  pregnant: "",
                  weeks: 0,
                  childMinor: "",
                  observations: "",
                  active: false,
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

final caseStreamProvider =
    StreamProvider.autoDispose.family<Case, CaseID>((ref, myCaseId) {
  final myCase = ref.watch(authStateChangesProvider).value;
  if (myCase == null) {
    throw AssertionError('Case can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchCase(myCaseId: myCaseId);
});

