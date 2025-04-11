import 'dart:convert';
import 'dart:io';

import 'package:chat_bot_app/model/chatbot.model.dart';
import  'package:http/http.dart' as http;

class ChatBotRepository{
  Future<Message> askLargeLangugeModel(String query) async{

    var url = "https://openrouter.ai/api/v1/chat/completions";

    Map<String, String> headers = {
                        "Content-Type": 'application/json',
                        "Authorization": 'Bearer xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
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

    try{
      http.Response response=await http.post(Uri.parse(url), headers: headers, body: json.encode(prompt));
      if(response.statusCode == 200){

        Map<String,dynamic> result = jsonDecode(response.body);
        Message message = Message(message: result["choices"][0]['message']['content'], type: "assistant");
        return message;
      }else{
        return throw("Error ${response.statusCode}");
      }

    }catch(error){
      return throw("Error ${error.toString()}");
    }
    
  }
}

