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

  final TextEditingController ipController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController brokerController = TextEditingController();
  final TextEditingController topicController = TextEditingController();

  MqttServerClient? client;
  bool isConnected = false;
  late String clientId;

  final List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();

    brokerController.text = '192.168.1.200';
    topicController.text = 'test';
    usernameController.text = 'Swajahome';
    passwordController.text = '12345678';
    clientId = 'flutter_client_${DateTime.now().millisecondsSinceEpoch}';
    connectMQTT();
  }

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

    client = MqttServerClient(broker, clientId);
    client!.port = 1883;
    client!.logging(on: true);
    client!.keepAlivePeriod = 20;
    client!.onDisconnected = onDisconnected;
    client!.onConnected = onConnected;
    client!.onSubscribed = onSubscribed;

    client!.connectionMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean()
        .authenticateAs(username, password)
        .withWillTopic('willtopic')
        .withWillMessage('Client disconnected unexpectedly')
        .withWillQos(MqttQos.atLeastOnce);

    try {
      if (username.isNotEmpty && password.isNotEmpty) {
        await client!.connect(username, password);
      } else {
        await client!.connect();
      }
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
        final rawPayload = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

        // Extract clean message text (remove any client IDs)
        final cleanMessage = _extractCleanMessage(rawPayload);

        // Check if this is our own message by comparing with sent messages
        final isMyMessage = _isMyOwnMessage(cleanMessage);

        if (!isMyMessage) {
          setState(() {
            messages.add({"text": cleanMessage, "sentByMe": false});
          });

          Future.delayed(const Duration(milliseconds: 100), () {
            if (_scrollController.hasClients) {
              _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
            }
          });
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("MQTT Connection failed")),
      );
      client!.disconnect();
    }
  }

  String _extractCleanMessage(String rawPayload) {
    // Remove any client ID prefixes (format: "clientId:message")
    final colonIndex = rawPayload.indexOf(':');
    if (colonIndex != -1 && colonIndex < rawPayload.length - 1) {
      return rawPayload.substring(colonIndex + 1).trim();
    }
    return rawPayload;
  }

  bool _isMyOwnMessage(String message) {
    // Check if this message was recently sent by us
    return messages.any((msg) => msg["sentByMe"] == true && msg["text"] == message);
  }

  void onConnected() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Connected to MQTT Broker")),
      );
    }
  }

  void onDisconnected() {
    if (mounted) {
      setState(() => isConnected = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Disconnected from MQTT Broker")),
      );
    }
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
    // Send only the clean message
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
        title: Center(child: const Text("MQTT Chat App",style: TextStyle(color: Colors.white),)),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(isConnected ? Icons.wifi : Icons.wifi_off, color: Colors.white),
            onPressed: connectMQTT,
          )
        ],
      ),
      drawer: AppDrawer(
        usernameController: usernameController,
        passwordController: passwordController,
        brokerController: brokerController,
        topicController: topicController,
        ipController: ipController,
        onSave: connectMQTT,
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
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
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
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            color: Colors.white,
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        controller: _controller,
                        minLines: 1,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: "Type a message...",
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.blueAccent,
                    child: IconButton(
                      icon: const Icon(Icons.send, size: 18, color: Colors.white),
                      onPressed: sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}