import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class CreateBillScreen extends StatefulWidget {
  const CreateBillScreen({super.key});
  @override
  State<CreateBillScreen> createState() => _CreateBillScreenState();
}

class _CreateBillScreenState extends State<CreateBillScreen> {
  final _customerCtrl = TextEditingController();
  final _itemNameCtrl = TextEditingController();
  final _hsnCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _taxCtrl = TextEditingController(text: "5"); // Default tax 5%

  List<Map<String, dynamic>> items = [];

  void _addItem() {
    if (_itemNameCtrl.text.isEmpty || _qtyCtrl.text.isEmpty || _priceCtrl.text.isEmpty) return;
    
    double qty = double.parse(_qtyCtrl.text);
    double price = double.parse(_priceCtrl.text);
    double tax = double.tryParse(_taxCtrl.text) ?? 0;
    double baseAmount = qty * price;
    double taxAmount = baseAmount * (tax / 100);
    double finalAmount = baseAmount + taxAmount;

    setState(() {
      items.add({
        'name': _itemNameCtrl.text,
        'hsn': _hsnCtrl.text.isEmpty ? "0000" : _hsnCtrl.text,
        'qty': qty,
        'price': price,
        'tax': tax,
        'amount': finalAmount,
      });
    });

    _itemNameCtrl.clear(); _hsnCtrl.clear(); _qtyCtrl.clear(); _priceCtrl.clear();
  }

  double get totalBillAmount {
    double total = 0;
    for (var item in items) { total += item['amount']; }
    return total;
  }

  Future<void> _saveBillToDatabase(String invoiceNo, double total) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedData = prefs.getString('saved_bills');
    List bills = savedData != null ? json.decode(savedData) : [];
    
    bills.add({
      'invoice': invoiceNo,
      'date': DateFormat('dd-MMM-yyyy').format(DateTime.now()),
      'customer': _customerCtrl.text.isEmpty ? 'Cash' : _customerCtrl.text,
      'total': total,
      'items': items,
    });
    
