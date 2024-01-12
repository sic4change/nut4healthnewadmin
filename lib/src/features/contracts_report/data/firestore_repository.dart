import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../authentication/data/firebase_auth_repository.dart';
import '../../../common_data/firestore_data_source.dart';

import '../domain/child_inform.dart';
import '../domain/contract.dart';
import '../domain/main_inform.dart';

import 'package:tuple/tuple.dart';


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

  Stream<List<Contract>> watchContracts(int day, int month, int year) {
    Stream<List<Contract>> contracts = _dataSource.watchCollection(
      path: FirestorePath.contracts(),
      builder: (data, documentId) => Contract.fromMap(data, documentId),
      queryBuilder: (query) {
        query = query.where('creationDateYear', isEqualTo: year)
            .where('creationDateMonth', isEqualTo: month)
            .where('creationDateDay', isEqualTo: day);
        return query;
      },
    );
    return contracts;
  }

  Stream<List<MainInform>> watchMainInform(int day, int month, int year) {
    return watchContracts(day, month, year).map((contracts) {
      Map<String, Map<String, int>> addressCount = {};

      for (var contract in contracts) {
        String key = contract.childAddress!.toUpperCase().trim();
        addressCount.putIfAbsent(
            key,
            () => {
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

        int currentRecord = addressCount[key]!['records']!;
        addressCount[key]!['records'] = currentRecord + 1;

        if (contract.code!.endsWith('-99')) {
          int currentFefas = addressCount[key]!['fefas']!;
          int currentFe = addressCount[key]!['fefasfe']!;
          int currentFeMas = addressCount[key]!['fefasfemas']!;
          int currentFeMam = addressCount[key]!['fefasfemam']!;
          int currentFePn = addressCount[key]!['fefasfepn']!;
          int currentFa = addressCount[key]!['fefasfa']!;
          int currentFaMas = addressCount[key]!['fefasfamas']!;
          int currentFaMam = addressCount[key]!['fefasfamam']!;
          int currentFaPn = addressCount[key]!['fefasfapn']!;
          int currentFea = addressCount[key]!['fefasfea']!;
          int currentFeaMas = addressCount[key]!['fefasfeamas']!;
          int currentFeaMam = addressCount[key]!['fefasfeamam']!;
          int currentFeaPn = addressCount[key]!['fefasfeapn']!;
          addressCount[key]!['fefas'] = currentFefas + 1;
          if (contract.tutorStatus != null &&
              contract.tutorStatus!.isNotEmpty &&
              (contract.tutorStatus! == 'Embarazada' ||
                  contract.tutorStatus! == 'Enceinte' ||
                  contract.tutorStatus! == 'حامل')) {
            addressCount[key]!['fefasfe'] = currentFe + 1;
            if ((contract.armCircumferenceMedical != 0 &&
                    contract.armCircumferenceMedical! >= 21.0) ||
                (contract.armCircunference != 0 &&
                    contract.armCircunference! >= 21.0)) {
              addressCount[key]!['fefasfepn'] = currentFePn + 1;
            } else if ((contract.armCircumferenceMedical != 0 &&
                    contract.armCircumferenceMedical! >= 18.0 &&
                    contract.armCircumferenceMedical! <= 20.9) ||
                (contract.armCircunference != 0 &&
                    contract.armCircunference! >= 18.0 &&
                    contract.armCircunference! <= 20.9)) {
              addressCount[key]!['fefasfemam'] =
                  currentFeMam + 1;
            } else if ((contract.armCircumferenceMedical != 0 &&
                    contract.armCircumferenceMedical! <= 17.9) ||
                (contract.armCircunference != 0 &&
                    contract.armCircunference! <= 17.9)) {
              addressCount[key]!['fefasfemas'] = currentFeMas + 1;
            }
          } else if (contract.tutorStatus != null &&
              contract.tutorStatus!.isNotEmpty &&
              (contract.tutorStatus! == 'Lactante' ||
                  contract.tutorStatus! == 'Allaitante' ||
                  contract.tutorStatus! == ' المرضعة')) {
            addressCount[key]!['fefasfa'] = currentFa + 1;
            if ((contract.armCircumferenceMedical != 0 &&
                    contract.armCircumferenceMedical! >= 21.0) ||
                (contract.armCircunference != 0 &&
                    contract.armCircunference! >= 21.0)) {
              addressCount[key]!['fefasfapn'] = currentFaPn + 1;
            } else if ((contract.armCircumferenceMedical != 0 &&
                    contract.armCircumferenceMedical! >= 18.0 &&
                    contract.armCircumferenceMedical! <= 20.9) ||
                (contract.armCircunference != 0 &&
                    contract.armCircunference! >= 18.0 &&
                    contract.armCircunference! <= 20.9)) {
              addressCount[key]!['fefasfamam'] =
                  currentFaMam + 1;
            } else if ((contract.armCircumferenceMedical != 0 &&
                    contract.armCircumferenceMedical! <= 17.9) ||
                (contract.armCircunference != 0 &&
                    contract.armCircunference! <= 17.9)) {
              addressCount[key]!['fefasfamas'] = currentFaMas + 1;
            }
          } else if (contract.tutorStatus != null &&
              contract.tutorStatus!.isNotEmpty &&
              (contract.tutorStatus! == 'Embarazada y lactante' ||
                  contract.tutorStatus! == 'Enceinte et allaitante' ||
                  contract.tutorStatus! == 'الحامل و المرضعة ')) {
            addressCount[key]!['fefasfea'] = currentFea + 1;
            if ((contract.armCircumferenceMedical != 0 &&
                    contract.armCircumferenceMedical! >= 21.0) ||
                (contract.armCircunference != 0 &&
                    contract.armCircunference! >= 21.0)) {
              addressCount[key]!['fefasfeapn'] = currentFeaPn + 1;
            } else if ((contract.armCircumferenceMedical != 0 &&
                    contract.armCircumferenceMedical! >= 18.0 &&
                    contract.armCircumferenceMedical! <= 20.9) ||
                (contract.armCircunference != 0 &&
                    contract.armCircunference! >= 18.0 &&
                    contract.armCircunference! <= 20.9)) {
              addressCount[key]!['fefasfeamam'] = currentFeaMam + 1;
            } else if ((contract.armCircumferenceMedical != 0 &&
                    contract.armCircumferenceMedical! <= 17.9) ||
                (contract.armCircunference != 0 &&
                    contract.armCircunference! <= 17.9)) {
              addressCount[key]!['fefasfeamas'] = currentFeaMas + 1;
            }
          }
        } else {
          int currentChilds = addressCount[key]!['childs']!;
          int currentChildMAS = addressCount[key]!['childsMAS']!;
          int currentChildMAM = addressCount[key]!['childsMAM']!;
          int currentChildPN = addressCount[key]!['childsPN']!;
          addressCount[key]!['childs'] = currentChilds + 1;
          if ((contract.armCircumferenceMedical != 0 &&
                  contract.armCircumferenceMedical! >= 12.5) ||
              (contract.armCircunference != 0 &&
                  contract.armCircunference! >= 12.5)) {
            addressCount[key]!['childsPN'] = currentChildPN + 1;
          } else if ((contract.armCircumferenceMedical != 0 &&
                  contract.armCircumferenceMedical! >= 11.5 &&
                  contract.armCircumferenceMedical! <= 12.4) ||
              (contract.armCircunference != 0 &&
                  contract.armCircunference! >= 11.5 &&
                  contract.armCircunference! <= 12.4)) {
            addressCount[key]!['childMAM'] = currentChildMAM + 1;
          } else if ((contract.armCircumferenceMedical != 0 &&
                  contract.armCircumferenceMedical! <= 11.4) ||
              (contract.armCircunference != 0 &&
                  contract.armCircunference! <= 11.4)) {
            addressCount[key]!['childsMAS'] = currentChildMAS + 1;
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

  int calculateAgeInMonths(int birthdateMilliseconds) {
    DateTime birthDate = DateTime.fromMillisecondsSinceEpoch(birthdateMilliseconds);
    DateTime currentDate = DateTime.now();
    int monthDiff = (currentDate.year - birthDate.year) * 12 + currentDate.month - birthDate.month;

    if (currentDate.day < birthDate.day) {
      monthDiff--;
    }

    return monthDiff;
  }


  Stream<List<ChildInform>> watchChildInform(int day, int month, int year) {
    return watchContracts(day, month, year).map((contracts) {
      Map<String, Map<String, int>> addressAndAgeCount = {};

      for (var contract in contracts) {
        for (String ageGroup in ['6 - 23 (m)', '24 - 59 (m)']) {
          String key = '${contract.childAddress!.toUpperCase().trim()}_$ageGroup';
          addressAndAgeCount.putIfAbsent(
              key,
                  () => {
                'records': 0, 'male': 0, 'female': 0,
              });
        }
      }

      for (var contract in contracts) {
        int ageInMonths = calculateAgeInMonths(contract.childBirthdate!.millisecondsSinceEpoch);
        String ageGroup;

        if (ageInMonths <= 2) {
          continue;
        } else if (ageInMonths <= 23) {
          ageGroup = "6 - 23 (m)";
        } else {
          ageGroup = "24 - 59 (m)";
        }

        String key = '${contract.childAddress!.toUpperCase().trim()}_$ageGroup';

        if (!contract.code!.endsWith('-99')) {
          int currentRecord = addressAndAgeCount[key]!['records']!;
          addressAndAgeCount[key]!['records'] = currentRecord + 1;
          int currentMale = addressAndAgeCount[key]!['male']!;
          int currentFemale = addressAndAgeCount[key]!['female']!;
          if (contract.sex == 'M') {
            addressAndAgeCount[key]!['male'] = currentMale + 1;
          } else if (contract.sex == 'F') {
            addressAndAgeCount[key]!['female'] = currentFemale + 1;
          }
        }
      }

      List<ChildInform> mainInfoList = addressAndAgeCount.entries.map((entry) {
        var data = entry.value;
        return ChildInform(
          place: entry.key.split('_')[0],
          ageGroup: entry.key.split('_')[1],
          records: data['records']!,
          male: data['male']!,
          female: data['female']!
        );
      }).toList();

      mainInfoList.sort((a, b) {
        int placeComparison = a.place.compareTo(b.place);
        if (placeComparison != 0) {
          return placeComparison;
        }
        return a.ageGroup.compareTo(b.ageGroup);
      });

      return mainInfoList;
    });
  }



}

final databaseProvider = Provider<FirestoreRepository>((ref) {
  return FirestoreRepository(ref.watch(firestoreDataSourceProvider));
});


final mainInformMauritane2024StreamProvider = StreamProvider.family.autoDispose<List<MainInform>, Tuple3<int, int, int>>((ref, yearMonthDay) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw AssertionError('User can\'t be null');
  }

  final database = ref.watch(databaseProvider);
  final day = yearMonthDay.item1;
  final month = yearMonthDay.item2;
  final year = yearMonthDay.item3;

  return database.watchMainInform(day, month, year);
});

final childInformMauritane2024StreamProvider = StreamProvider.family.autoDispose<List<ChildInform>, Tuple3<int, int, int>>((ref, yearMonthDay) {
  final user = ref.watch(authStateChangesProvider).value;
  if (user == null) {
    throw AssertionError('User can\'t be null');
  }

  final database = ref.watch(databaseProvider);
  final day = yearMonthDay.item1;
  final month = yearMonthDay.item2;
  final year = yearMonthDay.item3;

  return database.watchChildInform(day, month, year);
});









