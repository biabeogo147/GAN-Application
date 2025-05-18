import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
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
                        controller.screenTitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          color: AppColors.blackText,
                          fontFamily: AppFonts.robotoMedium,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
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
    return Obx(() => Column(
      children: [
        controller.selectedImage.value != null || controller.isCameraActive.value
            ? _buildPreviewArea()
            : _buildOptionsButtons(),
        const SizedBox(height: 20),
        if (controller.selectedImage.value != null &&
            !(controller.isCameraActive.value && controller.isReviewingImage.value))
          SizedBox(
            width: double.infinity, // Full width
            child: TouchableWidget(
              onPressed: controller.analyzeImage,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  controller.actionButtonText,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    ));
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
        if (controller.isReviewingImage.value && controller.selectedImage.value != null) {
          // Review UI remains the same
          return Column(
            children: [
              Container(
                constraints: BoxConstraints(
                  maxHeight: Get.height * 0.6,
                ),
                child: AspectRatio(
                  aspectRatio: controller.cameraController!.value.aspectRatio,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(
                      File(controller.selectedImage.value!.path),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Retake button
                  TouchableWidget(
                    onPressed: controller.retakePhoto,
                    height: 50,
                    width: Get.width * 0.4,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(
                      child: Text(
                        "Retake",
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Action button
                  TouchableWidget(
                    onPressed: controller.analyzeImage,
                    height: 50,
                    width: Get.width * 0.4,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        controller.actionButtonText,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        } else {
          // Improved camera preview to prevent distortion
          return Column(
            children: [
              GetBuilder<ImageCaptureController>(
                id: 'cameraPreview',
                builder: (ctrl) => _buildCameraPreview(),
              ),
              const SizedBox(height: 20),
              // Camera capture button
              TouchableWidget(
                onPressed: controller.captureForReview,
                height: 60,
                width: 60,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ],
          );
        }
      } else if (controller.selectedImage.value != null) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: Get.height * 0.5,
          ),
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

  Widget _buildCameraPreview() {
    if (controller.isSwitchingCamera.value) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        height: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppColors.grayBorder),
          color: Colors.black,
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (controller.cameraController == null ||
        !controller.cameraController!.value.isInitialized) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        height: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: AppColors.grayBorder),
          color: Colors.black,
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final size = Get.size;
    final double previewRatio = controller.cameraController!.value.aspectRatio;
    double scale = size.aspectRatio * previewRatio;
    if (scale < 1) scale = 1 / scale;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.grayBorder),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            Transform.scale(
              scale: scale,
              child: Center(
                child: CameraPreview(controller.cameraController!),
              ),
            ),
            // Camera switch button
            Positioned(
              top: 20,
              right: 20,
              child: TouchableWidget(
                onPressed: controller.toggleCamera,
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.flip_camera_ios,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
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