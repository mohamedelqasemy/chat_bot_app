import 'dart:convert';
import 'package:chat_bot_app/bloc/chatbot.bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

class ChatbotPage extends StatelessWidget {
  ChatbotPage({super.key});

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
          BlocBuilder<ChatbotBloc,ChatBotState>(
            builder: (context, state) {
              if (state is ChatBotPenddingState){
                return CircularProgressIndicator();
              }
              else if (state is ChatBotErrorState){
                return Column(
                  children: [
                    Text(state.errorMessage,style: TextStyle(color: Colors.red),),
                    ElevatedButton(
                      onPressed: () {
                        ChatBotEvent evt = context.read<ChatbotBloc>().lastchatBotEvent;
                        context.read<ChatbotBloc>().add(evt);
                      },
                      child: Text("Retry",))
                  ],
                );
              }
              else if(state is ChatBotSuccessState || state is ChatBotInitialState){
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: state.messages.length,
                      itemBuilder: (context, index) {
                        bool isUser = state.messages[index].type == "user";
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
                              state.messages[index].message,
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
                );
              }
              else{
                return Container();
              }
            },
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
                      String query = queryController.text;
                      context.read<ChatbotBloc>().add(AskLLMEvent(query: query));
                      queryController.text="";
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
