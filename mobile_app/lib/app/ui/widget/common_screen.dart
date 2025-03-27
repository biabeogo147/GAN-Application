import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_app/app/ui/theme/app_colors.dart';

class CommonScreen extends StatelessWidget {
  @required
  final Widget? child;
  final Widget? header;
  final bool? isBlankScreen;
  final Color? mainBackgroundColor;
  final bool? isFixedSizeHeader;

  const CommonScreen(
      {super.key, this.isBlankScreen, this.child, this.mainBackgroundColor, this.isFixedSizeHeader, this.header});

  @override
  Widget build(BuildContext context) {
    return isBlankScreen == true
        ? child!
        : GestureDetector(
            onTap: () {
              FocusScopeNode currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              }
            },
            child: Scaffold(
//                    resizeToAvoidBottomInset : false,
              body: Builder(
                builder: (context) => Container(
                  color: mainBackgroundColor ?? AppColors.lightGrayBackground,
                  child: (isFixedSizeHeader == true
                      ? Stack(
                          children: <Widget>[
                            Container(child: header ?? const SizedBox.shrink()),
                            Container(
                              margin: EdgeInsets.only(
                                  top: ((MediaQuery.of(context).size.width / 15) * 3.2) +
                                      (MediaQuery.of(context).padding.top > 24 ? 15 : 0)),
                              child: child,
                            ),
                          ],
                        )
                      : Column(
                          children: <Widget>[
                            header ?? const SizedBox.shrink(),
                            Expanded(
                              flex: 1,
                              child: Container(
                                child: child,
                              ),
                            ),
                          ],
                        )),
                ),
              ),
            ),
          );
  }
}

class StyleOfStatusBarContent {
  SystemUiOverlayStyle? androidStyle;
  Brightness? iosStyle;

  StyleOfStatusBarContent(StatusBarStyle statusBarStyle) {
    switch (statusBarStyle) {
      case StatusBarStyle.dark:
        androidStyle = SystemUiOverlayStyle.dark;
        iosStyle = Brightness.light;
        break;
      case StatusBarStyle.light:
        androidStyle = SystemUiOverlayStyle.light;
        iosStyle = Brightness.dark;
        break;
    }
  }
}

enum StatusBarStyle {
  dark,
  light,
}
