import 'package:flutter/material.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Variabel untuk switch Login/Register
  bool isLogin = true;

  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. BACKGROUND MAKANAN (Sesuai syarat kemarin)
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1504674900247-0877df9cc836?q=80&w=1000&auto=format&fit=crop'),
                fit: BoxFit.cover,
              ),
            ),
          ),
     
          Container(color: Colors.black.withOpacity(0.3)),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTabButton("login", isLogin),
                      const SizedBox(width: 40),
                      _buildTabButton("register", !isLogin),
                    ],
                  ),
                  const SizedBox(height: 50),

                  if (!isLogin) _buildLabel("full name"),
                  if (!isLogin) _buildPinkInput(_nameController),
                  
                  _buildLabel("email"),
                  _buildPinkInput(_userController),
                  
                  _buildLabel("password"),
                  _buildPinkInput(_passController, isPass: true),

                  const SizedBox(height: 40),

                  GestureDetector(
                    onTap: () {
                      if (isLogin) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => HomeScreen(username: _userController.text.split('@')[0])),
                        );
                      } else {
                        setState(() => isLogin = true);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Berhasil Daftar!")));
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: const Color(0xFFD88C9A), width: 3),
                      ),
                      child: Center(
                        child: Text(
                          isLogin ? "login" : "register",
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

       
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network('https://upload.wikimedia.org/wikipedia/commons/5/53/Google_%22G%22_Logo.svg', width: 25, height: 25, errorBuilder: (c, e, s) => const Icon(Icons.g_mobiledata, color: Colors.blue)),
                      const SizedBox(width: 10),
                      const Text("sign in", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text("continue with gogle", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, bool active) {
    return GestureDetector(
      onTap: () => setState(() => isLogin = (label == "login")),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: active ? Colors.black : Colors.black54,
          decoration: active ? TextDecoration.none : TextDecoration.none,
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.only(bottom: 5, left: 10),
      child: Text(text, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
    );
  }

  Widget _buildPinkInput(TextEditingController ctrl, {bool isPass = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFFDB4F2), // Warna pink screenshot
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(0, 6)), // Shadow bawah hitam tebal
        ],
      ),
      child: TextField(
        controller: ctrl,
        obscureText: isPass,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold),
        decoration: const InputDecoration(border: InputBorder.none),
      ),
    );
  }
}