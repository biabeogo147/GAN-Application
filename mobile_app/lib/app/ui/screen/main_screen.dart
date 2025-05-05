import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/app/controller/main_controller.dart';
import 'package:mobile_app/app/res/image/app_images.dart';
import 'package:mobile_app/app/ui/widget/common_screen.dart';
import 'package:mobile_app/app/ui/widget/touchable_widget.dart';
import 'package:mobile_app/app/res/string/app_strings.dart';
import 'package:mobile_app/app/ui/theme/app_colors.dart';
import 'package:mobile_app/app/res/font/app_fonts.dart';

class MainScreen extends GetView<MainController> {
  const MainScreen({Key? key}) : super(key: key);

  Widget _buildFunctionButton({
    required bool isShow,
    required VoidCallback onPress,
    required Color color,
    required String img,
    required String text,
  }) {
    if (!isShow) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TouchableWidget(
        height: 120,
        onPressed: onPress,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 4),
              blurRadius: 5.0,
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Image.asset(
                  img,
                  width: 48,
                  height: 48,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    double heightHeader = (Get.width / 15) * 3.2;
    double heightHeaderContent = (Get.width / 15) * 3.2 - MediaQuery.of(context).padding.top;
    return Container(
      width: Get.width,
      height: heightHeader,
      alignment: Alignment.bottomCenter,
      color: AppColors.white,
      child: Stack(children: <Widget>[
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: heightHeader - MediaQuery.of(context).padding.top,
          child: Column(
            children: <Widget>[
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: heightHeaderContent,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 4,
                      child: Text(AppStrings.chooseFunction.tr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          color: AppColors.blackText,
                          fontFamily: AppFonts.robotoMedium,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    controller.context = context;
    return CommonScreen(
      mainBackgroundColor: AppColors.white,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _buildHeader(context),
              const SizedBox(height: 70),
              _buildFunctionButton(
                isShow: true,
                onPress: controller.onPressDetectFake,
                color: AppColors.lightGreen,
                img: AppImages.qrCode,
                text: AppStrings.detectFake.tr,
              ),
              _buildFunctionButton(
                isShow: true,
                onPress: controller.onPressGenerateImage,
                color: AppColors.primary,
                img: AppImages.scanCard,
                text: AppStrings.generateImage.tr,
              ),
              // Add the new Capture Image button here
              _buildFunctionButton(
                isShow: true,
                onPress: controller.onPressCaptureImage,
                color: AppColors.orange,
                img: AppImages.scanCard, // Use an appropriate camera icon from your assets
                text: "Capture Image", // Or use AppStrings if you have a constant for this
              ),
            ],
          ),
        ),
      ),
    );
  }
}