import 'dart:async';

import 'package:adminnut4health/src/features/childs/domain/child.dart';
import 'package:adminnut4health/src/features/cases/domain/case.dart';
import 'package:adminnut4health/src/features/users/domain/user.dart';
import 'package:adminnut4health/src/features/visits/domain/visit.dart';
import 'package:adminnut4health/src/features/visits/domain/visitCombined.dart';
import 'package:adminnut4health/src/features/visitsWithoutDiagnosis/domain/visitWithoutDiagnosis.dart';
import 'package:adminnut4health/src/features/visitsWithoutDiagnosis/domain/visitWithoutDiagnosisCombined.dart';
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
  static String visitWithoutDiagnosis(String uid) => 'visitsWithoutDiagnosis/$uid';
  static String visitsWithoutDiagnosis() => 'visitsWithoutDiagnosis';
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

  Future<void> setVisitWithoutDiagnosis({required VisitWithoutDiagnosis visit}) =>
      _dataSource.setData(
        path: FirestorePath.visitsWithoutDiagnosis(),
        data: visit.toMap(),
      );

  Future<void> deleteVisitWithoutDiagnosis({required VisitWithoutDiagnosis visit}) async {
    await _dataSource.deleteData(path: FirestorePath.visitWithoutDiagnosis(visit.id));
  }

  Future<void> updateVisitWithoutDiagnosis({required VisitWithoutDiagnosis visit}) async {
    await _dataSource.updateData(path: FirestorePath.visitWithoutDiagnosis(visit.id), data: visit.toMap());
  }

  Future<void> addVisitWithoutDiagnosis({required VisitWithoutDiagnosis visit}) async {
    await _dataSource.addData(path: FirestorePath.visitsWithoutDiagnosis(), data: visit.toMap());
  }

  Stream<VisitWithoutDiagnosis> watchVisitWithoutDiagnosis({required String visitId}) =>
      _dataSource.watchDocument(
        path: FirestorePath.visitWithoutDiagnosis(visitId),
        builder: (data, documentId) => VisitWithoutDiagnosis.fromMap(data, documentId),
      );

  Stream<List<VisitWithoutDiagnosis>> watchVisitsWithoutDiagnosis() =>
      _dataSource.watchCollection(
        path: FirestorePath.visitsWithoutDiagnosis(),
        builder: (data, documentId) => VisitWithoutDiagnosis.fromMap(data, documentId),
        queryBuilder: (query) {
          if (User.currentRole != 'super-admin' && User.currentRole != 'donante') {
            query = query.where('chefValidation', isEqualTo: true).where('regionalValidation', isEqualTo: true);
          }
          return query;
        },
      );

  Stream<List<VisitWithoutDiagnosis>> watchVisitsWithoutDiagnosisByPoints(List<String> pointsIds) =>
      _dataSource.watchCollection(
        path: FirestorePath.visitsWithoutDiagnosis(),
        builder: (data, documentId) => VisitWithoutDiagnosis.fromMap(data, documentId),
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

  Stream<List<VisitWithoutDiagnosisCombined>> watchVisitWithoutDiagnosissWithPointChildAndTutor() {
    return CombineLatestStream.combine4(
        watchVisitsWithoutDiagnosis(),
        watchPoints(),
        watchChilds(),
        watchTutors(),
            (List<VisitWithoutDiagnosis> visits,
            List<Point> points,
            List<Child> childs,
            List<Tutor> tutors) {
          final Map<String, Point> pointMap = Map.fromEntries(
            points.map((point) => MapEntry(point.pointId, point)),
          );

          final Map<String, Child> childMap = Map.fromEntries(
            childs.map((child) => MapEntry(child.childId, child)),
          );

          final Map<String, Tutor> tutorMap = Map.fromEntries(
            tutors.map((tutor) => MapEntry(tutor.tutorId, tutor)),
          );

          return visits.map((visit) {
            final point = pointMap[visit.pointId] ?? Point.getEmptyPoint();

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

            return VisitWithoutDiagnosisCombined(visit, point, child, tutor);
          }).toList();
        });
  }

  Stream<List<VisitWithoutDiagnosisCombined>> watchVisitsWithoutDiagnosisFullByPoints(List<String> pointsIds) {
    return CombineLatestStream.combine4(
        watchVisitsWithoutDiagnosisByPoints(pointsIds),
        watchPoints(),
        watchChilds(),
        watchTutors(),
            (List<VisitWithoutDiagnosis> visits,
            List<Point> points,
            List<Child> childs,
            List<Tutor> tutors) {
          final Map<String, Point> pointMap = Map.fromEntries(
            points.map((point) => MapEntry(point.pointId, point)),
          );

          final Map<String, Child> childMap = Map.fromEntries(
            childs.map((child) => MapEntry(child.childId, child)),
          );

          final Map<String, Tutor> tutorMap = Map.fromEntries(
            tutors.map((tutor) => MapEntry(tutor.tutorId, tutor)),
          );

          return visits.map((visit) {
            final point = pointMap[visit.pointId] ?? Point.getEmptyPoint();

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

            return VisitWithoutDiagnosisCombined(visit, point, child, tutor);
          }).toList();
        });
  }

  Future<VisitWithoutDiagnosis> fetchVisitWithoutDiagnosis({required String visitId}) =>
      _dataSource.fetchDocument(
        path: FirestorePath.visitWithoutDiagnosis(visitId),
        builder: (data, documentId) => VisitWithoutDiagnosis.fromMap(data, documentId),
      );

  Future<List<VisitWithoutDiagnosis>> fetchVisitsWithoutDiagnosis() =>
      _dataSource.fetchCollection(
        path: FirestorePath.visitsWithoutDiagnosis(),
        builder: (data, documentId) => VisitWithoutDiagnosis.fromMap(data, documentId),
      );

}

final databaseProvider = Provider<FirestoreRepository>((ref) {
  return FirestoreRepository(ref.watch(firestoreDataSourceProvider));
});

final visitsWithoutDiagnosisStreamProvider = StreamProvider.autoDispose<List<VisitWithoutDiagnosisCombined>>((ref) {
  final visit = ref.watch(authStateChangesProvider).value;
  if (visit == null) {
    throw AssertionError('VisitWithoutDiagnosis can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchVisitWithoutDiagnosissWithPointChildAndTutor();
});

final visitsWithoutDiagnosisByPointsStreamProvider = StreamProvider.autoDispose.family<List<VisitWithoutDiagnosisCombined>, List<String>>((ref, pointsIds) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw AssertionError('User can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchVisitsWithoutDiagnosisFullByPoints(pointsIds);
});

final tutorsStreamProvider = StreamProvider.autoDispose<List<Tutor>>((ref) {
  final visit = ref.watch(authStateChangesProvider).value;
  if (visit == null) {
    throw AssertionError('VisitWithoutDiagnosis can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchTutors();
});

final pointsStreamProvider = StreamProvider.autoDispose<List<Point>>((ref) {
  final visit = ref.watch(authStateChangesProvider).value;
  if (visit == null) {
    throw AssertionError('VisitWithoutDiagnosis can\'t be null');
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

final visitWithoutDiagnosisStreamProvider =
StreamProvider.autoDispose.family<VisitWithoutDiagnosis, String>((ref, visitId) {
  final visit = ref.watch(authStateChangesProvider).value;
  if (visit == null) {
    throw AssertionError('VisitWithoutDiagnosis can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchVisitWithoutDiagnosis(visitId: visitId);
});

