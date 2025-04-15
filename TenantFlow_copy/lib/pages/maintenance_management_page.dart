import 'package:flutter/material.dart';
import 'package:tenantflow/components/my_button.dart';
import 'package:tenantflow/pages/login_page.dart';
import 'package:provider/provider.dart';
import 'tenant_provider.dart';

class MaintenanceManagementPage extends StatefulWidget {
  const MaintenanceManagementPage({super.key});

  @override
  _MaintenanceManagementPageState createState() => _MaintenanceManagementPageState();
}

class _MaintenanceManagementPageState extends State<MaintenanceManagementPage> {
  final _issueTypeController = TextEditingController();
  final _reportDateController = TextEditingController();
  bool _breakage = false;
  bool _workerCalled = false;
  int? _selectedTenantId;

  @override
  Widget build(BuildContext context) {
    final tenantProvider = Provider.of<TenantProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Maintenance Management', style: TextStyle(fontFamily: 'Poppins')),
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
                'Report Maintenance Issue',
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
              TextField(
                controller: _issueTypeController,
                decoration: InputDecoration(labelText: 'Issue Type', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _reportDateController,
                decoration: InputDecoration(labelText: 'Report Date', border: OutlineInputBorder()),
                onTap: () async {
                  DateTime? date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
                  if (date != null) _reportDateController.text = date.toIso8601String().split('T')[0];
                },
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Checkbox(
                    value: _breakage,
                    onChanged: (value) => setState(() => _breakage = value ?? false),
                  ),
                  const Text('Caused by Tenant Breakage', style: TextStyle(fontFamily: 'Poppins')),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: _workerCalled,
                    onChanged: (value) => setState(() => _workerCalled = value ?? false),
                  ),
                  const Text('Worker Called', style: TextStyle(fontFamily: 'Poppins')),
                ],
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  if (_selectedTenantId != null && _issueTypeController.text.isNotEmpty && _reportDateController.text.isNotEmpty) {
                    tenantProvider.addMaintenanceIssue(
                      _selectedTenantId!,
                      _issueTypeController.text,
                      DateTime.parse(_reportDateController.text),
                      _breakage,
                      _workerCalled,
                    );
                    _issueTypeController.clear();
                    _reportDateController.clear();
                    setState(() {
                      _breakage = false;
                      _workerCalled = false;
                      _selectedTenantId = null;
                    });
                  }
                },
                child: const Text('Add Issue', style: TextStyle(fontFamily: 'Poppins')),
              ),
              const SizedBox(height: 20),
              const Text(
                'Maintenance Records',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Poppins'),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Table(
                    border: TableBorder.all(),
                    columnWidths: const {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(2),
                      2: FlexColumnWidth(1),
                      3: FlexColumnWidth(1),
                      4: FlexColumnWidth(1),
                    },
                    children: [
                      TableRow(
                        children: [
                          const TableCell(child: Text('Tenant Name', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins'))),
                          const TableCell(child: Text('Issue Type', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins'))),
                          const TableCell(child: Text('Date Reported', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins'))),
                          const TableCell(child: Text('Breakage?', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins'))),
                          const TableCell(child: Text('Worker Called?', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins'))),
                        ],
                      ),
                      ...tenantProvider.maintenanceIssues.map((issue) {
                        final tenant = tenantProvider.tenants.firstWhere((t) => t.id == issue.tenantId);
                        return TableRow(
                          children: [
                            TableCell(child: Text(tenant.name, style: TextStyle(fontFamily: 'Poppins'))),
                            TableCell(child: Text(issue.issueType, style: TextStyle(fontFamily: 'Poppins'))),
                            TableCell(child: Text(issue.reportDate.toIso8601String().split('T')[0], style: TextStyle(fontFamily: 'Poppins'))),
                            TableCell(child: Text(issue.breakage ? 'Yes' : 'No', style: TextStyle(fontFamily: 'Poppins'))),
                            TableCell(child: Text(issue.workerCalled ? 'Yes' : 'No', style: TextStyle(fontFamily: 'Poppins'))),
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