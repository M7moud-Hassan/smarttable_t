import 'package:flutter/material.dart';

class ProfileItemWidget extends StatelessWidget {
  const ProfileItemWidget({
    super.key,
    this.onTap,
    required this.title,
    this.color,
  });
  final String title;
  final Function()? onTap;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(
          height: 0,
          color: Color(0XFFCBD4D9),
        ),
        ListTile(
          onTap: onTap,
          contentPadding: EdgeInsets.zero,
          title: Text(
            title,
            style: TextStyle(color: color),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 18,
            color: color,
          ),
        ),
        const Divider(
          height: 0,
          color: Color(0XFFCBD4D9),
        ),
      ],
    );
  }
}
