import 'package:flutter/material.dart';
import 'package:tenantflow/components/my_button.dart';
import 'package:tenantflow/pages/login_page.dart';
import 'package:provider/provider.dart';
import 'tenant_provider.dart';
import 'payment_management_page.dart';
import 'maintenance_management_page.dart';
import 'service_rating_page.dart';

class TenantProfilePage extends StatefulWidget {
  const TenantProfilePage({super.key});

  @override
  _TenantProfilePageState createState() => _TenantProfilePageState();
}

class _TenantProfilePageState extends State<TenantProfilePage> {
  final TextEditingController _tenantNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final tenantProvider = Provider.of<TenantProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tenant Profile Scoring', style: TextStyle(fontFamily: 'Poppins')),
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Theme.of(context).scaffoldBackgroundColor, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add New Tenant',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _tenantNameController,
                decoration: InputDecoration(
                  labelText: 'Enter tenant name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  if (_tenantNameController.text.isNotEmpty) {
                    tenantProvider.addTenant(_tenantNameController.text);
                    _tenantNameController.clear();
                  }
                },
                child: const Text('Add Tenant', style: TextStyle(fontFamily: 'Poppins')),
              ),
              const SizedBox(height: 20),
              const Text(
                'Tenant Scores',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Poppins'),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Table(
                    border: TableBorder.all(),
                    columnWidths: const {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(1),
                      2: FlexColumnWidth(1),
                      3: FlexColumnWidth(1),
                      4: FlexColumnWidth(1),
                      5: FlexColumnWidth(1),
                      6: FlexColumnWidth(2),
                    },
                    children: [
                      TableRow(
                        children: [
                          const TableCell(child: Text('Name', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins'))),
                          const TableCell(child: Text('Payment Rating', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins'))),
                          const TableCell(child: Text('Maintenance Rating', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins'))),
                          const TableCell(child: Text('Service Rating', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins'))),
                          const TableCell(child: Text('Total Score', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins'))),
                          const TableCell(child: Text('Trend', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins'))),
                          const TableCell(child: Text('Rewards/Penalties', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins'))),
                        ],
                      ),
                      ...tenantProvider.tenants.map((tenant) {
                        final trend = tenant.score > tenant.previousScore ? '↑' : tenant.score < tenant.previousScore ? '↓' : '–';
                        final trendColor = tenant.score > tenant.previousScore ? Colors.green : tenant.score < tenant.previousScore ? Colors.red : Colors.grey;
                        return TableRow(
                          children: [
                            TableCell(child: Text(tenant.name, style: TextStyle(fontFamily: 'Poppins'))),
                            TableCell(child: Text('${tenant.paymentRating}', style: TextStyle(fontFamily: 'Poppins'))),
                            TableCell(child: Text('${tenant.maintenanceRating}', style: TextStyle(fontFamily: 'Poppins'))),
                            TableCell(child: Text('${tenant.serviceRating.toStringAsFixed(1)}', style: TextStyle(fontFamily: 'Poppins'))),
                            TableCell(child: Text('${tenant.score}', style: TextStyle(fontFamily: 'Poppins'))),
                            TableCell(child: Text(trend, style: TextStyle(fontFamily: 'Poppins', color: trendColor))),
                            TableCell(child: Text(tenantProvider.suggestRewardsOrPenalties(tenant.score), style: TextStyle(fontFamily: 'Poppins'))),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentManagementPage())),
                    child: const Text('Manage Payments', style: TextStyle(fontFamily: 'Poppins', color: Colors.blue)),
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MaintenanceManagementPage())),
                    child: const Text('Manage Maintenance', style: TextStyle(fontFamily: 'Poppins', color: Colors.blue)),
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ServiceRatingPage())),
                    child: const Text('Manage Service Ratings', style: TextStyle(fontFamily: 'Poppins', color: Colors.blue)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}