import 'dart:async';

import 'package:adminnut4health/src/features/reports/domain/reportWithUser.dart';
import 'package:adminnut4health/src/features/users/domain/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';

import '../../authentication/data/firebase_auth_repository.dart';
import '../../../common_data/firestore_data_source.dart';

import '../domain/report.dart';

String documentIdFromCurrentDate() {
  final iso = DateTime.now().toIso8601String();
  return iso.replaceAll(':', '-').replaceAll('.', '-');
}

class FirestorePath {
  static String user(String uid) => 'users/$uid';
  static String users() => 'users';
  static String report(String uid) => 'reports/$uid';
  static String reports() => 'reports';
}

class FirestoreRepository {
  const FirestoreRepository(this._dataSource);
  final FirestoreDataSource _dataSource;

  Stream<List<User>> watchUsers() =>
      _dataSource.watchCollection(
        path: FirestorePath.users(),
        builder: (data, documentId) => User.fromMap(data, documentId),
      );

  Future<void> setReport({required Report report}) =>
      _dataSource.setData(
        path: FirestorePath.reports(),
        data: report.toMap(),
      );

  Future<void> deleteReport({required Report report}) async {
    await _dataSource.deleteData(path: FirestorePath.report(report.reportId));
  }

  Future<void> updateReport({required Report report}) async {
    await _dataSource.updateData(path: FirestorePath.report(report.reportId), data: report.toMap());
  }

  Future<void> addReport({required Report report}) async {
    await _dataSource.addData(path: FirestorePath.reports(), data: report.toMap());
  }

  Stream<Report> watchReport({required ReportID reportId}) =>
      _dataSource.watchDocument(
        path: FirestorePath.report(reportId),
        builder: (data, documentId) => Report.fromMap(data, documentId),
      );

  Stream<List<Report>> watchReports() =>
      _dataSource.watchCollection(
        path: FirestorePath.reports(),
        builder: (data, documentId) => Report.fromMap(data, documentId),
      );

  Stream<List<ReportWithUser>> watchReportsWithUsers() {
    return CombineLatestStream.combine2(
        watchReports(),
        watchUsers(),
            (List<Report> reports, List<User> users,) {
          final Map<String, User> userMap = Map.fromEntries(
            users.map((user) => MapEntry(user.userId, user)),
          );
          return reports.map((report) {
            try {
              final User user = userMap[report
                  .user]!;
              return ReportWithUser(
                  report, user);
            } catch (e) {
                return ReportWithUser(
                    report,
                    User(userId: '', name: '', email: '', role: ''));
          }}).toList();
        });
  }

  Future<Report> fetchReport({required ReportID reportId}) =>
      _dataSource.fetchDocument(
        path: FirestorePath.report(reportId),
        builder: (data, documentId) => Report.fromMap(data, documentId),
      );

  Future<List<Report>> fetchReports() =>
      _dataSource.fetchCollection(
        path: FirestorePath.reports(),
        builder: (data, documentId) => Report.fromMap(data, documentId),
      );

}

final databaseProvider = Provider<FirestoreRepository>((ref) {
  return FirestoreRepository(ref.watch(firestoreDataSourceProvider));
});

final reportsStreamProvider = StreamProvider.autoDispose<List<ReportWithUser>>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw AssertionError('User can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchReportsWithUsers();
});

final reportStreamProvider =
    StreamProvider.autoDispose.family<Report, ReportID>((ref, reportId) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw AssertionError('User can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchReport(reportId: reportId);
});

