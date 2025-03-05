import 'package:flutter/material.dart';

// 섹션 제목 텍스트
class SectionText extends StatelessWidget {
  String text;
  Color textColor;
  SectionText({super.key, required this.text, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.bold
      ),
    );
  }
}


/// 읽기 전용 텍스트
class ReadOnlyText extends StatelessWidget {
  String title;
  ReadOnlyText({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 2),
            borderRadius: BorderRadius.circular(4),
          )
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          title,
          style:const TextStyle(fontSize: 16, color: Colors.black),
        ),
      ),
    );
  }
}