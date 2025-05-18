import 'package:mobile_app/app/binding/app_binding.dart';
import 'package:mobile_app/app/route/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


void main() async {
  runApp(GetMaterialApp(
    initialBinding: AppBinding(),
    initialRoute: AppRoute.splash_screen,
    getPages: AppPages.pages,
    debugShowCheckedModeBanner: false,
    locale: const Locale('en', 'US'),
    builder: (context, child) {
      return Scaffold(
        body: child,
      );
    },
  ),
  );
}