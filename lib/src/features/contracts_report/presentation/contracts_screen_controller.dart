import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';


class ContractsScreenController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // ok to leave this empty if the return type is FutureOr<void>
  }
}

final contractsScreenControllerProvider =
    AutoDisposeAsyncNotifierProvider<ContractsScreenController, void>(
        ContractsScreenController.new);
