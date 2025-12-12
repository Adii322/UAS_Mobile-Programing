import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:young_care/app/modules/onboarding/controllers/splashscreen_controller.dart';

class SplashScreenView extends GetView<SplashscreenController> {
  const SplashScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0XFFF2F2F2),
      body: Column(
        children: [
          Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Image.asset("assets/images/splash_center.png"),
          ),
          Spacer(),
          Image.asset("assets/images/splash_branding.png"),
          SizedBox(height: 12,),
        ],
      ),
    );
  }
}