    await prefs.setString('saved_bills', json.encode(bills));
  }

  Future<void> _generatePdf() async {
    if (items.isEmpty) return;
    
    final pdf = pw.Document();
    String invoiceNo = "INV/${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}";
    String dateStr = DateFormat('dd-MMM-yyyy').format(DateTime.now());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header Box (Like the image)
              pw.Container(
                decoration: pw.BoxDecoration(border: pw.Border.all()),
                child: pw.Column(
                  children: [
                    pw.Container(
                      width: double.infinity,
                      color: PdfColors.grey300,
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Center(child: pw.Text("TAX INVOICE", style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text("REHAN TRADERS", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                    pw.Text("Main Market, New Delhi, 110001, India"),
                    pw.Text("GSTIN: 07AABCU9603R1ZX | Mob: +91 9876543210"),
                    pw.SizedBox(height: 10),
                    pw.Divider(),
                    pw.Row(
                      children: [
                        pw.Expanded(
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text("Billing Details:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                                pw.Text(_customerCtrl.text.isEmpty ? "Cash Customer" : _customerCtrl.text),
                              ]
                            )
                          )
                        ),
                        pw.Container(width: 1, height: 50, color: PdfColors.black), // Vertical line
                        pw.Expanded(
                          child: pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text("Invoice No: $invoiceNo"),
                                pw.Text("Date: $dateStr"),
                              ]
                            )
                          )
                        ),
                      ]
                    )
                  ]
                )
              ),
              pw.SizedBox(height: 10),
              
              // Professional Table
              pw.Table.fromTextArray(
                border: pw.TableBorder.all(),
                headers: ['Sr.', 'Item Description', 'HSN/SAC', 'Qty', 'Rate', 'Tax %', 'Amount (Rs)'],
                data: List.generate(items.length, (index) {
                  final item = items[index];
                  return [
                    (index + 1).toString(),
                    item['name'],
                    item['hsn'],
                    item['qty'].toString(),
                    item['price'].toStringAsFixed(2),
                    item['tax'].toString(),
                    item['amount'].toStringAsFixed(2)
                  ];
                }),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.black),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
                cellAlignments: {0: pw.Alignment.center, 1: pw.Alignment.centerLeft, 2: pw.Alignment.center, 3: pw.Alignment.center, 4: pw.Alignment.centerRight, 5: pw.Alignment.center, 6: pw.Alignment.centerRight},
              ),
              
              // Total Row
              pw.Container(
                decoration: pw.BoxDecoration(border: pw.Border.all(), color: PdfColors.grey200),
                padding: const pw.EdgeInsets.all(5),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("Grand Total:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text(totalBillAmount.toStringAsFixed(2), style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ]
                )
              ),
              pw.SizedBox(height: 10),
              
              // Bottom Section (Terms & Bank)
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(5),
                      decoration: pw.BoxDecoration(border: pw.Border.all()),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text("Terms and Conditions", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                          pw.Text("1. Goods once sold will not be taken back.\n2. Interest @ 18% p.a. if not paid on time.\n3. Subject to Delhi jurisdiction.", style: const pw.TextStyle(fontSize: 8)),
                        ]
                      )
                    )
                  ),
                  pw.SizedBox(width: 5),
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(5),
                      decoration: pw.BoxDecoration(border: pw.Border.all()),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text("Bank Details", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                          pw.Text("Account: 123456789012\nBank: HDFC Bank\nIFSC: HDFC0001234", style: const pw.TextStyle(fontSize: 9)),
                        ]
                      )
                    )
                  ),
                  pw.SizedBox(width: 5),
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(5),
                      decoration: pw.BoxDecoration(border: pw.Border.all()),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text("For REHAN TRADERS", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                          pw.SizedBox(height: 30),
                          pw.Text("Auth. Signatory", style: const pw.TextStyle(fontSize: 10)),
                        ]
                      )
                    )
                  )
                ]
              )
            ]
          );
        }
      )
    );

    // Save logic
    await _saveBillToDatabase(invoiceNo, totalBillAmount);
    
    // Print/Preview
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save(), name: 'Invoice_$invoiceNo.pdf');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New Invoice")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _customerCtrl, decoration: const InputDecoration(labelText: "Customer/Company Name", border: OutlineInputBorder(), fillColor: Colors.white, filled: true)),
            const SizedBox(height: 10),
            
            // Easy Input Box
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(flex: 2, child: TextField(controller: _itemNameCtrl, decoration: const InputDecoration(labelText: "Item", isDense: true))),
                        const SizedBox(width: 10),
                        Expanded(flex: 1, child: TextField(controller: _hsnCtrl, decoration: const InputDecoration(labelText: "HSN", isDense: true))),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: _qtyCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Qty", isDense: true))),
                        const SizedBox(width: 10),
                        Expanded(child: TextField(controller: _priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Price", isDense: true))),
                        const SizedBox(width: 10),
                        Expanded(child: TextField(controller: _taxCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Tax %", isDense: true))),
                        IconButton(icon: const Icon(Icons.add_box, color: Color(0xFF1E3A8A), size: 40), onPressed: _addItem)
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Item List
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (ctx, i) => Card(
                  child: ListTile(
                    title: Text(items[i]['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Qty: ${items[i]['qty']} | ₹${items[i]['price']} | Tax: ${items[i]['tax']}%"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("₹${items[i]['amount'].toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                        IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => items.removeAt(i))),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Print Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A), padding: const EdgeInsets.all(15)),
                icon: const Icon(Icons.print, color: Colors.white),
                label: Text("GENERATE INVOICE (Total: ₹$totalBillAmount)", style: const TextStyle(color: Colors.white, fontSize: 16)),
                onPressed: _generatePdf,
              ),
            )
          ],
        ),
      ),
    );
  }
}
