import 'package:flutter/material.dart';
import 'package:mobile_app/app/ui/theme/app_colors.dart';

class HeaderButton extends StatelessWidget {
  final String? icon;
  final Color? iconColor;
  final Function? onPressed;
  final Widget? childWidget;
  final double? iconWidth;
  final double? iconHeight;
  final bool? mini;

  const HeaderButton({
    super.key,
    this.onPressed,
    this.icon,
    this.iconColor,
    this.childWidget,
    this.iconWidth,
    this.iconHeight,
    this.mini,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      mini: mini ?? false,
      heroTag: null,
      elevation: 0,
      focusElevation: 0,
      hoverElevation: 0,
      highlightElevation: 0,
      disabledElevation: 0,
      backgroundColor: AppColors.transparent,
      onPressed: onPressed as void Function()?,
      child: Container(
        child: icon == null
            ? childWidget
            : Image.asset(
                icon!,
                width: iconWidth,
                height: iconHeight,
                color: iconColor,
              ),
      ),
    );
  }
}
