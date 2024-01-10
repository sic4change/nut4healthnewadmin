import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../authentication/data/firebase_auth_repository.dart';
import '../../../common_data/firestore_data_source.dart';

import '../domain/contract.dart';
import '../domain/main_inform.dart';

String documentIdFromCurrentDate() {
  final iso = DateTime.now().toIso8601String();
  return iso.replaceAll(':', '-').replaceAll('.', '-');
}

class FirestorePath {
  static String contracts() => 'contracts';
}

class FirestoreRepository {
  const FirestoreRepository(this._dataSource);
  final FirestoreDataSource _dataSource;

  Stream<List<Contract>> watchContracts() {
    Stream<List<Contract>> contracts = _dataSource.watchCollection(
      path: FirestorePath.contracts(),
      builder: (data, documentId) => Contract.fromMap(data, documentId),
      queryBuilder: (query) {
        query = query.where('creationDateYear', isEqualTo: 2024);
        return query;
      },
    );
    return contracts;
  }

  Stream<List<MainInform>> watchMainInform() {
    return watchContracts().map((contracts) {
      Map<String, Map<String, int>> addressCount = {};

      for (var contract in contracts) {
        // Inicializa los contadores si es la primera vez que se encuentra esta dirección
        addressCount.putIfAbsent(contract.childAddress!, () => {'records': 0, 'fefas': 0, 'childs': 0});

        // Incrementa el contador general
        int currentRecord = addressCount[contract.childAddress]!['records']!;
        addressCount[contract.childAddress]!['records'] = currentRecord + 1;

        // Verifica si el código termina en -99 y actualiza los contadores correspondientes
        if (contract.code!.endsWith('-99')) {
          int currentFefas = addressCount[contract.childAddress]!['fefas']!;
          addressCount[contract.childAddress]!['fefas'] = currentFefas + 1;
        } else {
          int currentChilds = addressCount[contract.childAddress]!['childs']!;
          addressCount[contract.childAddress]!['childs'] = currentChilds + 1;
        }
      }

      List<MainInform> mainInfoList = addressCount.entries.map((entry) {
        var data = entry.value;
        return MainInform(
            place: entry.key,
            records: data['records']!,
            fefas: data['fefas']!,
            childs: data['childs']!
        );
      }).toList();

      // Ordenar la lista por 'place'
      mainInfoList.sort((a, b) => a.place.compareTo(b.place));

      return mainInfoList;
    });
  }




}

final databaseProvider = Provider<FirestoreRepository>((ref) {
  return FirestoreRepository(ref.watch(firestoreDataSourceProvider));
});

final contractsStreamProvider = StreamProvider.autoDispose<List<Contract>>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw AssertionError('User can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchContracts();
});

final mainInformMauritane2024StreamProvider = StreamProvider.autoDispose<List<MainInform>>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw AssertionError('User can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchMainInform();
});








