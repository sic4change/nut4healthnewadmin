import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../contracts/data/firestore_repository.dart';

import '../domain/contract.dart';

class ContractsScreenController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // ok to leave this empty if the return type is FutureOr<void>
  }

  Future<void> addContract(Contract contract) async {
    final database = ref.read(databaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => database.addContract(contract: contract));
  }

  Future<void> deleteContract(Contract contract) async {
    final database = ref.read(databaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => database.deleteContract(contract: contract));
  }

  Future<void> updateContract(Contract contract) async {
    final database = ref.read(databaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => database.updateContract(contract: contract));
  }

  Future<void> updateLocalizationContract(String contractId, String localization) async {
    try {
      final database = ref.read(databaseProvider);
      state = const AsyncLoading();
      var contract = await AsyncValue.guard(() => database.fetchContract(contractId: contractId));
      if (contract.hasValue) {
        state = await AsyncValue.guard(() => database.updateContractChildAddress(contractId: contractId, newChildAddress: localization));
      }
    } catch (e) {
      print('Error updating localization: $e');
    }

  }
}

final contractsScreenControllerProvider =
    AutoDisposeAsyncNotifierProvider<ContractsScreenController, void>(
        ContractsScreenController.new);
