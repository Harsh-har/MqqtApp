import 'package:flutter/material.dart';
import 'Qr_Screen.dart';

class AppDrawer extends StatefulWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final TextEditingController brokerController;
  final TextEditingController topicController;
  final TextEditingController ipController;
  final VoidCallback onSave;

  const AppDrawer({
    super.key,
    required this.usernameController,
    required this.passwordController,
    required this.brokerController,
    required this.topicController,
    required this.ipController,
    required this.onSave,
  });

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscure = false,
    TextInputType type = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const UserAccountsDrawerHeader(
            accountName: Text("Harsh Singhal"),
            accountEmail: Text("harsh@singhal.com"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Colors.blueAccent),
            ),
            decoration: BoxDecoration(color: Colors.blueAccent),
          ),

          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Home"),
            onTap: () {
              Navigator.pop(context);
            },
          ),

          // MQTT Settings
          ExpansionTile(
            leading: const Icon(Icons.settings),
            title: const Text("MQTT Settings"),
            children: [
              buildTextField(
                controller: widget.usernameController,
                label: "Username",
              ),
              buildTextField(
                controller: widget.passwordController,
                label: "Password",
                obscure: true,
              ),
              buildTextField(
                controller: widget.brokerController,
                label: "Broker ID",
              ),
              buildTextField(
                controller: widget.ipController,
                label: "Broker IP ",
                type: TextInputType.number,
              ),
              buildTextField(
                controller: widget.topicController,
                label: "Topic",
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text("Save"),
                  onPressed: () {
                    widget.onSave();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("🔄 Settings saved")),
                    );
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),

          ListTile(
            leading: const Icon(Icons.qr_code),
            title: const Text("QR Code"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QrScannerScreen()),
              );
            },
          ),

          const Divider(),
        ],
      ),
    );
  }
}