import 'package:flutter/cupertino.dart';
import 'package:mobile_app/app/res/font/app_fonts.dart';

import 'app_colors.dart';
import 'app_dimens.dart';

TextStyle buttonTextStyle({color, fontSize}) {
  return TextStyle(
    fontSize: fontSize ?? AppDimens.textSizeLarge,
    fontFamily: AppFonts.robotoMedium,
    color: color ?? AppColors.white,
  );
}

BoxDecoration buttonDecoration() {
  return BoxDecoration(
    color: AppColors.gray,
    borderRadius: const BorderRadius.all(Radius.circular(6)),
    border: Border.all(color: AppColors.gray, width: 1),
//    boxShadow: [
//      BoxShadow(
//        color: Color.fromRGBO(204, 223, 242, 0.57),
//        offset: Offset(0, 2),
//        blurRadius: 25,
//      )
//    ],
  );
}

BoxDecoration bodyDecoration({Color? color}) {
  return BoxDecoration(
    color: color ?? AppColors.white,
    borderRadius: const BorderRadius.all(Radius.circular(6)),
    boxShadow: const [
      BoxShadow(
        color: Color.fromRGBO(204, 223, 242, 0.17),
        offset: Offset(0, 8),
        blurRadius: 25,
      )
    ],
  );
}

BoxDecoration bottomDecoration() {
  return const BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
    boxShadow: [
      BoxShadow(
        color: Color.fromRGBO(57, 82, 107, 0.09),
        offset: Offset(0, -4),
        blurRadius: 25,
      )
    ],
  );
}
