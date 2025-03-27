import 'package:flutter/widgets.dart';
import 'package:mobile_app/app/res/font/app_fonts.dart';
import 'package:mobile_app/app/ui/theme/app_colors.dart';
import 'package:mobile_app/app/ui/theme/app_dimens.dart';
import 'package:mobile_app/app/res/image/app_images.dart';

import 'header_button.dart';

class CommonHeader extends StatelessWidget {
  final Widget? headerExtend;
  final double? headerBackgroundHeight;
  final Color? headerBackgroundColor;
  final BoxDecoration? headerDecoration;
  final String? title;
  final Color? titleColor;
  final Widget? headerContent; // khác null: bỏ qua toàn bộ nội dung khác (buildLeftWidget, buildRightWidget...)
  final Widget? leftWidget;
  final Widget? rightWidget;
  final Widget? rightWidgetStack;
  final Widget? customTitle;
  final int? rightWidgetFlex;
  final TextAlign? titleTextAlign;

  const CommonHeader(
      {Key? key,
      this.headerExtend,
      this.headerBackgroundHeight,
      this.headerBackgroundColor,
      this.headerDecoration,
      this.title,
      this.titleColor,
      this.headerContent,
      this.leftWidget,
      this.rightWidget,
      this.rightWidgetStack,
      this.customTitle,
      this.rightWidgetFlex,
      this.titleTextAlign})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double addSizeHeight = MediaQuery.of(context).padding.top > 24
        ? 5
        : 0; // tăng size cho các màn hình có thanh trạng thái lớn (VD: Iphone X)
    double heightHeader = (headerBackgroundHeight ?? 80) + addSizeHeight;
    double heightHeaderContent = 80 - MediaQuery.of(context).padding.top + addSizeHeight;

    return Stack(children: <Widget>[
      Container(
        width: MediaQuery.of(context).size.width,
        height: heightHeader,
        decoration: headerDecoration ??
            BoxDecoration(
              color: headerBackgroundColor ?? AppColors.white,
              border: Border.all(width: 0, color: headerBackgroundColor ?? AppColors.white),
            ),
      ),
      Container(
        width: MediaQuery.of(context).size.width,
        height: heightHeader,
        alignment: Alignment.bottomCenter,
        decoration: BoxDecoration(
          border: Border.all(width: 0, color: headerBackgroundColor ?? AppColors.white),
        ),
        child: Stack(children: <Widget>[
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: heightHeader - MediaQuery.of(context).padding.top,
            child: Column(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: heightHeaderContent,
                  padding: const EdgeInsets.only(top: 10),
                  child: headerContent ??
                      Row(
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: leftWidget ??
                                HeaderButton(
                                  icon: AppImages.icBack,
                                  iconColor: titleColor ?? AppColors.blackText,
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  iconHeight: 18,
                                  iconWidth: 9,
                                ),
                          ),
                          Expanded(
                            flex: 4,
                            child: customTitle ??
                                Text(
                                  title ?? '',
                                  textAlign: titleTextAlign ?? TextAlign.center,
                                  style: TextStyle(
                                    fontSize: AppDimens.textSizeLarge,
                                    color: titleColor ?? AppColors.blackText,
                                    fontFamily: AppFonts.robotoMedium,
                                  ),
                                ),
                          ),
                          Expanded(
                            flex: rightWidgetFlex ?? 1,
                            child: rightWidget ?? Container(),
                          )
                        ],
                      ),
                ),
                Expanded(flex: 1, child: headerExtend ?? const SizedBox.shrink())
              ],
            ),
          ),
        ]),
      ),
      rightWidgetStack != null
          ? Positioned(
              right: 0,
              top: MediaQuery.of(context).padding.top,
              child: Container(
                height: heightHeaderContent,
                padding: const EdgeInsets.only(top: 10, right: 10),
                child: rightWidgetStack,
              ),
            )
          : const SizedBox.shrink(),
    ]);
  }
}
