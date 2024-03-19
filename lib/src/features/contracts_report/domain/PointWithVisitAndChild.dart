
import '../../childs/domain/child.dart';
import '../../points/domain/point.dart';
import '../../visits/domain/visit.dart';

class VisitWithChildAndPoint {
  final Visit visit;
  final Child? child;
  final Point? point;

  VisitWithChildAndPoint(this.visit, this.child, this.point);
}