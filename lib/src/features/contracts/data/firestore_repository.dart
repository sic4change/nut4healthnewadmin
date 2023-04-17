import 'dart:async';

import 'package:adminnut4health/src/features/contracts/domain/contract_stadistic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../authentication/data/firebase_auth_repository.dart';
import '../../../common_data/firestore_data_source.dart';
import '../../points/domain/point.dart';

import 'package:rxdart/rxdart.dart';

import '../../users/domain/user.dart';
import '../domain/ContractWithScreenerAndMedicalAndPoint.dart';
import '../domain/ContractWithPoint.dart';
import '../domain/contract.dart';

String documentIdFromCurrentDate() {
  final iso = DateTime.now().toIso8601String();
  return iso.replaceAll(':', '-').replaceAll('.', '-');
}

class FirestorePath {
  static String contract(String uid) => 'contracts/$uid';
  static String contracts() => 'contracts';
  static String user(String uid) => 'users/$uid';
  static String users() => 'users';
  static String point(String uid) => 'points/$uid';
  static String points() => 'points';
}

class FirestoreRepository {
  const FirestoreRepository(this._dataSource);
  final FirestoreDataSource _dataSource;

  Future<void> setContract({required Contract contract}) =>
      _dataSource.setData(
        path: FirestorePath.contracts(),
        data: contract.toMap(),
      );

  Future<void> deleteContract({required Contract contract}) async {
    await _dataSource.deleteData(path: FirestorePath.contract(contract.contractId));
  }

  Future<void> updateContract({required Contract contract}) async {
    await _dataSource.updateData(path: FirestorePath.contract(contract.contractId), data: contract.toMap());
  }

  Future<void> addContract({required Contract contract}) async {
    await _dataSource.addData(path: FirestorePath.contracts(), data: contract.toMap());
  }

  Stream<Contract> watchContract({required ContractID contractId}) =>
      _dataSource.watchDocument(
        path: FirestorePath.contract(contractId),
        builder: (data, documentId) => Contract.fromMap(data, documentId),
      );

  Stream<List<Contract>> watchContracts() {
    Stream<List<Contract>> contracts = _dataSource.watchCollection(
      path: FirestorePath.contracts(),
      builder: (data, documentId) => Contract.fromMap(data, documentId),
    );
    return contracts;
  }

  Stream<List<User>> watchUsers() {
    Stream<List<User>> users =  _dataSource.watchCollection(
      path: FirestorePath.users(),
      builder: (data, documentId) => User.fromMap(data, documentId),
    );
    return users;
  }

  Stream<List<Point>> watchPoints() {
    Stream<List<Point>> points =  _dataSource.watchCollection(
      path: FirestorePath.points(),
      builder: (data, documentId) => Point.fromMap(data, documentId),
    );
    return points;
  }

  Stream<List<ContractWithScreenerAndMedicalAndPoint>> watchContractWithConfigurationAndPoints() {
    const emptyUser = User(userId: '', name: '', email: '', role: '');
    const emptyPoint = Point(pointId: '', name: '', fullName: '', country: '',
        province: '', phoneCode: '', active: false, latitude: 0.0, longitude: 0.0,
    cases: 0, casesnormopeso: 0, casesmoderada: 0, casessevera: 0);
    return CombineLatestStream.combine3(
        watchContracts(), watchUsers(), watchPoints(),
          (List<Contract> contracts, List<User> users, List<Point> points) {
            return contracts.map((contract) {
              final Map<String, Point> pointMap = Map.fromEntries(
                points.map((point) => MapEntry(point.pointId, point)),
              );
              final point = pointMap[contract.point] ?? emptyPoint;
              final Map<String, User> userMap = Map.fromEntries(
                users.map((user) => MapEntry(user.userId, user)),
              );
              final medical = userMap[contract.medicalId] ?? emptyUser;
              final screener = userMap[contract.screenerId] ?? emptyUser;
              return ContractWithScreenerAndMedicalAndPoint(contract, screener, medical, point);
            }).toList();
          });
  }

  Stream<List<ContractStadistic>> watchContractPoints() {
    const emptyPoint = Point(pointId: '', name: '', fullName: '', country: '',
        province: '', phoneCode: '', active: false, latitude: 0.0, longitude: 0.0,
        cases: 0, casesnormopeso: 0, casesmoderada: 0, casessevera: 0);
    return CombineLatestStream.combine2(
        watchContracts(), watchPoints(),
            (List<Contract> contracts, List<Point> points) {
          List<ContractWithPoint> contractsWithPoint = contracts.map((contract) {
            final Map<String, Point> pointMap = Map.fromEntries(
              points.map((point) => MapEntry(point.pointId, point)),
            );
            final point = pointMap[contract.point] ?? emptyPoint;
            return ContractWithPoint(contract, point);
          }).toList();

          Map<String, List<ContractWithPoint>> groupedCases = contractsWithPoint.fold({},
                  (Map<String, List<ContractWithPoint>> map, ContractWithPoint item) {
            //String key = '${item.contract.creationDate}_${item.point?.pointId}';
            String key = '${item.contract.creationDate?.year}_${item.contract.creationDate?.month}_'
                '${item.contract.creationDate?.day}';
            if (!map.containsKey(key)) {
              map[key] = [item];
            } else {
              map[key]!.add(item);
            }
            return map;
          });

          List<ContractStadistic> contractStaticsList = groupedCases.entries.map((entry) {
            List<String> keys = entry.key.split('_');
            DateTime creationDate = DateTime.parse(entry.value[0].contract.creationDate!.toString());
            String? point = entry.value[0].contract.point;
            int value = entry.value.length;
            return ContractStadistic(creationDate: creationDate, point: point, value: value);
          }).toList();
          contractStaticsList.sort((a, b) => a.creationDate!.compareTo(b.creationDate!));

          return contractStaticsList;
        });

  }

  Future<User> fetchUser({required UserID userId}) =>
      _dataSource.fetchDocument(
        path: FirestorePath.user(userId),
        builder: (data, documentId) => User.fromMap(data, documentId),
      );

  Future<List<User>> fetchUsers() =>
      _dataSource.fetchCollection(
        path: FirestorePath.users(),
        builder: (data, documentId) => User.fromMap(data, documentId),
      );

}

final databaseProvider = Provider<FirestoreRepository>((ref) {
  return FirestoreRepository(ref.watch(firestoreDataSourceProvider));
});

final contractsStreamProvider = StreamProvider.autoDispose<List<ContractWithScreenerAndMedicalAndPoint>>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw AssertionError('User can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchContractWithConfigurationAndPoints();
});

final contractsStadisticsStreamProvider = StreamProvider.autoDispose<List<ContractStadistic>>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw AssertionError('User can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchContractPoints();
});





