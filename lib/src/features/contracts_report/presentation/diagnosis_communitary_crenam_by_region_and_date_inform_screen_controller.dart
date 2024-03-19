import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';


class DiagnosisCommunitaryCrenamByRegionAndDateInformScreenController extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // ok to leave this empty if the return type is FutureOr<void>
  }
}

final contractsScreenControllerProvider =
    AutoDisposeAsyncNotifierProvider<DiagnosisCommunitaryCrenamByRegionAndDateInformScreenController, void>(
        DiagnosisCommunitaryCrenamByRegionAndDateInformScreenController.new);
