import 'package:flutter/material.dart';
import 'package:mobile_app/app/res/image/app_images.dart';
import 'package:mobile_app/app/ui/theme/app_colors.dart';
import 'package:mobile_app/app/ui/theme/app_dimens.dart';
import 'package:mobile_app/app/ui/widget/common_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoAnimation;
  late Animation<double> _taglineAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );
    _taglineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CommonScreen(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.orangeDark,
              AppColors.orange,
            ],
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ScaleTransition(
                    scale: _logoAnimation,
                    child: FadeTransition(
                      opacity: _logoAnimation,
                      child: Image.asset(
                        AppImages.appLogo, // Giả định có logo trong AppImages
                        width: 300.0,
                        height: 300.0,
                        // Nếu chưa có logo, thay bằng: FlutterLogo(size: 100.0),
                      ),
                    ),
                  ),
                  SizedBox(height: AppDimens.spaceLarge),
                  FadeTransition(
                    opacity: _taglineAnimation,
                    child: Text(
                      'Generating Faces with AI',
                      style: TextStyle(
                        fontSize: AppDimens.textSizeLarge24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: 20.0),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}