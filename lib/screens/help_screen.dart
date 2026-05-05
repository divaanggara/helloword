import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pusat Bantuan", style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.teal),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          ListTile(leading: Icon(Icons.chat, color: Colors.teal), title: Text("Chat dengan CS"), subtitle: Text("Online 24 Jam")),
          Divider(),
          ListTile(leading: Icon(Icons.question_answer, color: Colors.teal), title: Text("FAQ"), subtitle: Text("Pertanyaan yang sering diajukan")),
          Divider(),
          ListTile(leading: Icon(Icons.email, color: Colors.teal), title: Text("Kirim Email"), subtitle: Text("support@foodapp.com")),
        ],
      ),
    );
  }
}