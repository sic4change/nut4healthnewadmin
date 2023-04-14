import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

typedef NotificationID = String;

@immutable
class Notification extends Equatable {
  const Notification({
    required this.notificationId,
    required this.pointId,
    required this.childId,
    required this.text,
    required this.timeMillis,
    required this.sent,
  });

  final NotificationID notificationId;
  final String pointId;
  final String childId;
  final String text;
  final double timeMillis;
  final bool sent;

  @override
  List<Object> get props => [notificationId, pointId, childId, text, timeMillis, sent, ];

  @override
  bool get stringify => true;

  factory Notification.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      throw StateError('missing data for notificationId: $documentId');
    }
    final pointId = data['point']?? "";
    final childId = data['childId']?? "";
    final text = data['text']?? "";
    final timeMillis = data['timeMillis']?? "";
    final sent = data['sent']?? false;

    return Notification(
      notificationId: documentId,
      pointId: pointId,
      childId: childId,
      text: text,
      timeMillis: timeMillis,
      sent: sent,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'point': pointId,
      'childId': childId,
      'text': text,
      'timeMillis': timeMillis,
      'sent': sent,
    };
  }
}
