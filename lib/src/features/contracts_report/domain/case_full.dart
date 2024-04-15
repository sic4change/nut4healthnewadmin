
import 'package:adminnut4health/src/features/cases/domain/case.dart';
import 'package:adminnut4health/src/features/childs/domain/child.dart';
import '../../points/domain/point.dart';

class CaseFull {
  final Case myCase;
  final Point? point;
  final Child? child;

  CaseFull(this.myCase, this.point, this.child);
}