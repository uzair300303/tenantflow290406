import 'package:flutter/material.dart';
import 'package:tenantflow/components/my_button.dart';
import 'package:tenantflow/pages/login_page.dart';
import 'package:provider/provider.dart';
import 'tenant_provider.dart';

class ServiceRatingPage extends StatefulWidget {
  const ServiceRatingPage({super.key});

  @override
  _ServiceRatingPageState createState() => _ServiceRatingPageState();
}

class _ServiceRatingPageState extends State<ServiceRatingPage> {
  final _raterIdController = TextEditingController();
  final _ratingController = TextEditingController();
  final _commentController = TextEditingController();
  String? _raterType;
  int? _selectedTenantId;

  @override
  Widget build(BuildContext context) {
    final tenantProvider = Provider.of<TenantProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Ratings', style: TextStyle(fontFamily: 'Poppins')),
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
                'Add Rating',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 10),
              DropdownButton<int>(
                value: _selectedTenantId,
                hint: const Text('Select a tenant', style: TextStyle(fontFamily: 'Poppins')),
                items: tenantProvider.tenants.map((tenant) {
                  return DropdownMenuItem<int>(
                    value: tenant.id,
                    child: Text('${tenant.name} (ID: ${tenant.id})', style: TextStyle(fontFamily: 'Poppins')),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedTenantId = value),
              ),
              const SizedBox(height: 10),
              DropdownButton<String>(
                value: _raterType,
                hint: const Text('Select Rater', style: TextStyle(fontFamily: 'Poppins')),
                items: ['worker', 'neighbor', 'owner', 'guard', 'community', 'servant'].map((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type[0].toUpperCase() + type.substring(1), style: TextStyle(fontFamily: 'Poppins')),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _raterType = value),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _raterIdController,
                decoration: InputDecoration(labelText: 'Rater ID', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _ratingController,
                decoration: InputDecoration(labelText: 'Rating (0-5)', border: OutlineInputBorder()),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _commentController,
                decoration: InputDecoration(labelText: 'Comment', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  if (_selectedTenantId != null && _raterType != null && _raterIdController.text.isNotEmpty && _ratingController.text.isNotEmpty) {
                    tenantProvider.addServiceRating(
                      _selectedTenantId!,
                      _raterType!,
                      double.parse(_ratingController.text),
                      _commentController.text,
                      _raterIdController.text,
                    );
                    _raterIdController.clear();
                    _ratingController.clear();
                    _commentController.clear();
                    setState(() {
                      _raterType = null;
                      _selectedTenantId = null;
                    });
                  }
                },
                child: const Text('Add Rating', style: TextStyle(fontFamily: 'Poppins')),
              ),
              const SizedBox(height: 20),
              const Text(
                'Rating Records',
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
                      4: FlexColumnWidth(2),
                    },
                    children: [
                      TableRow(
                        children: [
                          const TableCell(child: Text('Tenant Name', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins'))),
                          const TableCell(child: Text('Rater', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins'))),
                          const TableCell(child: Text('Rater ID', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins'))),
                          const TableCell(child: Text('Rating', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins'))),
                          const TableCell(child: Text('Comment', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins'))),
                        ],
                      ),
                      ...tenantProvider.serviceRatings.map((rating) {
                        final tenant = tenantProvider.tenants.firstWhere((t) => t.id == rating.tenantId);
                        return TableRow(
                          children: [
                            TableCell(child: Text(tenant.name, style: TextStyle(fontFamily: 'Poppins'))),
                            TableCell(child: Text(rating.raterType[0].toUpperCase() + rating.raterType.substring(1), style: TextStyle(fontFamily: 'Poppins'))),
                            TableCell(child: Text(rating.raterId ?? '-', style: TextStyle(fontFamily: 'Poppins'))),
                            TableCell(child: Text('${rating.rating}', style: TextStyle(fontFamily: 'Poppins'))),
                            TableCell(child: Text(rating.comment ?? '-', style: TextStyle(fontFamily: 'Poppins'))),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to Tenant Scoring', style: TextStyle(fontFamily: 'Poppins', color: Colors.blue)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}