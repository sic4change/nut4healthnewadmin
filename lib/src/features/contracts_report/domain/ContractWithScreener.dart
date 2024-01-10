import 'package:adminnut4health/src/features/users/domain/user.dart';

import '../../points/domain/point.dart';
import 'contract.dart';

class ContractWithScreener {
  final Contract contract;
  final User? screener;

  ContractWithScreener(this.contract, this.screener);
}