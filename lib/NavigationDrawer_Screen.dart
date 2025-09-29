import 'package:flutter/material.dart';
import 'package:task/Qr_Screen.dart';

class AppDrawer extends StatefulWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final TextEditingController brokerController;
  final TextEditingController topicController;

  const AppDrawer({
    super.key,
    required this.usernameController,
    required this.passwordController,
    required this.brokerController,
    required this.topicController,
  });

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: const Text("Harsh Singhal"),
            accountEmail: const Text("harsh@singhal.com"),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Colors.blueAccent),
            ),
            decoration: const BoxDecoration(
              color: Colors.blueAccent,
            ),
          ),

          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Home"),
            onTap: () {
              Navigator.pop(context);
            },
          ),

          ExpansionTile(
            leading: const Icon(Icons.topic),
            title: const Text("Topics"),
            children: [
              ListTile(
                title: const Text("IN", style: TextStyle(color: Colors.green)),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text("OUT", style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),

          ExpansionTile(
            leading: const Icon(Icons.settings),
            title: const Text("MQTT Settings"),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextField(
                  controller: widget.usernameController,
                  decoration: const InputDecoration(
                    labelText: "Username",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextField(
                  controller: widget.passwordController,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextField(
                  controller: widget.brokerController,
                  decoration: const InputDecoration(
                    labelText: "Broker ID / Host",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextField(
                  controller: widget.topicController,
                  decoration: const InputDecoration(
                    labelText: "Topic",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close drawer
                  },
                  child: const Text("Save Settings"),
                ),
              ),
            ],
          ),

          ListTile(
            leading: const Icon(Icons.document_scanner),
            title: const Text("QR Scanner"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const QrScannerScreen()),
              );
            },
          ),

          const Divider(),
        ],
      ),
    );
  }
}
