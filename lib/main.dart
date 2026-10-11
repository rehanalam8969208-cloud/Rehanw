import 'package:flutter/material.dart';
import 'create_bill.dart';
import 'saved_bills.dart';

void main() {
  runApp(const RehanBillingApp());
}

class RehanBillingApp extends StatelessWidget {
  const RehanBillingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rehan Billing',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF1E3A8A), // Dark Blue
        scaffoldBackgroundColor: const Color(0xFFF3F4F6),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E3A8A),
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("REHAN TRADERS")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Text("Welcome to Billing System", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)), textAlign: TextAlign.center),
            const SizedBox(height: 50),
            _buildBigButton(
              context, 
              icon: Icons.receipt_long, 
              title: "Create New Tax Invoice", 
              subtitle: "Generate professional wholesaler bill",
              color: const Color(0xFF1E3A8A),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateBillScreen()))
            ),
            const SizedBox(height: 20),
            _buildBigButton(
              context, 
              icon: Icons.folder_special, 
              title: "Saved Bills History", 
              subtitle: "View & reprint old invoices",
              color: const Color(0xFF00796B),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SavedBillsScreen()))
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBigButton(BuildContext context, {required IconData icon, required String title, required String subtitle, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.5), width: 2),
          boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))]
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
                  const SizedBox(height: 5),
                  Text(subtitle, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color)
          ],
        ),
      ),
    );
  }
}
