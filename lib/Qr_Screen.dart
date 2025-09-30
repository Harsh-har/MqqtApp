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
  bool isProcessing = false;

  // --- NEW FUNCTION TO PARSE WIFI STRING ---
  Map<String, String> parseWifiQr(String qrData) {
    final Map<String, String> data = {};

    // 1. Remove the "WIFI:" prefix and trailing semicolons
    String cleanData = qrData.replaceFirst('WIFI:', '').replaceAll(';;', '');

    // 2. Split by semicolon to get key-value pairs
    final parts = cleanData.split(';');

    for (var part in parts) {
      if (part.isNotEmpty && part.contains(':')) {
        // 3. Extract key (S, P, T, H) and value
        final key = part[0];
        final value = part.substring(2);

        data[key] = value;
      }
    }


    return {
      'ssid': data['S'] ?? '',
      'password': data['P'] ?? '',
      'security': data['T'] ?? '',
    };
  }


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
                if (code == null || !code.startsWith("WIFI:")) return;

                isProcessing = true;
                scannedResult = code;
                setState(() {});

                try {
                  final wifiData = parseWifiQr(scannedResult!);
                  final ssid = wifiData["ssid"];
                  final password = wifiData["password"];


                  final securityType = NetworkSecurity.WPA;


                  if (ssid == null || ssid.isEmpty) {
                    throw Exception("SSID not found in QR code.");
                  }

                  bool connected = await WiFiForIoTPlugin.connect(
                    ssid,
                    password: password,
                    joinOnce: true,
                    security: securityType,
                  );

                  if (connected) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("✅ WiFi Connected Successfully!")),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("❌ Connection Failed. Check password/security.")),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Parsing/Connection Error: ${e.toString()}")),
                  );
                } finally {
                  await Future.delayed(const Duration(seconds: 3));
                  isProcessing = false;
                }
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: scannedResult != null
                    ? Text("Scanned: $scannedResult", textAlign: TextAlign.center)
                    : const Text("Scan a WiFi QR Code"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}