import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_app/app/res/font/app_fonts.dart';
import 'package:mobile_app/app/res/string/app_strings.dart';
import 'package:mobile_app/app/ui/theme/app_colors.dart';
import 'package:mobile_app/app/ui/widget/common_screen.dart';
import 'package:mobile_app/app/ui/widget/touchable_widget.dart';
import 'package:mobile_app/app/controller/image_capture_controller.dart';

class ImageCaptureScreen extends GetView<ImageCaptureController> {
  const ImageCaptureScreen({Key? key}) : super(key: key);

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
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      onPressed: () => Get.back(),
                    ),
                    Expanded(
                      flex: 4,
                      child: Text(
                        "Face Detection",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          color: AppColors.blackText,
                          fontFamily: AppFonts.robotoMedium,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // Balance the back button
                  ],
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildImageOptions() {
    return Column(
      children: [
        Obx(() => controller.selectedImage.value != null || controller.isCameraActive.value
            ? _buildPreviewArea()
            : _buildOptionsButtons()),
        const SizedBox(height: 20),
        if (controller.selectedImage.value != null)
          TouchableWidget(
            onPressed: controller.analyzeImage,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                "Analyze Face",
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildOptionsButtons() {
    return Column(
      children: [
        _buildOptionButton(
          onPress: controller.captureImage,
          color: AppColors.lightGreen,
          icon: Icons.camera_alt,
          text: "Take Photo",
        ),
        const SizedBox(height: 20),
        _buildOptionButton(
          onPress: controller.pickImageFromGallery,
          color: AppColors.primary,
          icon: Icons.photo_library,
          text: "Upload Image",
        ),
      ],
    );
  }

  Widget _buildOptionButton({
    required VoidCallback onPress,
    required Color color,
    required IconData icon,
    required String text,
  }) {
    return TouchableWidget(
      height: 100,
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
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 35,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewArea() {
    return Obx(() {
      if (controller.isCameraActive.value) {
        return Container(
          height: 300,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.lightGrayBackground,
            borderRadius: BorderRadius.circular(15),
          ),
          child: controller.cameraController?.buildPreview() ??
              const Center(child: CircularProgressIndicator()),
        );
      } else if (controller.selectedImage.value != null) {
        return Container(
          height: 400,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.lightGrayBackground,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: AppColors.grayBorder),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.file(
              File(controller.selectedImage.value!.path),
              fit: BoxFit.contain,
            ),
          ),
        );
      } else {
        return const SizedBox.shrink();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    controller.context = context;
    return CommonScreen(
      mainBackgroundColor: AppColors.white,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: _buildImageOptions(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}