import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
          padding: const EdgeInsets.all(10),
          width: 50,
          height: 50,
          decoration:
              const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
          child: const CircularProgressIndicator(
            color: AppColors.primaryColor,
          )),
    );
  }
}
