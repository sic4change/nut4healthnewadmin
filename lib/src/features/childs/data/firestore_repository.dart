import 'dart:async';

import 'package:adminnut4health/src/features/users/domain/user.dart';
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
        queryBuilder: (query) {
          if (User.currentRole != 'super-admin' && User.currentRole != 'donante') {
            query = query.where('chefValidation', isEqualTo: true).where('regionalValidation', isEqualTo: true);
          }
          return query;
        },
      );

  Stream<List<Child>> watchChildrenByPoints(List<String> pointsIds) =>
      _dataSource.watchCollection(
        path: FirestorePath.childs(),
        builder: (data, documentId) => Child.fromMap(data, documentId),
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
              final Point point = pointMap[child.pointId] ?? const Point(
                pointId: "",
                name: "",
                pointName: "",
                pointCode: "",
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

              final Tutor tutor = tutorMap[child.tutorId] ?? Tutor(
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

              return ChildWithPointAndTutor(child, point, tutor);
            }).toList();
          });
  }

  Stream<List<ChildWithPointAndTutor>> watchChildrenFullByPoints(List<String> pointsIds) {
    return CombineLatestStream.combine3(
      watchChildrenByPoints(pointsIds),
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
              final Point point = pointMap[child.pointId] ?? const Point(
                pointId: "",
                name: "",
                pointName: "",
                pointCode: "",
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

              final Tutor tutor = tutorMap[child.tutorId] ?? Tutor(
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

              return ChildWithPointAndTutor(child, point, tutor);
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

final childrenByPointsStreamProvider = StreamProvider.autoDispose.family<List<ChildWithPointAndTutor>, List<String>>((ref, pointsIds) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw AssertionError('User can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchChildrenFullByPoints(pointsIds);
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

final childStreamProvider =
    StreamProvider.autoDispose.family<Child, ChildID>((ref, childId) {
  final child = ref.watch(authStateChangesProvider).value;
  if (child == null) {
    throw AssertionError('Child can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchChild(childId: childId);
});

