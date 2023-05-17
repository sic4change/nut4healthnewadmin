import 'dart:async';

import 'package:adminnut4health/src/features/points/domain/point.dart';
import 'package:adminnut4health/src/features/tutors/domain/tutor.dart';
import 'package:adminnut4health/src/features/tutors/domain/tutorWithPoint.dart';
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
            try {
              final Point point = pointMap[tutor.pointId]!;
              return TutorWithPoint(tutor, point);
            } catch (e) {
                return TutorWithPoint(
                    tutor,
                    const Point(
                      pointId: "",
                      name: "",
                      fullName: "",
                      country: "",
                      active: false,
                      province: "",
                      phoneCode: "",
                      phoneLength: 0,
                      latitude: 0.0,
                      longitude: 0.0,
                      cases: 0,
                      casesnormopeso: 0,
                      casesmoderada: 0,
                      casessevera: 0,
                      transactionHash: "",
                    ));
          }}).toList();
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

final tutorStreamProvider =
    StreamProvider.autoDispose.family<Tutor, TutorID>((ref, tutorId) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw AssertionError('User can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchTutor(tutorId: tutorId);
});

