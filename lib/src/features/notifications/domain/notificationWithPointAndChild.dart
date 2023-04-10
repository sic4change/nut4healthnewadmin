import 'package:adminnut4health/src/features/childs/domain/child.dart';
import 'package:adminnut4health/src/features/notifications/domain/notification.dart';
import '../../points/domain/point.dart';

class NotificationWithPointAndChild {
  final Notification notification;
  final Point? point;
  final Child? child;

  NotificationWithPointAndChild(this.notification, this.point, this.child);
}