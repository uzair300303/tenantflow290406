import 'dart:convert';

class Tenant {
  final int id;
  String name;
  int paymentRating;
  int maintenanceRating;
  double serviceRating;
  int score;
  int previousScore;

  Tenant({
    required this.id,
    required this.name,
    this.paymentRating = 0,
    this.maintenanceRating = 0,
    this.serviceRating = 0,
    this.score = 50,
    this.previousScore = 50,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'paymentRating': paymentRating,
    'maintenanceRating': maintenanceRating,
    'serviceRating': serviceRating,
    'score': score,
    'previousScore': previousScore,
  };

  factory Tenant.fromJson(Map<String, dynamic> json) => Tenant(
    id: json['id'],
    name: json['name'],
    paymentRating: json['paymentRating'],
    maintenanceRating: json['maintenanceRating'],
    serviceRating: json['serviceRating'],
    score: json['score'],
    previousScore: json['previousScore'],
  );
}

class Payment {
  final int tenantId;
  final DateTime submissionDate;
  final DateTime idealDate;

  Payment({required this.tenantId, required this.submissionDate, required this.idealDate});

  Map<String, dynamic> toJson() => {
    'tenantId': tenantId,
    'submissionDate': submissionDate.toIso8601String(),
    'idealDate': idealDate.toIso8601String(),
  };

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
    tenantId: json['tenantId'],
    submissionDate: DateTime.parse(json['submissionDate']),
    idealDate: DateTime.parse(json['idealDate']),
  );
}

class MaintenanceIssue {
  final int tenantId;
  final String issueType;
  final DateTime reportDate;
  final bool breakage;
  final bool workerCalled;

  MaintenanceIssue({
    required this.tenantId,
    required this.issueType,
    required this.reportDate,
    required this.breakage,
    required this.workerCalled,
  });

  Map<String, dynamic> toJson() => {
    'tenantId': tenantId,
    'issueType': issueType,
    'reportDate': reportDate.toIso8601String(),
    'breakage': breakage,
    'workerCalled': workerCalled,
  };

  factory MaintenanceIssue.fromJson(Map<String, dynamic> json) => MaintenanceIssue(
    tenantId: json['tenantId'],
    issueType: json['issueType'],
    reportDate: DateTime.parse(json['reportDate']),
    breakage: json['breakage'],
    workerCalled: json['workerCalled'],
  );
}

class ServiceRating {
  final int tenantId;
  final String raterType;
  final double rating;
  final String? comment;
  final String? raterId;

  ServiceRating({
    required this.tenantId,
    required this.raterType,
    required this.rating,
    this.comment,
    this.raterId,
  });

  Map<String, dynamic> toJson() => {
    'tenantId': tenantId,
    'raterType': raterType,
    'rating': rating,
    'comment': comment,
    'raterId': raterId,
  };

  factory ServiceRating.fromJson(Map<String, dynamic> json) => ServiceRating(
    tenantId: json['tenantId'],
    raterType: json['raterType'],
    rating: json['rating'],
    comment: json['comment'],
    raterId: json['raterId'],
  );
}