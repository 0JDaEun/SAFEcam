import 'package:flutter/material.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  String title;
  bool isLeading; // 백버튼 존재 여부
  // 물음표가 들어가는 것들은 있을수도 있고 없을수도 있는 것, 물음표가 없으면 무조건 있는것
  Function? onTapBackButton; // 뒤로가기 버튼 액션 정의
  List<Widget>? actions; // 앱바 우측에 버튼들 필요할 때 정의

  // required는 반드시 있어야 하는거, 없으면 있어도 없어도 되는거
  CommonAppBar({
    super.key,
    required this.title,
    required this.isLeading,
    this.actions,
    this.onTapBackButton,
  });

  // 앱바의 기본적인 사이즈 어떻게 설정할거냐
  @override
  Size get preferredSize => Size.fromHeight(AppBar().preferredSize.height);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 48,
      // 백버튼 자동으로 만들어줄까?
      automaticallyImplyLeading: isLeading,
      titleSpacing: isLeading ? 0 : 16,
      scrolledUnderElevation: 3,
      backgroundColor: Colors.white,
      leading: isLeading
          ? GestureDetector(
        child: Icon(
          Icons.arrow_back,
          color: Colors.black,
        ),
        onTap: () {
          // onTapBackButton 유무에 따라
          onTapBackButton != null
              ? onTapBackButton!.call()
              : Navigator.pop(context);
        },
      )
          : null,
      elevation: 1,
      actions: actions,
      // 있다면 왼쪽 없다면 오른쪽
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.black,
        ),
      ),
    );
  }
}