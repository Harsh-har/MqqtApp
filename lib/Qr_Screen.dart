import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:wifi_iot/wifi_iot.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  String? scannedResult;
  bool isProcessing = false; // Prevent multiple scans

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("QR Scanner")),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: MobileScanner(
              onDetect: (capture) async {
                if (isProcessing) return;

                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isEmpty) return;

                final String? code = barcodes.first.rawValue;
                if (code == null) return;

                isProcessing = true;
                scannedResult = code;

                try {
                  final wifiData = jsonDecode(scannedResult!);
                  final ssid = wifiData["ssid"];
                  final password = wifiData["password"];

                  bool connected = await WiFiForIoTPlugin.connect(
                    ssid,
                    password: password,
                    joinOnce: true,
                    security: NetworkSecurity.WPA,
                  );

                  if (connected) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("✅ WiFi Connected Successfully!")),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("❌ Connection Failed")),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: $e")),
                  );
                } finally {
                  await Future.delayed(const Duration(seconds: 2));
                  isProcessing = false;
                }
                setState(() {}); // Update scannedResult text
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: scannedResult != null
                  ? Text("Scanned: $scannedResult")
                  : const Text("Scan a WiFi QR Code"),
            ),
          ),
        ],
      ),
    );
  }
}
