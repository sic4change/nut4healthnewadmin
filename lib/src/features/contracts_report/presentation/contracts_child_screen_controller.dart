import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';


class ContractsChildScreenController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // ok to leave this empty if the return type is FutureOr<void>
  }
}

final contractschildScreenControllerProvider =
    AutoDisposeAsyncNotifierProvider<ContractsChildScreenController, void>(
        ContractsChildScreenController.new);
