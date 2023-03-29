import 'package:adminnut4health/src/features/childs/domain/child.dart';
import 'package:adminnut4health/src/features/cases/domain/case.dart';
import 'package:adminnut4health/src/features/tutors/domain/tutor.dart';
import '../../points/domain/point.dart';

class CaseWithPointChildAndTutor {
  final Case myCase;
  final Point? point;
  final Child? child;
  final Tutor? tutor;

  CaseWithPointChildAndTutor(this.myCase, this.point, this.child, this.tutor);
}