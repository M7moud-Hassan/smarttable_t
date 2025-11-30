import 'package:flutter/material.dart';
import 'package:smart_table_app/core/constants/constants.dart';

class AppThemes {
  ThemeData appTheme() {
    final baseTheme = ThemeData.light(
      useMaterial3: true,
    );

    final textTheme = baseTheme.textTheme
        .copyWith(
            headlineLarge: baseTheme.textTheme.headlineLarge?.copyWith(
              fontSize: 32,
            ),
            titleLarge: baseTheme.textTheme.titleLarge?.copyWith(
              fontSize: 24,
            ),
            bodyLarge: baseTheme.textTheme.bodyLarge?.copyWith(fontSize: 17))
        .apply(
          fontFamily: AppAssets.arFont,
        );
    return baseTheme.copyWith(
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        iconTheme: IconThemeData(color: Colors.black),
        color: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(
            color: AppColors.appbarTextColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: AppAssets.arFont),
      ),
      colorScheme: ThemeData.light().colorScheme.copyWith(
          primary: AppColors.primaryColor, secondary: AppColors.secondryColor),
      scaffoldBackgroundColor: Colors.white,
      radioTheme: RadioThemeData(
          fillColor: WidgetStateProperty.all<Color>(AppColors.primaryColor)),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.primaryColor),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          fixedSize: const Size(500, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          textStyle: ThemeData.light()
              .textTheme
              .titleMedium!
              .copyWith(fontFamily: AppAssets.arFont, fontSize: 24),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0XFF4B4949),
          textStyle: baseTheme.textTheme.bodyMedium!.copyWith(
              color: const Color(0XFF4B4949),
              fontSize: 20,
              fontFamily: AppAssets.arFont),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          fixedSize: const Size(500, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          side: const BorderSide(color: Colors.black, width: 0.5),
          elevation: 0,
          textStyle: ThemeData.light().textTheme.titleMedium!.copyWith(
              fontFamily: AppAssets.arFont,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 30,
        selectedLabelStyle: TextStyle(fontSize: 15),
        unselectedLabelStyle: TextStyle(fontSize: 15),
      ),
    );
  }
}
