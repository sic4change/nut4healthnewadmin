import 'dart:async';

import 'package:adminnut4health/src/features/points/domain/point.dart';
import 'package:adminnut4health/src/features/tutors/domain/tutor.dart';
import 'package:adminnut4health/src/features/tutors/domain/tutorWithPoint.dart';
import 'package:adminnut4health/src/features/users/domain/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';

import '../../authentication/data/firebase_auth_repository.dart';
import '../../../common_data/firestore_data_source.dart';

String documentIdFromCurrentDate() {
  final iso = DateTime.now().toIso8601String();
  return iso.replaceAll(':', '-').replaceAll('.', '-');
}

class FirestorePath {
  static String point(String uid) => 'points/$uid';
  static String points() => 'points';
  static String tutor(String uid) => 'tutors/$uid';
  static String tutors() => 'tutors';
}

class FirestoreRepository {
  const FirestoreRepository(this._dataSource);
  final FirestoreDataSource _dataSource;

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

  Future<void> setTutor({required Tutor tutor}) =>
      _dataSource.setData(
        path: FirestorePath.tutors(),
        data: tutor.toMap(),
      );

  Future<void> deleteTutor({required Tutor tutor}) async {
    await _dataSource.deleteData(path: FirestorePath.tutor(tutor.tutorId));
  }

  Future<void> updateTutor({required Tutor tutor}) async {
    await _dataSource.updateData(path: FirestorePath.tutor(tutor.tutorId), data: tutor.toMap());
  }

  Future<void> addTutor({required Tutor tutor}) async {
    await _dataSource.addData(path: FirestorePath.tutors(), data: tutor.toMap());
  }

  Stream<Tutor> watchTutor({required TutorID tutorId}) =>
      _dataSource.watchDocument(
        path: FirestorePath.tutor(tutorId),
        builder: (data, documentId) => Tutor.fromMap(data, documentId),
      );

  Stream<List<Tutor>> watchTutors() =>
      _dataSource.watchCollection(
        path: FirestorePath.tutors(),
        builder: (data, documentId) => Tutor.fromMap(data, documentId),
        queryBuilder: (query) {
          if (User.currentRole != 'super-admin') {
            query = query.where('chefValidation', isEqualTo: true).where('regionalValidation', isEqualTo: true);
          }
          return query;
        },
      );

  Stream<List<Tutor>> watchTutorsByPoints(List<String> pointsIds) =>
      _dataSource.watchCollection(
        path: FirestorePath.tutors(),
        builder: (data, documentId) => Tutor.fromMap(data, documentId),
        queryBuilder: (query) {
          query = query.where('point', whereIn: pointsIds);
          if (User.currentRole == 'direccion-regional-salud') {
            query = query.where('chefValidation', isEqualTo: true);
          }
          return query;
        },
    );

  Stream<List<TutorWithPoint>> watchTutorsWithPoints() {
    return CombineLatestStream.combine2(
        watchTutors(),
        watchPoints(),
            (List<Tutor> tutors, List<Point> points,) {
          final Map<String, Point> pointMap = Map.fromEntries(
            points.map((point) => MapEntry(point.pointId, point)),
          );
          return tutors.map((tutor) {
              final Point point = pointMap[tutor.pointId] ??
                  const Point(pointId: "", name: "", fullName: "", type: "",
                    country: "", regionId: '', active: false, province: "",  phoneCode: "",
                    phoneLength: 0, latitude: 0.0, longitude: 0.0, language: "",
                    cases: 0, casesnormopeso: 0, casesmoderada: 0, casessevera: 0,
                    transactionHash: "");
              return TutorWithPoint(tutor, point);
            }).toList();
        });
  }

  Stream<List<TutorWithPoint>> watchTutorsFullByPoints(List<String> pointsIds) {
    return CombineLatestStream.combine2(
        watchTutorsByPoints(pointsIds),
        watchPoints(),
            (List<Tutor> tutors, List<Point> points,) {
          final Map<String, Point> pointMap = Map.fromEntries(
            points.map((point) => MapEntry(point.pointId, point)),
          );
          return tutors.map((tutor) {
              final Point point = pointMap[tutor.pointId] ??
                  const Point(pointId: "", name: "", fullName: "", type: "",
                    country: "", regionId: '', active: false, province: "",  phoneCode: "",
                    phoneLength: 0, latitude: 0.0, longitude: 0.0, language: "",
                    cases: 0, casesnormopeso: 0, casesmoderada: 0, casessevera: 0,
                    transactionHash: "");
              return TutorWithPoint(tutor, point);
            }).toList();
        });
  }

  Future<Tutor> fetchTutor({required TutorID tutorId}) =>
      _dataSource.fetchDocument(
        path: FirestorePath.tutor(tutorId),
        builder: (data, documentId) => Tutor.fromMap(data, documentId),
      );

  Future<List<Tutor>> fetchTutors() =>
      _dataSource.fetchCollection(
        path: FirestorePath.tutors(),
        builder: (data, documentId) => Tutor.fromMap(data, documentId),
      );

}

final databaseProvider = Provider<FirestoreRepository>((ref) {
  return FirestoreRepository(ref.watch(firestoreDataSourceProvider));
});

final tutorsStreamProvider = StreamProvider.autoDispose<List<TutorWithPoint>>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw AssertionError('User can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchTutorsWithPoints();
});

final tutorsByPointsStreamProvider = StreamProvider.autoDispose.family<List<TutorWithPoint>, List<String>>((ref, pointsIds) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw AssertionError('User can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchTutorsFullByPoints(pointsIds);
});

final tutorStreamProvider =
    StreamProvider.autoDispose.family<Tutor, TutorID>((ref, tutorId) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw AssertionError('User can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchTutor(tutorId: tutorId);
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

