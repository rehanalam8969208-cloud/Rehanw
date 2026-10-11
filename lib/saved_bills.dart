import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SavedBillsScreen extends StatefulWidget {
  const SavedBillsScreen({super.key});
  @override
  State<SavedBillsScreen> createState() => _SavedBillsScreenState();
}

class _SavedBillsScreenState extends State<SavedBillsScreen> {
  List bills = [];

  @override
  void initState() {
    super.initState();
    _loadBills();
  }

  _loadBills() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedData = prefs.getString('saved_bills');
    if (savedData != null) {
      setState(() {
        bills = json.decode(savedData).reversed.toList(); // Naye bills upar dikhenge
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Saved Invoices")),
      body: bills.isEmpty 
        ? const Center(child: Text("No bills saved yet."))
        : ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: bills.length,
            itemBuilder: (ctx, i) {
              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: const CircleAvatar(backgroundColor: Color(0xFF1E3A8A), child: Icon(Icons.receipt, color: Colors.white)),
                  title: Text(bills[i]['customer'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${bills[i]['invoice']} • ${bills[i]['date']}"),
                  trailing: Text("₹${bills[i]['total'].toStringAsFixed(2)}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
                  onTap: () {
                    // Future detail view options
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Total items in this bill: ${bills[i]['items'].length}")));
                  },
                ),
              );
            },
          ),
    );
  }
}
