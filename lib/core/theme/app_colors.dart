import 'package:flutter/material.dart';

/// Brand palette aligned with the_boss_app.html mockup.
class AppColors {
  static const orange = Color(0xFFFF7900);
  static const orangeDark = Color(0xFFE56A00);
  static const orangeLight = Color(0xFFFFF3E8);
  static const orangeBorder = Color(0xFFFFD9B3);
  static const ink = Color(0xFF000000);
  static const black = ink;
  static const cloud = Color(0xFFF2F2F2);
  static const grey900 = Color(0xFF2D2D2D);
  static const grey600 = Color(0xFF8F8F8F);
  static const grey400 = Color(0xFF9CA3AF);
  static const grey200 = Color(0xFFE4E4E4);
  static const grey100 = Color(0xFFEBEBEB);
  static const white = Color(0xFFFFFFFF);
  static const error = Color(0xFFD6382B);
  static const success = Color(0xFF50BE87);
  static const successBg = Color(0xFFE2F5EC);
  static const successDark = Color(0xFF1E9963);
  static const yellow = Color(0xFFFFD200);
  static const blue = Color(0xFF4BB4E6);
  static const pink = Color(0xFFFFB4E6);
  static const purple = Color(0xFFA885D8);
}

class AppTextStyles {
  static const logo = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w800,
    color: AppColors.ink,
    letterSpacing: -0.5,
    height: 1.1,
  );

  static const tagline = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.orange,
    height: 1.4,
  );

  static const h1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
    letterSpacing: -0.4,
    height: 1.25,
  );

  static const h2 = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  static const muted = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.grey600,
    height: 1.55,
  );

  static const small = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.grey600,
    height: 1.45,
  );

  static const button = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
  );

  static const link = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.orange,
  );
}
