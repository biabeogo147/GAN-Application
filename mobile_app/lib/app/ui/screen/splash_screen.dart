import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:mobile_app/app/ui/theme/app_colors.dart';
import 'package:mobile_app/app/ui/widget/common_screen.dart';
import 'package:mobile_app/app/controller/splash_controller.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonScreen(
      child: Container(
        color: AppColors.white,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
