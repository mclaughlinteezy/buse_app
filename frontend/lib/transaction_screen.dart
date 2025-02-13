import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'add_transaction_screen.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class TransactionScreen extends StatefulWidget {
  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  List transactions = [];
  String searchQuery = "";
  bool isAscending = true;
  int sortColumnIndex = 1;
  final String apiUrl = "http://127.0.0.1:8000/api/transactions/";
  final String apiKey = "your_static_api_key_here"; // Static API key from Django settings

  Future<void> fetchTransactions() async {
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'ApiKey $apiKey', // Add API Key in the request header
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        transactions = jsonDecode(response.body);
      });
    }
  }

  Future<void> printTransactions() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Transaction Report", style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: ["Client", "Currency", "Amount", "Description", "Date"],
                data: transactions.map((transaction) => [
                  transaction['client'].toString(),
                  transaction['currency'].toString(),
                  "\$${transaction['amount']?.toString() ?? "0.0"}",
                  transaction['description'].toString(),
                  transaction['date'].toString(),
                ]).toList(),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  void sortData(int columnIndex, bool ascending) {
    setState(() {
      sortColumnIndex = columnIndex;
      isAscending = ascending;
      transactions.sort((a, b) {
        if (columnIndex == 2) { // Sorting Amount column
          double aAmount = (a['amount'] is num) ? (a['amount'] as num).toDouble() : 0.0;
          double bAmount = (b['amount'] is num) ? (b['amount'] as num).toDouble() : 0.0;
          return ascending ? aAmount.compareTo(bAmount) : bAmount.compareTo(aAmount);
        }
        var aValue = columnIndex == 0 ? a['client'] : a['date'];
        var bValue = columnIndex == 0 ? b['client'] : a['date'];
        return ascending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
      });
    });
  }

  void showTransactionDetails(Map<String, dynamic> transaction) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "Transaction Details",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Divider(),
              _buildDetailRow("Client", transaction['client'].toString()),
              _buildDetailRow("Currency", transaction['currency'].toString()),
              _buildDetailRow("Amount", "\$${transaction['amount']?.toString() ?? '0.0'}"),
              _buildDetailRow("Description", transaction['description'].toString()),
              _buildDetailRow("Date", transaction['date'].toString()),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context); // Close the modal
                  },
                  icon: Icon(Icons.close),
                  label: Text("Close"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(value, style: TextStyle(color: Colors.grey[700])),
        ],
      ),
    );
  }

  double calculateTotalAmount() {
    return transactions.fold(0.0, (sum, transaction) {
      double amount = (transaction['amount'] is num) ? (transaction['amount'] as num).toDouble() : 0.0;
      return sum + amount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        actions: [
          CircleAvatar(
            backgroundImage: AssetImage("assets/buse.png"), // Ensure this image exists in assets
          ),
          SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome Back!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text("Hi, Admin", style: TextStyle(fontSize: 16, color: Colors.grey)),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard("Transactions", transactions.length.toString(), Icons.bar_chart),
                _buildStatCard("Total Amount", calculateTotalAmount().toStringAsFixed(2), Icons.account_balance_wallet),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    printTransactions();
                  },
                  icon: Icon(Icons.print),
                  label: Text("Print"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
                SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.filter_list),
                  label: Text("Filter"),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Search...",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: DataTable(
                    columnSpacing: 20,
                    sortColumnIndex: sortColumnIndex,
                    sortAscending: isAscending,
                    columns: [
                      DataColumn(
                        label: Text("Client"),
                        onSort: (columnIndex, ascending) => sortData(columnIndex, ascending),
                      ),
                      DataColumn(
                        label: Text("Currency"),
                        onSort: (columnIndex, ascending) => sortData(columnIndex, ascending),
                      ),
                      DataColumn(
                        label: Text("Amount"),
                        onSort: (columnIndex, ascending) => sortData(columnIndex, ascending),
                      ),
                      DataColumn(
                        label: Text("Description"),
                        onSort: (columnIndex, ascending) => sortData(columnIndex, ascending),
                      ),
                      DataColumn(
                        label: Text("Date"),
                        onSort: (columnIndex, ascending) => sortData(columnIndex, ascending),
                      ),
                      DataColumn(label: Text("Action")),
                    ],
                    rows: transactions
                        .where((transaction) =>
                        transaction["client"].toString().toLowerCase().contains(searchQuery.toLowerCase()))
                        .map(
                          (transaction) => DataRow(cells: [
                        DataCell(Text(transaction['client'].toString())),
                        DataCell(Text(transaction['currency'].toString())),
                        DataCell(Text("\$${transaction['amount']?.toString() ?? "0.0"}")),
                        DataCell(Text(transaction['description'].toString())),
                        DataCell(Text(transaction['date'].toString())),
                        DataCell(
                          IconButton(
                            icon: Icon(Icons.visibility),
                            onPressed: () {
                              showTransactionDetails(transaction);
                            },
                          ),
                        ),
                      ]),
                    )
                        .toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bool? transactionAdded = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTransactionScreen()),
          );
          if (transactionAdded == true) {
            fetchTransactions();
          }
        },
        child: Icon(Icons.add, size: 30),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Expanded(
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, size: 30, color: Colors.deepPurple),
              SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                value,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
