import 'package:adminnut4health/src/features/childs/domain/child.dart';
import 'package:adminnut4health/src/features/tutors/domain/tutor.dart';
import 'package:adminnut4health/src/features/visitsWithoutDiagnosis/domain/visitWithoutDiagnosis.dart';
import '../../points/domain/point.dart';

class VisitWithoutDiagnosisCombined {
  final VisitWithoutDiagnosis visitWithoutDiagnosis;
  final Point? point;
  final Child? child;
  final Tutor? tutor;

  VisitWithoutDiagnosisCombined(this.visitWithoutDiagnosis, this.point, this.child, this.tutor);
}