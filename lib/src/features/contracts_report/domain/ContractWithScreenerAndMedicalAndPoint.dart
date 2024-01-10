import 'package:adminnut4health/src/features/users/domain/user.dart';

import '../../points/domain/point.dart';
import 'contract.dart';

class ContractWithScreenerAndMedicalAndPoint {
  final Contract contract;
  final User? screener;
  final User? medical;
  final Point? point;

  ContractWithScreenerAndMedicalAndPoint(this.contract, this.screener, this.medical, this.point);
}