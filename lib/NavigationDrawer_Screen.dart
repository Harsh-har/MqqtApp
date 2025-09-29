import 'package:flutter/material.dart';

class AppDrawer extends StatefulWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final TextEditingController brokerController;
  final TextEditingController topicController;
  final VoidCallback onSave; // 🔹 callback for settings save

  const AppDrawer({
    super.key,
    required this.usernameController,
    required this.passwordController,
    required this.brokerController,
    required this.topicController,
    required this.onSave,
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
                  obscureText: true,
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
                    widget.onSave();
                    Navigator.pop(context);
                  },
                  child: const Text("Save & Reconnect"),
                ),
              ),
            ],
          ),

          const Divider(),
        ],
      ),
    );
  }
}