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

  Stream<List<Contract>> watchContracts(int year) {
    Stream<List<Contract>> contracts = _dataSource.watchCollection(
      path: FirestorePath.contracts(),
      builder: (data, documentId) => Contract.fromMap(data, documentId),
      queryBuilder: (query) {
        query = query.where('creationDateYear', isEqualTo: year);
        return query;
      },
    );
    return contracts;
  }

  Stream<List<MainInform>> watchMainInform() {
    return watchContracts(2024).map((contracts) {
      Map<String, Map<String, int>> addressCount = {};

      for (var contract in contracts) {
        addressCount.putIfAbsent(contract.childAddress!, () => {
          'records': 0,
          'fefas': 0,
          'childs': 0,
          'childsMAS': 0,
          'childsMAM': 0,
          'childsPN': 0,
          'fefasfe': 0,
          'fefasfemas': 0,
          'fefasfemam': 0,
          'fefasfepn': 0,
          'fefasfa': 0,
          'fefasfamas': 0,
          'fefasfamam': 0,
          'fefasfapn': 0,
          'fefasfea': 0,
          'fefasfeamas': 0,
          'fefasfeamam': 0,
          'fefasfeapn': 0,
        });

        int currentRecord = addressCount[contract.childAddress]!['records']!;
        addressCount[contract.childAddress]!['records'] = currentRecord + 1;

        if (contract.code!.endsWith('-99')) {
          int currentFefas = addressCount[contract.childAddress]!['fefas']!;
          int currentFe = addressCount[contract.childAddress]!['fefasfe']!;
          int currentFeMas = addressCount[contract.childAddress]!['fefasfemas']!;
          int currentFeMam = addressCount[contract.childAddress]!['fefasfemam']!;
          int currentFePn = addressCount[contract.childAddress]!['fefasfepn']!;
          int currentFa = addressCount[contract.childAddress]!['fefasfa']!;
          int currentFaMas = addressCount[contract.childAddress]!['fefasfamas']!;
          int currentFaMam = addressCount[contract.childAddress]!['fefasfamam']!;
          int currentFaPn = addressCount[contract.childAddress]!['fefasfapn']!;
          int currentFea = addressCount[contract.childAddress]!['fefasfea']!;
          int currentFeaMas = addressCount[contract.childAddress]!['fefasfeamas']!;
          int currentFeaMam = addressCount[contract.childAddress]!['fefasfeamam']!;
          int currentFeaPn = addressCount[contract.childAddress]!['fefasfeapn']!;
          addressCount[contract.childAddress]!['fefas'] = currentFefas + 1;
          if (contract.tutorStatus != null && contract.tutorStatus!.isNotEmpty &&
              (contract.tutorStatus! == 'Embarazada' || contract.tutorStatus! == 'Enceinte' || contract.tutorStatus! == 'حامل')) {
            addressCount[contract.childAddress]!['fefasfe'] = currentFe + 1;
            if ((contract.armCircumferenceMedical!= 0 && contract.armCircumferenceMedical! >= 21.0) ||
                (contract.armCircunference!= 0 && contract.armCircunference! >= 21.0)) {
              addressCount[contract.childAddress]!['fefasfepn'] = currentFePn + 1;
            } else if ((contract.armCircumferenceMedical!= 0 && contract.armCircumferenceMedical! >= 18.0 && contract.armCircumferenceMedical! <= 20.9) ||
                (contract.armCircunference!= 0 && contract.armCircunference! >= 18.0 && contract.armCircunference! <= 20.9)) {
              addressCount[contract.childAddress]!['fefasfemam'] = currentFeMam + 1;
            } else if ((contract.armCircumferenceMedical!= 0 && contract.armCircumferenceMedical! <= 17.9) ||
                (contract.armCircunference!= 0 && contract.armCircunference! <= 17.9)) {
              addressCount[contract.childAddress]!['fefasfemas'] = currentFeMas + 1;
            }
          } else if (contract.tutorStatus != null && contract.tutorStatus!.isNotEmpty &&
              (contract.tutorStatus! == 'Lactante' || contract.tutorStatus! == 'Allaitante'  || contract.tutorStatus! == ' المرضعة')) {
            addressCount[contract.childAddress]!['fefasfa'] = currentFa + 1;
            if ((contract.armCircumferenceMedical!= 0 && contract.armCircumferenceMedical! >= 21.0) ||
                (contract.armCircunference!= 0 && contract.armCircunference! >= 21.0)) {
              addressCount[contract.childAddress]!['fefasfapn'] = currentFaPn + 1;
            } else if ((contract.armCircumferenceMedical!= 0 && contract.armCircumferenceMedical! >= 18.0 && contract.armCircumferenceMedical! <= 20.9) ||
                (contract.armCircunference!= 0 && contract.armCircunference! >= 18.0 && contract.armCircunference! <= 20.9)) {
              addressCount[contract.childAddress]!['fefasfamam'] = currentFaMam + 1;
            } else if ((contract.armCircumferenceMedical!= 0 && contract.armCircumferenceMedical! <= 17.9) ||
                (contract.armCircunference!= 0 && contract.armCircunference! <= 17.9)) {
              addressCount[contract.childAddress]!['fefasfamas'] = currentFaMas + 1;
            }
          } else if (contract.tutorStatus != null && contract.tutorStatus!.isNotEmpty &&
              (contract.tutorStatus! == 'Embarazada y lactante' || contract.tutorStatus! == 'Enceinte et allaitante' || contract.tutorStatus! == 'الحامل و المرضعة ')){
            addressCount[contract.childAddress]!['fefasfea'] = currentFea + 1;
            if ((contract.armCircumferenceMedical!= 0 && contract.armCircumferenceMedical! >= 21.0) ||
                (contract.armCircunference!= 0 && contract.armCircunference! >= 21.0)) {
              addressCount[contract.childAddress]!['fefasfeapn'] = currentFeaPn + 1;
            } else if ((contract.armCircumferenceMedical!= 0 && contract.armCircumferenceMedical! >= 18.0 && contract.armCircumferenceMedical! <= 20.9) ||
                (contract.armCircunference!= 0 && contract.armCircunference! >= 18.0 && contract.armCircunference! <= 20.9)) {
              addressCount[contract.childAddress]!['fefasfeamam'] = currentFeaMam + 1;
            } else if ((contract.armCircumferenceMedical!= 0 && contract.armCircumferenceMedical! <= 17.9) ||
                (contract.armCircunference!= 0 && contract.armCircunference! <= 17.9)) {
              addressCount[contract.childAddress]!['fefasfeamas'] = currentFeaMas + 1;
            }
          }
        } else {
          int currentChilds = addressCount[contract.childAddress]!['childs']!;
          int currentChildMAS = addressCount[contract.childAddress]!['childsMAS']!;
          int currentChildMAM = addressCount[contract.childAddress]!['childsMAM']!;
          int currentChildPN = addressCount[contract.childAddress]!['childsPN']!;
          addressCount[contract.childAddress]!['childs'] = currentChilds + 1;
          if ((contract.armCircumferenceMedical!= 0 && contract.armCircumferenceMedical! >= 12.5) ||
              (contract.armCircunference!= 0 && contract.armCircunference! >= 12.5)) {
            addressCount[contract.childAddress]!['childsPN'] = currentChildPN + 1;
          } else if ((contract.armCircumferenceMedical!= 0 && contract.armCircumferenceMedical! >= 11.5 && contract.armCircumferenceMedical! <= 12.4) ||
              (contract.armCircunference!= 0 && contract.armCircunference! >= 11.5 && contract.armCircunference! <= 12.4)) {
            addressCount[contract.childAddress]!['childMAM'] = currentChildMAM + 1;
          } else if ((contract.armCircumferenceMedical!= 0 && contract.armCircumferenceMedical! <= 11.4) ||
            (contract.armCircunference!= 0 && contract.armCircunference! <= 11.4)) {
            addressCount[contract.childAddress]!['childsMAS'] = currentChildMAS + 1;
          }

      }

      }

      List<MainInform> mainInfoList = addressCount.entries.map((entry) {
        var data = entry.value;
        return MainInform(
            place: entry.key,
            records: data['records']!,
            fefas: data['fefas']!,
            childs: data['childs']!,
            childsMAS: data['childsMAS']!,
            childsMAM: data['childsMAM']!,
            childsPN: data['childsPN']!,
            fefasfe: data['fefasfe']!,
            fefasfemas: data['fefasfemas']!,
            fefasfemam: data['fefasfemam']!,
            fefasfepn: data['fefasfepn']!,
            fefasfa: data['fefasfa']!,
            fefasfamas: data['fefasfamas']!,
            fefasfamam: data['fefasfamam']!,
            fefasfapn: data['fefasfapn']!,
            fefasfea: data['fefasfea']!,
            fefasfeamas: data['fefasfeamas']!,
            fefasfeamam: data['fefasfeamam']!,
            fefasfeapn: data['fefasfeapn']!,
        );
      }).toList();

      mainInfoList.sort((a, b) => a.place.compareTo(b.place));

      return mainInfoList;
    });
  }




}

final databaseProvider = Provider<FirestoreRepository>((ref) {
  return FirestoreRepository(ref.watch(firestoreDataSourceProvider));
});


final mainInformMauritane2024StreamProvider = StreamProvider.autoDispose<List<MainInform>>((ref) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw AssertionError('User can\'t be null');
  }
  final database = ref.watch(databaseProvider);
  return database.watchMainInform();
});








