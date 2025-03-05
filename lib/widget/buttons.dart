import 'package:flutter/material.dart';

class ElevatedButtonCustom extends StatelessWidget {
  String text; // 버튼 텍스트
  Color backgroundColor; // 버튼 배경 색상
  Color textColor; // 버튼 텍스트 색상
  Function onPressed; // 버튼 클릭 신호

  ElevatedButtonCustom({
    super.key,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => onPressed.call(),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            4,
          ),
        ),
      ),
    );
  }
}