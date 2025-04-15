import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'tenant_data.dart';

class TenantProvider with ChangeNotifier {
  List<Tenant> tenants = [];
  List<Payment> payments = [];
  List<MaintenanceIssue> maintenanceIssues = [];
  List<ServiceRating> serviceRatings = [];

  TenantProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    tenants = (jsonDecode(prefs.getString('tenants') ?? '[]') as List)
        .map((json) => Tenant.fromJson(json))
        .toList();
    payments = (jsonDecode(prefs.getString('payments') ?? '[]') as List)
        .map((json) => Payment.fromJson(json))
        .toList();
    maintenanceIssues = (jsonDecode(prefs.getString('maintenanceIssues') ?? '[]') as List)
        .map((json) => MaintenanceIssue.fromJson(json))
        .toList();
    serviceRatings = (jsonDecode(prefs.getString('serviceRatings') ?? '[]') as List)
        .map((json) => ServiceRating.fromJson(json))
        .toList();
    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('tenants', jsonEncode(tenants.map((t) => t.toJson()).toList()));
    prefs.setString('payments', jsonEncode(payments.map((p) => p.toJson()).toList()));
    prefs.setString('maintenanceIssues', jsonEncode(maintenanceIssues.map((m) => m.toJson()).toList()));
    prefs.setString('serviceRatings', jsonEncode(serviceRatings.map((s) => s.toJson()).toList()));
  }

  void addTenant(String name) {
    final tenant = Tenant(id: DateTime.now().millisecondsSinceEpoch, name: name);
    tenants.add(tenant);
    _saveData();
    notifyListeners();
  }

  void addPayment(int tenantId, DateTime submissionDate, DateTime idealDate) {
    payments.add(Payment(tenantId: tenantId, submissionDate: submissionDate, idealDate: idealDate));
    updateTenantRatings(tenantId);
    _saveData();
  }

  void addMaintenanceIssue(int tenantId, String issueType, DateTime reportDate, bool breakage, bool workerCalled) {
    maintenanceIssues.add(MaintenanceIssue(tenantId: tenantId, issueType: issueType, reportDate: reportDate, breakage: breakage, workerCalled: workerCalled));
    updateTenantRatings(tenantId);
    _saveData();
  }

  void addServiceRating(int tenantId, String raterType, double rating, String comment, String raterId) {
    serviceRatings.add(ServiceRating(tenantId: tenantId, raterType: raterType, rating: rating, comment: comment, raterId: raterId));
    updateTenantRatings(tenantId);
    _saveData();
  }

  int calculatePaymentRating(int tenantId) {
    final tenantPayments = payments.where((p) => p.tenantId == tenantId).toList();
    if (tenantPayments.isEmpty) return 0;
    int totalRating = 0;
    for (var payment in tenantPayments) {
      final diffDays = payment.submissionDate.difference(payment.idealDate).inDays;
      totalRating += diffDays > 0 ? 10 - diffDays : 10;
    }
    return (totalRating / tenantPayments.length).round();
  }

  int calculateMaintenanceRating(int tenantId) {
    final issues = maintenanceIssues.where((m) => m.tenantId == tenantId).toList();
    if (issues.isEmpty) return 10;
    final breakageCount = issues.where((m) => m.breakage).length;
    final workerCallCount = issues.where((m) => m.workerCalled).length;
    final totalIssues = issues.length;
    double rating = 10 - (breakageCount * 2) - (workerCallCount * 1) - (totalIssues * 0.5);
    return rating.clamp(0, 10).round();
  }

  double calculateServiceRating(int tenantId) {
    final ratings = serviceRatings.where((s) => s.tenantId == tenantId).toList();
    if (ratings.isEmpty) return 0;
    const weights = {'worker': 1, 'neighbor': 1.5, 'owner': 2, 'guard': 1, 'community': 1.5, 'servant': 1};
    double totalRating = 0;
    double totalWeight = 0;
    for (var rating in ratings) {
      final weight = weights[rating.raterType] ?? 1;
      totalRating += rating.rating * weight;
      totalWeight += weight;
    }
    return (totalRating / totalWeight).clamp(0, 5);
  }

  int calculateTotalScore(Tenant tenant) {
    final paymentRating = calculatePaymentRating(tenant.id);
    final maintenanceRating = calculateMaintenanceRating(tenant.id);
    final serviceRating = calculateServiceRating(tenant.id);
    int score = 50 + (paymentRating * 2) + (maintenanceRating * 2) + (serviceRating * 6).round();
    return score.clamp(0, 100);
  }

  String suggestRewardsOrPenalties(int score) {
    if (score >= 95) return "15% Gym Discount + Rent Freeze";
    if (score >= 85) return "10% Utility Discount + Free Parking";
    if (score >= 75) return "5% Utility Discount";
    if (score >= 65) return "No Change";
    if (score >= 55) return "Warning Notice";
    if (score >= 45) return "5% Rent Increase";
    if (score >= 35) return "10% Rent Increase + Warning";
    return "15% Rent Increase + Possible Eviction";
  }

  void updateTenantRatings(int tenantId) {
    final tenant = tenants.firstWhere((t) => t.id == tenantId);
    tenant.previousScore = tenant.score;
    tenant.paymentRating = calculatePaymentRating(tenantId);
    tenant.maintenanceRating = calculateMaintenanceRating(tenantId);
    tenant.serviceRating = calculateServiceRating(tenantId);
    tenant.score = calculateTotalScore(tenant);
    _saveData();
    notifyListeners();
  }
}