import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:young_care/app/core/constants/my_image.dart';

import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0XFFF2F2F2),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              bottom: 40,
              child: Transform.flip(
                flipX: true,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.7,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(MyImage.onboardingBlobImage),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.7,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(MyImage.onboardingBlobImage),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 32, right: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 5),
                  Text(
                    "Let's start your health journey today with us!",
                    style: GoogleFonts.lexendDeca(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0XFF03624C),
                    ),
                  ),
                  SizedBox(height: 10),
                  SizedBox(height: 10),
                  SizedBox(
                    width: Get.size.width / 2,
                    child: Obx(
                      () => ElevatedButton(
                        style: ButtonStyle(
                          shape: WidgetStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        onPressed: controller.isLoading.value
                            ? null
                            : controller.goToLogin,
                        child: controller.isLoading.value
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator())
                            : Text(
                                "Start",
                                style: GoogleFonts.lexendDeca(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                  color: Color(0XFF03624C),
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
