import 'package:flutter/material.dart';
import 'NavigationDrawer_Screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();


  final List<Map<String, dynamic>> messages = [
    {"text": "Hi there!", "sentByMe": false},
    {"text": "Hello! How are you?", "sentByMe": true},
    {"text": "I'm good, thanks!", "sentByMe": false},
  ];

  void sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      messages.add({"text": _controller.text.trim(), "sentByMe": true});
      _controller.clear();
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat App"),
        backgroundColor: Colors.blueAccent,
      ),

      drawer: const AppDrawer(),

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
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 14),
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      color: msg["sentByMe"]
                          ? Colors.blueAccent
                          : Colors.grey[300],
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(12),
                        topRight: const Radius.circular(12),
                        bottomLeft: msg["sentByMe"]
                            ? const Radius.circular(12)
                            : const Radius.circular(0),
                        bottomRight: msg["sentByMe"]
                            ? const Radius.circular(0)
                            : const Radius.circular(12),
                      ),
                    ),
                    child: Text(
                      msg["text"],
                      style: TextStyle(
                        color:
                        msg["sentByMe"] ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),


          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
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
