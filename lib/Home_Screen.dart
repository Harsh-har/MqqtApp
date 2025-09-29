import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'NavigationDrawer_Screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController brokerController = TextEditingController();
  final TextEditingController topicController = TextEditingController();


  MqttServerClient? client;
  bool isConnected = false;


  final List<Map<String, dynamic>> messages = [];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    brokerController.dispose();
    topicController.dispose();
    client?.disconnect();
    super.dispose();
  }


  Future<void> connectMQTT() async {
    final broker = brokerController.text.trim();
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();
    final topic = topicController.text.trim();

    if (broker.isEmpty || topic.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Broker and Topic are required")),
      );
      return;
    }

    client = MqttServerClient(broker, 'flutter_client_${DateTime.now().millisecondsSinceEpoch}');
    client!.port = 1883;
    client!.logging(on: false);
    client!.keepAlivePeriod = 20;
    client!.onDisconnected = onDisconnected;
    client!.onConnected = onConnected;
    client!.onSubscribed = onSubscribed;

    client!.connectionMessage = MqttConnectMessage()
        .withClientIdentifier('flutter_client_${DateTime.now().millisecondsSinceEpoch}')
        .startClean()
        .authenticateAs(username, password)
        .withWillTopic('willtopic')
        .withWillMessage('My Will message')
        .withWillQos(MqttQos.atLeastOnce);

    try {
      await client!.connect();
    } catch (e) {
      client!.disconnect();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('MQTT Connect Error: $e')),
      );
      return;
    }

    if (client!.connectionStatus!.state == MqttConnectionState.connected) {
      setState(() => isConnected = true);
      client!.subscribe(topic, MqttQos.atLeastOnce);

      client!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final recMess = c[0].payload as MqttPublishMessage;
        final pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

        setState(() {
          messages.add({"text": pt, "sentByMe": false});
        });


        Future.delayed(const Duration(milliseconds: 100), () {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          }
        });
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("MQTT Connection failed")),
      );
      client!.disconnect();
    }
  }

  void onConnected() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Connected to MQTT Broker")),
    );
  }

  void onDisconnected() {
    setState(() => isConnected = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("⚠️ Disconnected from MQTT Broker")),
    );
  }

  void onSubscribed(String topic) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Subscribed to $topic")),
    );
  }

  void sendMessage() {
    if (_controller.text.trim().isEmpty || !isConnected) return;

    final text = _controller.text.trim();
    final topic = topicController.text.trim();

    final builder = MqttClientPayloadBuilder();
    builder.addString(text);
    client?.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);

    setState(() {
      messages.add({"text": text, "sentByMe": true});
      _controller.clear();
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MQTT Chat App"),
        backgroundColor: Colors.blueAccent,
      ),
      drawer: AppDrawer(
        usernameController: usernameController,
        passwordController: passwordController,
        brokerController: brokerController,
        topicController: topicController,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return Align(
                  alignment: msg["sentByMe"]
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      color: msg["sentByMe"] ? Colors.blueAccent : Colors.grey[300],
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(12),
                        topRight: const Radius.circular(12),
                        bottomLeft: msg["sentByMe"] ? const Radius.circular(12) : const Radius.circular(0),
                        bottomRight: msg["sentByMe"] ? const Radius.circular(0) : const Radius.circular(12),
                      ),
                    ),
                    child: Text(
                      msg["text"],
                      style: TextStyle(
                        color: msg["sentByMe"] ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
            color: Colors.grey[100],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blueAccent),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
