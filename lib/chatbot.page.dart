import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatbotPage extends StatefulWidget {
  ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  List messages = [
    {"message": "Hello 👋 \nHow can I help you?", "type": "assistant"},
  ];

  TextEditingController queryController = TextEditingController();
  ScrollController scrollController = ScrollController();

  void scrollToBottom() {
    Future.delayed(Duration(milliseconds: 300), () {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent + 100,
        duration: Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          "ChatBot",
          style: TextStyle(
            color: Theme.of(context).indicatorColor,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: ListView.builder(
                controller: scrollController,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  bool isUser = messages[index]['type'] == "user";
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 4),
                      padding: EdgeInsets.all(12),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                      decoration: BoxDecoration(
                        color: isUser
                            ? const Color.fromARGB(255, 220, 255, 220)
                            : const Color.fromARGB(255, 240, 240, 240),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                          bottomLeft: Radius.circular(isUser ? 16 : 0),
                          bottomRight: Radius.circular(isUser ? 0 : 16),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          )
                        ],
                      ),
                      child: Text(
                        messages[index]['message'],
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Divider(height: 1, thickness: 1, color: Colors.grey[300]),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: queryController,
                    decoration: InputDecoration(
                      hintText: "Enter a message...",
                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 1,
                          color: Theme.of(context).primaryColor,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: () {
                      String query = queryController.text.trim();
                      if (query.isEmpty) return;

                      setState(() {
                        messages.add({"message": query, "type": "user"});
                      });

                      queryController.text = "";

                      var MetaAiLLMUri = Uri.parse("https://openrouter.ai/api/v1/chat/completions");
                      Map<String, String> headers = {
                        "Content-Type": 'application/json',
                        "Authorization": 'Bearer ######',
                      };

                      var prompt = {
                        "model": "meta-llama/llama-4-maverick:free",
                        "messages": [
                          {
                            "role": "user",
                            "content": query,
                          }
                        ]
                      };

                      http.post(MetaAiLLMUri, headers: headers, body: json.encode(prompt)).then((resp) {
                        var llmResponse = json.decode(resp.body);
                        if (llmResponse["choices"] == null) {
                          print("Erreur détectée dans la réponse !");
                          return;
                        }

                        String responseContent = llmResponse["choices"][0]['message']['content'];
                        setState(() {
                          messages.add({"message": responseContent, "type": "assistant"});
                        });
                        scrollToBottom();
                      });
                    },
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
