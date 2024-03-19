
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class DiagnosisCommunitaryCrenamByRegionAndDateInform extends Equatable {

  DiagnosisCommunitaryCrenamByRegionAndDateInform({
    required this.category,
    required this.red,
    required this.yellow,
    required this.green,
    required this.oedema
  });

  final String category;
  int red;
  int yellow;
  int green;
  int oedema;

  @override
  List<Object> get props => [
    category ?? "",
    red ?? 0,
    yellow ?? 0,
    green ?? 0,
    oedema ?? 0
  ];

  @override
  bool get stringify => true;

  factory DiagnosisCommunitaryCrenamByRegionAndDateInform.fromMap(Map<String, dynamic>? data, String documentId) {
    if (data == null) {
      throw StateError('missing data for contractId: $documentId');
    }

    final category = data['category'] ?? "";
    final red = data['red'] ?? 0;
    final yellow = data['yellow'] ?? 0;
    final green = data['green'] ?? 0;
    final oedema = data['oedema'] ?? 0;

    return DiagnosisCommunitaryCrenamByRegionAndDateInform(
      category: category,
      red: red,
      yellow: yellow,
      green: green,
      oedema: oedema
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'red': red,
      'yellow': yellow,
      'green': green,
      'oedema': oedema
    };
  }

}

