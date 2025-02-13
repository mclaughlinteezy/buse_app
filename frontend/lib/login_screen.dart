import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences for storing the API key
import 'transaction_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final String apiUrl = "http://192.168.69.206:8000/api/login/";

  Future<void> login() async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": _usernameController.text,
        "password": _passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      // Parse the response body to get the API key
      final data = jsonDecode(response.body);
      final apiKey = data['api_key'];

      if (apiKey != null) {
        // Store the API key securely using shared preferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('api_key', apiKey);

        // Navigate to the next screen after successful login
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TransactionScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to get API key")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid credentials")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Gradient
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal.shade400, Colors.teal.shade100],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Login Form
          Align(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 100),

                  // Profile Placeholder
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade300,
                    child: Icon(Icons.person, size: 60, color: Colors.grey.shade700),
                  ),

                  SizedBox(height: 20),

                  // Sign In Text
                  Text(
                    "Sign In",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: 20),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      children: [
                        // Username Field
                        TextField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: "Username",
                            filled: true,
                            fillColor: Colors.grey.shade200,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        SizedBox(height: 10),

                        // Password Field
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: "Password",
                            filled: true,
                            fillColor: Colors.grey.shade200,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        SizedBox(height: 10),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: Text("Forgot Your Password?"),
                          ),
                        ),

                        SizedBox(height: 10),

                        // Sign In Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal.shade700,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text("Sign in", style: TextStyle(fontSize: 18, color: Colors.white)),
                          ),
                        ),

                        SizedBox(height: 30),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
