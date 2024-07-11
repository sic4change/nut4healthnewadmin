
import 'package:adminnut4health/src/features/cases/domain/case.dart';
import 'package:adminnut4health/src/features/childs/domain/child.dart';
import '../../points/domain/point.dart';

class CaseFull {
  final Case myCase;
  final Point? point;
  final Child? child;

  CaseFull(this.myCase, this.point, this.child);

  DateTime getClosedDate() {
    DateTime closedDate = myCase.lastDate;
    if (myCase.closedReason == CaseType.abandonment) {
      final daysToAbandonment = point!.type == "CRENAM" || point!.type == "Otro"? 31
          : point!.type == "CRENAS"? 14
          : 2;
      closedDate = closedDate.add(Duration(days: daysToAbandonment));
    }
    return closedDate;
  }
}