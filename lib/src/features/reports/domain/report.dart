import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

typedef ReportID = String;

@immutable
class Report extends Equatable {
  const Report({
    required this.reportId,
    required this.text,
    required this.user,
    required this.email,
    required this.sent,
    required this.date,
  });

  final ReportID reportId;
  final String text;
  final String user;
  final String email;
  final bool sent;
  final DateTime date;

  @override
  List<Object> get props => [reportId, text, user, email, sent, date];

  @override
  bool get stringify => true;

  factory Report.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      throw StateError('missing data for reportId: $documentId');
    }
    final text = data['text'] as String;
    final user = data['user'] as String;
    final email = data['email'] as String;
    final sent = data['sent'] as bool;
    final Timestamp dateFirebase = data['date'] ?? Timestamp(0, 0);
    final date = dateFirebase.toDate();

    return Report(
      reportId: documentId,
      text: text,
      user: user,
      email: email,
      sent: sent,
      date: date,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'user': user,
      'email': email,
      'sent': sent,
      'date': date,
    };
  }
}
