import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/theme/colors.dart';

class CustomSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Function(String) onSubmitted;
  final VoidCallback? onClear;

  const CustomSearchField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.onSubmitted,
    this.onClear,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45.h,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(25.r),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(color: AppColors.textPrimary, fontSize: 14.sp),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
          prefixIcon: Icon(Icons.search, color: AppColors.textSecondary, size: 20.sp),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: AppColors.textSecondary, size: 20.sp),
                  onPressed: onClear,
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 15.w),
        ),
        onSubmitted: onSubmitted,
      ),
    );
  }
}
