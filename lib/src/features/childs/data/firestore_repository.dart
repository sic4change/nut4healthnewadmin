import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../authentication/data/firebase_auth_repository.dart';
import '../../../common_data/firestore_data_source.dart';
import '../../points/domain/point.dart';
import '../../tutors/domain/tutor.dart';
import '../domain/childWithPointAndTutor.dart';
import '../domain/child.dart';

import 'package:rxdart/rxdart.dart';

String documentIdFromCurrentDate() {
  final iso = DateTime.now().toIso8601String();
  return iso.replaceAll(':', '-').replaceAll('.', '-');
}

class FirestorePath {
  static String child(String uid) => 'childs/$uid';
  static String childs() => 'childs';
  static String point(String uid) => 'points/$uid';
  static String points() => 'points';
  static String tutor(String uid) => 'tutors/$uid';
  static String tutors() => 'tutors';
}

class FirestoreRepository {
  const FirestoreRepository(this._dataSource);
  final FirestoreDataSource _dataSource;

  Future<void> setChild({required Child child}) =>
      _dataSource.setData(
        path: FirestorePath.childs(),
        data: child.toMap(),
      );

  Future<void> deleteChild({required Child child}) async {
    await _dataSource.deleteData(path: FirestorePath.child(child.childId));
  }

  Future<void> updateChild({required Child child}) async {
    await _dataSource.updateData(path: FirestorePath.child(child.childId), data: child.toMap());
  }

  Future<void> addChild({required Child child}) async {
    await _dataSource.addData(path: FirestorePath.childs(), data: child.toMap());
  }

  Stream<Child> watchChild({required ChildID childId}) =>
      _dataSource.watchDocument(
        path: FirestorePath.child(childId),
        builder: (data, documentId) => Child.fromMap(data, documentId),
      );

  Stream<List<Child>> watchChilds() =>
      _dataSource.watchCollection(
        path: FirestorePath.childs(),
        builder: (data, documentId) => Child.fromMap(data, documentId),
      );

  Stream<List<Point>> watchPoints() =>
      _dataSource.watchCollection(
        path: FirestorePath.points(),
        builder: (data, documentId) => Point.fromMap(data, documentId),
      );

  Stream<List<Tutor>> watchTutors() =>
      _dataSource.watchCollection(
        path: FirestorePath.tutors(),
        builder: (data, documentId) => Tutor.fromMap(data, documentId),
      );

  Stream<List<ChildWithPointAndTutor>> watchChildsWithPoints() {
    return CombineLatestStream.combine3(
      watchChilds(),
      watchPoints(),
      watchTutors(),
          (List<Child> childs, List<Point> points, List<Tutor> tutors) {
            final Map<String, Point> pointMap = Map.fromEntries(
              points.map((point) => MapEntry(point.pointId, point)),
            );

            final Map<String, Tutor> tutorMap = Map.fromEntries(
              tutors.map((tutor) => MapEntry(tutor.tutorId, tutor)),
            );

            return childs.map((child) {
              try {
                final Point point = pointMap[child.pointId]!;
                final Tutor tutor = tutorMap[child.tutorId]!;
                return ChildWithPointAndTutor(child, point, tutor);
              } catch (e) {
                try {
                  final Tutor tutor = tutorMap[child.tutorId]!;
                  return ChildWithPointAndTutor(
                      child,
                      const Point(
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
                          casessevera: 0),
                      tutor);
                } catch (e) {
                  try {
                    final Point point = pointMap[child.pointId]!;
                    return ChildWithPointAndTutor(
                        child,
                        point,
                        Tutor(
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
                        ));
            } catch (e) {
                    return ChildWithPointAndTutor(
                        child,
                        const Point(
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
                            casessevera: 0),
                        Tutor(
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
                        ));
            }
                }
              }
            }).toList();
          });
  }

  Future<Child> fetchChild({required ChildID childId}) =>
      _dataSource.fetchDocument(
        path: FirestorePath.child(childId),
        builder: (data, documentId) => Child.fromMap(data, documentId),
      );

  Future<List<Child>> fetchChilds() =>
      _dataSource.fetchCollection(
        path: FirestorePath.childs(),
        builder: (data, documentId) => Child.fromMap(data, documentId),
      );

}

final databaseProvider = Provider<FirestoreRepository>((ref) {
  return FirestoreRepository(ref.watch(firestoreDataSourceProvider));
});

final childsStreamProvider = StreamProvider.autoDispose<List<ChildWithPointAndTutor>>((ref) {
  final child = ref.watch(authStateChangesProvider).value;
  if (child == null) {
    throw AssertionError('Child can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchChildsWithPoints();
});

final tutorsStreamProvider = StreamProvider.autoDispose<List<Tutor>>((ref) {
  final child = ref.watch(authStateChangesProvider).value;
  if (child == null) {
    throw AssertionError('Child can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchTutors();
});

final pointsStreamProvider = StreamProvider.autoDispose<List<Point>>((ref) {
  final child = ref.watch(authStateChangesProvider).value;
  if (child == null) {
    throw AssertionError('Child can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchPoints();
});

final childStreamProvider =
    StreamProvider.autoDispose.family<Child, ChildID>((ref, childId) {
  final child = ref.watch(authStateChangesProvider).value;
  if (child == null) {
    throw AssertionError('Child can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchChild(childId: childId);
});

