import 'package:flutter/material.dart';

class TextFormFieldCustom extends StatefulWidget {
  String? defalutText; // 기본적으로 미리 쓰여지는 텍트 ㅡ값
  String? hintText; // 입력에 힌트가 되는 텍스트 설정 값
  bool isPasswordField = false; // 비밀번호 입력필드인지 여부
  bool? isEnabled; // 텍스트 필드 활성화 여부
  int? maxLines; // 최대 줄 길이
  bool isReadOnly; // 읽기 전용 입력필드인지 여부
  TextInputType keyboardType; // 키보드 입력 타입
  TextInputAction textInputAction; // 키보드 액션 타입
  FormFieldValidator validator; // 유효성 검사
  TextEditingController controller;
  Function(String value)? onFieldSubmitted; // 키보드에서 액션 결과 값을 받는 콜백
  Function()? onTap;


  TextFormFieldCustom({
    this.defalutText,
    this.hintText,
    required this.isPasswordField,
    this.isEnabled,
    this.maxLines,
    required this.isReadOnly,
    required this.keyboardType,
    required this.textInputAction,
    required this.validator,
    required this.controller,
    this.onFieldSubmitted,
    this.onTap,
    super.key,
  });

  @override
  State<TextFormFieldCustom> createState() => _TextFormFieldCustomState();
}

class _TextFormFieldCustomState extends State<TextFormFieldCustom> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: widget.defalutText,
      validator: (value) => widget.validator(value),
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      enabled: widget.isEnabled,
      readOnly: widget.isReadOnly,
      onTap: widget.isReadOnly ? widget.onTap : null,
      maxLines: widget.maxLines,
      onFieldSubmitted: widget.onFieldSubmitted,
      decoration: InputDecoration(

        /// 그냥 border 값을 어떻게 할것인가
        border: OutlineInputBorder(
          borderSide: BorderSide(
            width: 4,
            color: Colors.black,
          ),
          borderRadius: BorderRadius.circular(4),
        ),

        /// 활성화된 ui에 대해서 border 값을 어떻게 할것인가
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            width: 2,
            color: Color(0xff70b9db),
          ),
          borderRadius: BorderRadius.circular(4),
        ),

        /// 에러시 border 어떻게
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            width: 2,
            color: Colors.redAccent,
          ),
          borderRadius: BorderRadius.circular(4),
        ),

        /// 선택시 border
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            width: 2,
            color: Colors.blueAccent,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        hintText: widget.hintText,
      ),
      obscureText: widget.isPasswordField,
    );
  }
}