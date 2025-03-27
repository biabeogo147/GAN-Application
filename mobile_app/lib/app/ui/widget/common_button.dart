import 'package:flutter/material.dart';
import 'package:mobile_app/app/res/font/app_fonts.dart';
import 'package:mobile_app/app/ui/theme/app_colors.dart';

class CommonButton extends MaterialButton {
  final String? title;
  final double? maxWidth;
  final double? minWidth;
  final double? height;
  final double? textSize;
  final double? elevation;
  final String? fontFamily;

  const CommonButton({
    super.key,
    required VoidCallback onPressed,
    Color? textColor,
    Color? color,
    this.title,
    this.maxWidth,
    this.minWidth,
    this.height,
    this.textSize,
    this.elevation,
    this.fontFamily,
    Widget? child,
    ShapeBorder? shape,
    EdgeInsetsGeometry? padding,
  }) : super(
          onPressed: onPressed,
          textColor: textColor,
          color: color,
          child: child,
          shape: shape,
          padding: padding,
        );

  @override
  Widget build(BuildContext context) {
    final ButtonThemeData buttonTheme = ButtonTheme.of(context);
    return RawMaterialButton(
      onPressed: onPressed,
      fillColor: color ?? AppColors.primary,
      elevation: elevation ?? 0,
      constraints: color != Colors.transparent
          ? buttonTheme.getConstraints(this).copyWith(
              maxWidth: maxWidth ?? double.infinity,
              minWidth: minWidth ?? double.infinity,
              minHeight: height ?? 50,
              maxHeight: height ?? 50)
          : const BoxConstraints.tightFor(),
      padding: padding ?? const EdgeInsets.only(left: 10, right: 10),
      shape: shape ??
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
      child: child ??
          Text(
            title!,
            style: TextStyle(
                fontSize: textSize ?? 18,
                color: textColor ?? AppColors.white,
                fontFamily: fontFamily ?? AppFonts.robotoMedium),
          ),
    );
  }
}
