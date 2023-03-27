import 'package:adminnut4health/src/features/points/domain/point.dart';
import 'package:adminnut4health/src/features/tutors/domain/tutor.dart';

class TutorWithPoint {
  final Tutor tutor;
  final Point? point;

  TutorWithPoint(this.tutor, this.point);
}