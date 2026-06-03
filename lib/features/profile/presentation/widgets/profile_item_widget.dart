import 'package:flutter/material.dart';
import 'package:svg_flutter/svg.dart';

class ProfileItemWidget extends StatelessWidget {
  const ProfileItemWidget({
    super.key,
    this.onTap,
    required this.title,
    required this.icon,
    this.color,
  });
  final String title;
  final String icon;
  final Function()? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: SvgPicture.asset(
        icon,
        width: 24,
        height: 24,
        colorFilter: const ColorFilter.mode(Color(0xFF4AC2C5), BlendMode.srcIn), // Primary Color from the image approx
      ),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? const Color(0xFF2E2E2E), // Text color
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Color(0xFF8D8D8D),
      ),
    );
  }
}

