//auther: Jeong JuHa
//Date: 2025.04.09
//Description: 메시지 버블
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/material.dart';
class MessageBubble extends StatelessWidget {
  final String text;
  final bool isUser;

  const MessageBubble({super.key, required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) {
    final maxBubbleWidth = MediaQuery.of(context).size.width * 0.7;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        padding: const EdgeInsets.all(12.0),
        constraints: BoxConstraints(
          maxWidth: maxBubbleWidth,
        ),
        decoration: BoxDecoration(
          color: isUser ? Color.fromARGB(255, 184, 195, 193):Color.fromARGB(255, 220, 233, 231),
          borderRadius: BorderRadius.circular(16),
        ),
        child:MarkdownBody(data: text) 
      ),
    );
  }
}
