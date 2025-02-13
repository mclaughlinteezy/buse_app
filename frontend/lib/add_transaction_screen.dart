import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddTransactionScreen extends StatefulWidget {
  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController clientController = TextEditingController();
  final TextEditingController currencyController = TextEditingController(text: "USD");
  final TextEditingController emailController = TextEditingController();

  final String apiUrl = "http://127.0.0.1:8000/api/transactions/";

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        dateController.text = "${picked.year}-${picked.month}-${picked.day}"; // Adjusted format
      });
    }
  }

  Future<void> addTransaction() async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "amount": double.parse(amountController.text),
        "description": descriptionController.text,
        "date": dateController.text,
        "client": clientController.text,
        "currency": currencyController.text,
        "email": emailController.text,
      }),
    );

    if (response.statusCode == 201) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add transaction")),
      );
    }
  }

  Widget _buildTextField(
      {required TextEditingController controller,
        required String label,
        bool readOnly = false,
        Widget? suffixIcon}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 4,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("Add Transaction"),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Add Transaction",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text("Add", style: TextStyle(color: Colors.grey)),

            SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: descriptionController,
                    label: "Description",
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    controller: clientController,
                    label: "Client",
                  ),
                ),
              ],
            ),

            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: currencyController,
                    label: "Currency",
                    readOnly: true,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _buildTextField(
                    controller: dateController,
                    label: "Date",
                    readOnly: true,
                    suffixIcon: IconButton(
                      icon: Icon(Icons.calendar_today, color: Colors.grey),
                      onPressed: () => _selectDate(context),
                    ),
                  ),
                ),
              ],
            ),

            _buildTextField(controller: amountController, label: "Amount"),
            _buildTextField(controller: emailController, label: "Email"),

            SizedBox(height: 30),

            Center(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: addTransaction,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                    backgroundColor: Colors.purple.shade100,
                    elevation: 0,
                  ),
                  child: Text(
                    "Add Transaction",
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
