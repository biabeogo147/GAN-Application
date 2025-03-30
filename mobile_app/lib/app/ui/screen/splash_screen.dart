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
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;
  late String tagline;
  late List<String> words;
  late List<Animation<double>> _wordAnimations;

  @override
  void initState() {
    super.initState();

    // Khởi tạo tagline và words
    tagline = 'Generating Faces with AI';
    words = tagline.split(' ');

    // Khởi tạo AnimationController
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Logo animations
    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );
    _logoOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Tagline animations
    _wordAnimations = List.generate(words.length, (index) {
      final startTime = 0.5 + index * 0.5; // in seconds
      final endTime = startTime + 0.5;
      final startFraction = startTime / 3.0;
      final endFraction = endTime / 3.0;
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(startFraction, endFraction.clamp(0.0, 1.0), curve: Curves.easeIn),
        ),
      );
    });

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
                    scale: _logoScaleAnimation,
                    child: FadeTransition(
                      opacity: _logoOpacityAnimation,
                      child: Image.asset(
                        AppImages.appLogo,
                        width: 300.0,
                        height: 300.0,
                      ),
                    ),
                  ),
                  SizedBox(height: AppDimens.spaceLarge),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(words.length, (index) {
                      return FadeTransition(
                        opacity: _wordAnimations[index],
                        child: Text(
                          words[index] + ' ',
                          style: TextStyle(
                            fontSize: AppDimens.textSizeLarge24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }),
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