class ChatMessage {
  String text;
  String thought;
  final bool isUser;

  ChatMessage(this.text, this.isUser, {this.thought = ""});
}
