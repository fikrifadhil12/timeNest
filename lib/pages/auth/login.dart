import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image or Icon at the top
              Image.asset(
                'assets/2.png', // Path harus sesuai dengan struktur folder
                height: 250,
                width: 550,
              ),
              SizedBox(height: 30),

              // Email TextField
              TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[200],
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 15),

              // Password TextField
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[200],
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Login Button
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/home');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors
                      .orange, // Gunakan backgroundColor sebagai pengganti primary
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding:
                      EdgeInsets.symmetric(vertical: 15.0, horizontal: 80.0),
                ),
                child: Text(
                  'Login',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),

              SizedBox(height: 10),

              // Register Link
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(
                      context, '/register'); // Navigate to register page
                },
                child: Text(
                  "Don't have an account? Register",
                  style: TextStyle(color: Colors.orange, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
