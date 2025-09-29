import 'package:flutter/material.dart';
import 'package:task/Qr_Screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

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
                title: const Text("IN",style: TextStyle(color: Colors.green),),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text("OUT",style: TextStyle(color: Colors.red),),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),

          ExpansionTile(
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            children: [
              ListTile(
                title: const Text("Mqqt User Name"),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text("Password"),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text("Broker Id"),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text("Ip"),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),

          ListTile(
            leading: const Icon(Icons.document_scanner),
            title: const Text("QR Scanner"),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => QrScannerScreen(),));
            },
          ),

          const Divider(),
        ],
      ),
    );
  }
}
