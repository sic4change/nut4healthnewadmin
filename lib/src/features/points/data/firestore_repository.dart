import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../authentication/data/firebase_auth_repository.dart';
import '../../../common_data/firestore_data_source.dart';
import '../domain/point.dart';

String documentIdFromCurrentDate() {
  final iso = DateTime.now().toIso8601String();
  return iso.replaceAll(':', '-').replaceAll('.', '-');
}

class FirestorePath {
  static String point(String uid) => 'points/$uid';
  static String points() => 'points';
}

class FirestoreRepository {
  const FirestoreRepository(this._dataSource);
  final FirestoreDataSource _dataSource;

  Future<void> setPoint({required Point point}) =>
      _dataSource.setData(
        path: FirestorePath.points(),
        data: point.toMap(),
      );

  Future<void> deletePoint({required Point point}) async {
    await _dataSource.deleteData(path: FirestorePath.point(point.pointId));
  }

  Future<void> updatePoint({required Point point}) async {
    await _dataSource.updateData(path: FirestorePath.point(point.pointId), data: point.toMap());
  }

  Future<void> addPoint({required Point point}) async {
    await _dataSource.addData(path: FirestorePath.points(), data: point.toMap());
  }

  Stream<Point> watchPoint({required PointID pointId}) =>
      _dataSource.watchDocument(
        path: FirestorePath.point(pointId),
        builder: (data, documentId) => Point.fromMap(data, documentId),
      );

  Stream<List<Point>> watchPoints() =>
      _dataSource.watchCollection(
        path: FirestorePath.points(),
        builder: (data, documentId) => Point.fromMap(data, documentId),
      );

  Future<List<Point>> fetchPoints() =>
      _dataSource.fetchCollection(
        path: FirestorePath.points(),
        builder: (data, documentId) => Point.fromMap(data, documentId),
      );

}

final databaseProvider = Provider<FirestoreRepository>((ref) {
  return FirestoreRepository(ref.watch(firestoreDataSourceProvider));
});

final pointsStreamProvider = StreamProvider.autoDispose<List<Point>>((ref) {
  final point = ref.watch(authStateChangesProvider).value;
  if (point == null) {
    throw AssertionError('Point can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchPoints();
});

final pointStreamProvider =
    StreamProvider.autoDispose.family<Point, PointID>((ref, pointId) {
  final point = ref.watch(authStateChangesProvider).value;
  if (point == null) {
    throw AssertionError('Point can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchPoint(pointId: pointId);
});

