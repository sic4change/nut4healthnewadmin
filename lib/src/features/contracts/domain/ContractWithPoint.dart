import 'package:adminnut4health/src/features/users/domain/user.dart';

import '../../points/domain/point.dart';
import 'contract.dart';

class ContractWithPoint {
  final Contract contract;
  final Point? point;

  ContractWithPoint(this.contract,this.point);
}