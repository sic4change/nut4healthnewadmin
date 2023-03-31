import 'package:adminnut4health/src/features/childs/domain/child.dart';
import 'package:adminnut4health/src/features/cases/domain/case.dart';
import 'package:adminnut4health/src/features/tutors/domain/tutor.dart';
import 'package:adminnut4health/src/features/visits/domain/visit.dart';
import '../../points/domain/point.dart';

class VisitCombined {
  final Visit visit;
  final Point? point;
  final Child? child;
  final Tutor? tutor;
  final Case? myCase;

  VisitCombined(this.visit, this.point, this.child, this.tutor, this.myCase);
}