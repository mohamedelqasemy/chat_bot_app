import 'package:chat_bot_app/model/chatbot.model.dart';
import 'package:chat_bot_app/repository/chatbot.repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ChatBotEvent {}

class AskLLMEvent extends ChatBotEvent {
  final String query;
  AskLLMEvent({required this.query});
}

abstract class ChatBotState{
  final List<Message> messages;
  ChatBotState({required this.messages});
}


class ChatBotPenddingState extends ChatBotState{
  ChatBotPenddingState({required super.messages});
}

class ChatBotSuccessState extends ChatBotState{
  ChatBotSuccessState({required super.messages});
}

class ChatBotErrorState extends ChatBotState{
  final String errorMessage;
  ChatBotErrorState({required super.messages,required this.errorMessage});
}


class ChatBotInitialState extends ChatBotState{
  ChatBotInitialState():super(messages: [
    Message(message: "Hello 👋 \nHow can I help you?", type: "assistant"),
  ]);
}


class ChatbotBloc extends Bloc<ChatBotEvent,ChatBotState>{
  final ChatBotRepository chatBotRepository = ChatBotRepository();
  late ChatBotEvent lastchatBotEvent;
  ChatbotBloc():super(ChatBotInitialState()){    
    on((AskLLMEvent event , emit) async {
      print("AskLLMEvent occured");
      lastchatBotEvent = event;
      List<Message> currentMessages = state.messages;
      emit(ChatBotPenddingState(messages: state.messages));
      currentMessages.add(Message(message: event.query, type: "user"));
      try{
        Message responseMessage = await chatBotRepository.askLargeLangugeModel(event.query);
        currentMessages.add(responseMessage);
        emit(ChatBotSuccessState(messages: currentMessages));
      }
      catch(err){
        emit(ChatBotErrorState(messages: state.messages, errorMessage: err.toString()));
      }
    });

  }
}








