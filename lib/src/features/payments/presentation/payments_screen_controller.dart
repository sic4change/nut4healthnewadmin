import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../payments/data/firestore_repository.dart';
import '../domain/payment.dart';


class PaymentsScreenController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // ok to leave this empty if the return type is FutureOr<void>
  }

  Future<void> addPayment(Payment payment) async {
    final database = ref.read(databaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => database.addPayment(payment: payment));
  }

  Future<void> deletePayment(Payment payment) async {
    final database = ref.read(databaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => database.deletePayment(payment: payment));
  }

  Future<void> updatePayment(Payment payment) async {
    final database = ref.read(databaseProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => database.updatePayment(payment: payment));
  }
}

final paymentsScreenControllerProvider =
    AutoDisposeAsyncNotifierProvider<PaymentsScreenController, void>(
        PaymentsScreenController.new);
