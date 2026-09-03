import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/theme/colors.dart';

class CustomText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const CustomText({
    Key? key,
    required this.text,
    this.fontSize = 14,
    this.fontWeight = FontWeight.normal,
    this.color = AppColors.textPrimary,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: TextStyle(
        fontSize: fontSize.sp,
        fontWeight: fontWeight,
        color: color,
        // fontFamily: 'Inter', // Default if configured
      ),
    );
  }
}
