import 'package:flutter/material.dart';
import 'package:tenantflow/components/my_button.dart';
import 'package:tenantflow/pages/login_page.dart';
import 'package:provider/provider.dart';
import 'tenant_provider.dart';

class PaymentManagementPage extends StatefulWidget {
  const PaymentManagementPage({super.key});

  @override
  _PaymentManagementPageState createState() => _PaymentManagementPageState();
}

class _PaymentManagementPageState extends State<PaymentManagementPage> {
  final _submissionDateController = TextEditingController();
  final _idealDateController = TextEditingController();
  int? _selectedTenantId;

  @override
  Widget build(BuildContext context) {
    final tenantProvider = Provider.of<TenantProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Management', style: TextStyle(fontFamily: 'Poppins')),
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
                'Add Payment',
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
                controller: _submissionDateController,
                decoration: InputDecoration(labelText: 'Submission Date', border: OutlineInputBorder()),
                onTap: () async {
                  DateTime? date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
                  if (date != null) _submissionDateController.text = date.toIso8601String().split('T')[0];
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _idealDateController,
                decoration: InputDecoration(labelText: 'Ideal Date', border: OutlineInputBorder()),
                onTap: () async {
                  DateTime? date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
                  if (date != null) _idealDateController.text = date.toIso8601String().split('T')[0];
                },
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  if (_selectedTenantId != null && _submissionDateController.text.isNotEmpty && _idealDateController.text.isNotEmpty) {
                    tenantProvider.addPayment(
                      _selectedTenantId!,
                      DateTime.parse(_submissionDateController.text),
                      DateTime.parse(_idealDateController.text),
                    );
                    _submissionDateController.clear();
                    _idealDateController.clear();
                    setState(() => _selectedTenantId = null);
                  }
                },
                child: const Text('Add Payment', style: TextStyle(fontFamily: 'Poppins')),
              ),
              const SizedBox(height: 20),
              const Text(
                'Payment Records',
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
                    },
                    children: [
                      TableRow(
                        children: [
                          const TableCell(child: Text('Tenant Name', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins'))),
                          const TableCell(child: Text('Submission Date', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins'))),
                          const TableCell(child: Text('Ideal Date', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins'))),
                          const TableCell(child: Text('Days Late', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins'))),
                        ],
                      ),
                      ...tenantProvider.payments.map((payment) {
                        final tenant = tenantProvider.tenants.firstWhere((t) => t.id == payment.tenantId);
                        final diffDays = payment.submissionDate.difference(payment.idealDate).inDays;
                        return TableRow(
                          children: [
                            TableCell(child: Text(tenant.name, style: TextStyle(fontFamily: 'Poppins'))),
                            TableCell(child: Text(payment.submissionDate.toIso8601String().split('T')[0], style: TextStyle(fontFamily: 'Poppins'))),
                            TableCell(child: Text(payment.idealDate.toIso8601String().split('T')[0], style: TextStyle(fontFamily: 'Poppins'))),
                            TableCell(child: Text(diffDays > 0 ? '$diffDays' : 'On Time', style: TextStyle(fontFamily: 'Poppins'))),
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