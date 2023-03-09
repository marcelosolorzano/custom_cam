import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTheme {
  static Color primaryColor = const Color(0xFF004691);
  static Color secondaryColor = const Color(0xFFF18700);
  static Color backgroundColor = const Color(0xFFFFFFFF);

  static ButtonStyle textButtonStyle = TextButton.styleFrom(
      foregroundColor: Colors.white,
      disabledForegroundColor: primaryColor,
      backgroundColor: primaryColor,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6.0)
      ),
      textStyle: TextStyle(
        fontFamily: 'IBMPlexSans',
        fontSize: 16.sp,
        fontWeight: FontWeight.w600
      )
  );

  static ButtonStyle circularButtonStyle = TextButton.styleFrom(
      foregroundColor: Colors.white,
      disabledForegroundColor: primaryColor,
      backgroundColor: primaryColor,
      shape: const CircleBorder(),
      textStyle: TextStyle(
        fontFamily: 'IBMPlexSans',
        fontSize: 16.sp,
        fontWeight: FontWeight.w600
      )
  );
}