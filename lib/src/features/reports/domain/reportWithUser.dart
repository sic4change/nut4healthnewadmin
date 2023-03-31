import 'package:adminnut4health/src/features/reports/domain/report.dart';
import 'package:adminnut4health/src/features/users/domain/user.dart';

class ReportWithUser {
  final Report report;
  final User? user;

  ReportWithUser(this.report, this.user);
}