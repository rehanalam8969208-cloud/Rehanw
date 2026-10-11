import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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
        primaryColor: const Color(0xFF1E3A8A), // Professional Dark Blue
        scaffoldBackgroundColor: const Color(0xFFF3F4F6),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E3A8A),
          centerTitle: true,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      home: const BillingScreen(),
    );
  }
}

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  final TextEditingController _customerNameCtrl = TextEditingController();
  final TextEditingController _itemNameCtrl = TextEditingController();
  final TextEditingController _qtyCtrl = TextEditingController();
  final TextEditingController _priceCtrl = TextEditingController();

  List<Map<String, dynamic>> items = [];

  void _addItem() {
    if (_itemNameCtrl.text.isEmpty || _qtyCtrl.text.isEmpty || _priceCtrl.text.isEmpty) return;
    
    setState(() {
      items.add({
        'name': _itemNameCtrl.text,
        'qty': int.parse(_qtyCtrl.text),
        'price': double.parse(_priceCtrl.text),
      });
    });

    // Clear item inputs after adding
    _itemNameCtrl.clear();
    _qtyCtrl.clear();
    _priceCtrl.clear();
  }

  void _deleteItem(int index) {
    setState(() {
      items.removeAt(index);
    });
  }

  double get grandTotal {
    double total = 0;
    for (var item in items) {
      total += (item['qty'] * item['price']);
    }
    return total;
  }

  // 🔥 YAHAN PROFESSIONAL PDF GENERATE HOGI 🔥
  Future<void> _generateAndPrintPDF() async {
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please add at least one item!")));
      return;
    }

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("REHAN'S ENTERPRISES", style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
                  pw.Text("INVOICE", style: pw.TextStyle(fontSize: 26, color: PdfColors.grey600)),
                ]
              ),
              pw.SizedBox(height: 20),
              
              // Customer Details
              pw.Text("Customer Name: ${_customerNameCtrl.text.isEmpty ? 'Cash Customer' : _customerNameCtrl.text}", style: pw.TextStyle(fontSize: 16)),
              pw.Text("Date: ${DateTime.now().toString().split(' ')[0]}", style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700)),
              pw.SizedBox(height: 30),
              
              // Invoice Table
              pw.Table.fromTextArray(
                headers: ['S.No', 'Item Description', 'Qty', 'Rate (Rs)', 'Total (Rs)'],
                data: List.generate(items.length, (index) {
                  final item = items[index];
                  return [
                    (index + 1).toString(),
                    item['name'],
                    item['qty'].toString(),
                    item['price'].toStringAsFixed(2),
                    (item['qty'] * item['price']).toStringAsFixed(2)
                  ];
                }),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
                cellHeight: 35,
                cellAlignments: {
                  0: pw.Alignment.center,
                  1: pw.Alignment.centerLeft,
                  2: pw.Alignment.center,
                  3: pw.Alignment.center,
                  4: pw.Alignment.centerRight,
                }
              ),
              pw.Divider(thickness: 2),
              
              // Grand Total
              pw.Container(
                alignment: pw.Alignment.centerRight,
                child: pw.Text("Grand Total: Rs ${grandTotal.toStringAsFixed(2)}", style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold))
              ),
              
              pw.Spacer(),
              // Footer
              pw.Divider(),
              pw.Center(child: pw.Text("Thank you for doing business with us!", style: pw.TextStyle(fontStyle: pw.FontStyle.italic, color: PdfColors.grey600))),
            ]
          );
        }
      )
    );

    // Seedha preview, print aur share ka option open karega
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Rehan_Invoice_${DateTime.now().millisecondsSinceEpoch}.pdf'
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Bill")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Customer Name Box
            TextField(
              controller: _customerNameCtrl,
              decoration: InputDecoration(
                labelText: "Customer Name",
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 15),

            // Item Input Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300)
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _itemNameCtrl,
                    decoration: const InputDecoration(labelText: "Item Name", isDense: true),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _qtyCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: "Quantity", isDense: true),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: TextField(
                          controller: _priceCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: "Price (₹)", isDense: true),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle, color: Color(0xFF1E3A8A), size: 35),
                        onPressed: _addItem,
                      )
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),

            // Items List
            Expanded(
              child: items.isEmpty 
                ? const Center(child: Text("No items added yet.", style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          title: Text(items[index]['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("Qty: ${items[index]['qty']}  x  ₹${items[index]['price']}"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("₹${items[index]['qty'] * items[index]['price']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteItem(index)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
            ),

            // Generate Bill Button
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 10),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                ),
                icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                label: Text("GENERATE & PRINT BILL (₹$grandTotal)", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                onPressed: _generateAndPrintPDF,
              ),
            )
          ],
        ),
      ),
    );
  }
}
