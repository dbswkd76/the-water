//auther: Jeong JuHa
//Date: 2025.04.09
//Description: 로딩 버블
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
class LoadingBubble extends StatelessWidget {
  const LoadingBubble({super.key});

  @override
  Widget build(BuildContext context) {
    final maxBubbleWidth = MediaQuery.of(context).size.width * 0.7;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin:  EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        padding: EdgeInsets.all(12.0), 
        constraints: BoxConstraints(
          maxWidth: maxBubbleWidth,
        ),
        decoration: BoxDecoration(
          color:Color.fromARGB(255, 220, 233, 231),
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        child: SpinKitSpinningLines(
          color: Color(0xFF176B87),
          size: 45.0,
        ),
      ),
    );
  }
}
