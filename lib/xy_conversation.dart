import 'xy_chat_message.dart';
import 'xy_local_llm_plugin.dart';

class Conversation {
  final XyLocalLlmPlugin _llm = XyLocalLlmPlugin();
  final List<ChatMessage> messages = [];

  bool isRunning = false;

  Future<void> sendMessage(String text) async {
    // Add user message
    messages.add(ChatMessage(text, true));

    // Generate AI response
    final history = messages
        .map((m) => "${m.isUser ? 'User' : 'Assistant'}: ${m.text}")
        .join("\n");
    final prompt = "$history\nUser: $text\nAssistant:";
    _llm.generate(prompt);
    String? response;
    isRunning = true;

    // Add initial empty AI message
    messages.add(ChatMessage("", false));
    while (isRunning) {
      response = await _llm.getOutput();
      await Future.delayed(
          const Duration(milliseconds: 100)); // Prevent tight loop
      isRunning =
          await _llm.isRunning(); // Use isRunning instead of isModelLoaded
      if (response != null && response.isNotEmpty) {
        print("Response: $response");
        // Update the last AI message
        final parts = response.split('<think>');
        messages.last.text = parts[0];
        if (parts.length > 1) {
          final thoughtParts = parts[1].split('</think>');
          messages.last.thought = thoughtParts[0];
          if (thoughtParts.length > 1) {
            messages.last.text += thoughtParts[1];
          }
        }
      }
    }
  }

  List<ChatMessage> getHistory() {
    return List.from(messages); // Return copy of messages
  }

  void clearHistory() {
    messages.clear();
  }
}
