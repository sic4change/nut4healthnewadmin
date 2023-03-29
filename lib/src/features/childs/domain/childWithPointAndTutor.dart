import 'package:adminnut4health/src/features/childs/domain/child.dart';
import 'package:adminnut4health/src/features/tutors/domain/tutor.dart';
import '../../points/domain/point.dart';

class ChildWithPointAndTutor {
  final Child child;
  final Point? point;
  final Tutor? tutor;

  ChildWithPointAndTutor(this.child, this.point, this.tutor);
}