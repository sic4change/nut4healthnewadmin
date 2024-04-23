import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../authentication/data/firebase_auth_repository.dart';
import '../../../common_data/firestore_data_source.dart';
import '../../points/domain/point.dart';

import 'package:rxdart/rxdart.dart';

import '../../users/domain/user.dart';
import '../domain/ContractWithScreener.dart';
import '../domain/ContractWithScreenerAndMedicalAndPoint.dart';
import '../domain/ContractWithPoint.dart';
import '../domain/contract.dart';
import '../domain/contract_point_stadistic.dart';
import '../domain/contract_screener_stadistic.dart';

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

  Future<Contract> fetchContract({required ContractID contractId}) =>
      _dataSource.fetchDocument(
        path: FirestorePath.contract(contractId),
        builder: (data, documentId) => Contract.fromMap(data, documentId),
      );

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

  Future<void> updateContractChildAddress({required String contractId, required String newChildAddress}) async {
    String path = FirestorePath.contract(contractId);
    await _dataSource.updateData(path: path, data: {'childAddress': newChildAddress});
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
      queryBuilder: (query) {
        if (User.currentRole != 'super-admin' && User.currentRole != 'donante') {
          query = query.where('chefValidation', isEqualTo: true).where('regionalValidation', isEqualTo: true);
        }
        return query;
      },
    );
    return contracts;
  }

  Stream<List<Contract>> watchContractsByRegion(List<String> pointsIds) {
    Stream<List<Contract>> contracts = _dataSource.watchCollection(
      path: FirestorePath.contracts(),
      builder: (data, documentId) => Contract.fromMap(data, documentId),
      queryBuilder: (query) {
        query = query.where('point', whereIn: pointsIds);
        if (User.currentRole == 'direccion-regional-salud') {
          query = query.where('chefValidation', isEqualTo: true);
        }
        return query;
      },
    );
    return contracts;
  }

  Stream<List<Contract>> watchContractsByPoint(String pointId) {
    Stream<List<Contract>> contracts = _dataSource.watchCollection(
      path: FirestorePath.contracts(),
      builder: (data, documentId) => Contract.fromMap(data, documentId),
      queryBuilder: (query) => query.where('point', isEqualTo: pointId),
    );
    return contracts;
  }

  Stream<List<Contract>> watchContractsByScreener(String screenerId) {
    Stream<List<Contract>> contracts = _dataSource.watchCollection(
      path: FirestorePath.contracts(),
      builder: (data, documentId) => Contract.fromMap(data, documentId),
      queryBuilder: (query) => query.where('screenerId', isEqualTo: screenerId),
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

  Stream<List<User>> watchScreenerUsers() {
    Stream<List<User>> users =  _dataSource.watchCollection(
      path: FirestorePath.users(),
      builder: (data, documentId) => User.fromMap(data, documentId),
      queryBuilder: (query) => query.where('role', isEqualTo: 'Agente Salud').orderBy('name'),
    );
    return users;
  }

  Stream<List<Point>> watchPoints() {
    Stream<List<Point>> points =  _dataSource.watchCollection(
      path: FirestorePath.points(),
      builder: (data, documentId) => Point.fromMap(data, documentId),
      queryBuilder: (query) => query.orderBy('fullName'),
    );
    return points;
  }

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

  Stream<List<ContractWithScreenerAndMedicalAndPoint>> watchContractWithConfigurationAndPoints() {
    const emptyUser = User(userId: '', name: '', email: '', role: '');
    final emptyPoint = Point.getEmptyPoint();
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

  Stream<List<ContractWithScreenerAndMedicalAndPoint>> watchContractsFullbyPoints(List<String> pointsIds) {
    const emptyUser = User(userId: '', name: '', email: '', role: '');
    final emptyPoint = Point.getEmptyPoint();
    return CombineLatestStream.combine3(
        watchContractsByRegion(pointsIds), watchUsers(), watchPoints(),
            (List<Contract> contracts, List<User> users, List<Point> points) {
          final lalala = contracts;
          return lalala.map((contract) {
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

  Stream<List<ContractPointStadistic>> watchContractPoints(String pointId) {
    final emptyPoint = Point.getEmptyPoint();
    return CombineLatestStream.combine2(
        watchContractsByPoint(pointId), watchPoints(),
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
            String key = '${item.contract.creationDate?.year}_'
                '${item.contract.creationDate?.month}_'
                '${item.contract.creationDate?.day}';
            if (!map.containsKey(key)) {
              map[key] = [item];
            } else {
              map[key]!.add(item);
            }
            return map;
          });

          List<ContractPointStadistic> contractStaticsList = groupedCases.entries.map((entry) {
            DateTime creationDate = DateTime.parse(entry.value[0].contract.creationDate!.toString());
            String? point = entry.value[0].contract.point;
            int value = entry.value.length;
            return ContractPointStadistic(creationDate: creationDate, point: point, value: value);
          }).toList();
          contractStaticsList.sort((a, b) => a.creationDate!.compareTo(b.creationDate!));

          return contractStaticsList;
        });

  }


  Stream<List<ContractScreenerStadistic>> watchContractsScreener(String screenerId) {
    const emptyUser = User(userId: '', email: '', role: 'Agente Salud');
    return CombineLatestStream.combine2(
        watchContractsByScreener(screenerId), watchScreenerUsers(),
            (List<Contract> contracts, List<User> screeners) {
          List<ContractWithScreener> contractsWithScreener = contracts.map((contract) {
            final Map<String, User> userMap = Map.fromEntries(
              screeners.map((user) => MapEntry(user.userId, user)),
            );
            final screener = userMap[contract.screenerId] ?? emptyUser;
            return ContractWithScreener(contract, screener);
          }).toList();

          Map<String, List<ContractWithScreener>> groupedCases = contractsWithScreener.fold({},
                  (Map<String, List<ContractWithScreener>> map, ContractWithScreener item) {
                String key = '${item.contract.creationDate?.year}_'
                    '${item.contract.creationDate?.month}_'
                    '${item.contract.creationDate?.day}';
                if (!map.containsKey(key)) {
                  map[key] = [item];
                } else {
                  map[key]!.add(item);
                }
                return map;
              });

          List<ContractScreenerStadistic> contractScreenerStaticsList = groupedCases.entries.map((entry) {
            DateTime creationDate = DateTime.parse(entry.value[0].contract.creationDate!.toString());
            String? screener = entry.value[0].contract.screenerId;
            int value = entry.value.length;
            return ContractScreenerStadistic(creationDate: creationDate, user: screener, value: value);
          }).toList();
          contractScreenerStaticsList.sort((a, b) => a.creationDate!.compareTo(b.creationDate!));

          return contractScreenerStaticsList;
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

final contractsByPointsStreamProvider = StreamProvider.autoDispose.family<List<ContractWithScreenerAndMedicalAndPoint>, List<String>>((ref, pointsIds) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw AssertionError('User can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchContractsFullbyPoints(pointsIds);
});

final contractsStadisticsStreamProvider = StreamProvider.autoDispose.family<List<ContractPointStadistic>, String>((ref, pointId) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw AssertionError('User can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchContractPoints(pointId);
});

final pointsStreamProvider = StreamProvider.autoDispose<List<Point>>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw AssertionError('User can\'t be null');
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

final screenersStreamProvider = StreamProvider.autoDispose<List<User>>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw AssertionError('User can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchScreenerUsers();
});

final contractsScreenerStadisticsStreamProvider =
  StreamProvider.autoDispose.family<List<ContractScreenerStadistic>, String>((ref, screenerId) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw AssertionError('User can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchContractsScreener(screenerId);
});

final contractsPointStadisticsStreamProvider =
StreamProvider.autoDispose.family<List<Contract>, String>((ref, pointId) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw AssertionError('User can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchContractsByPoint(pointId);
});





