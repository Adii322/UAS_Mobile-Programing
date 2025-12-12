import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:young_care/app/routes/app_pages.dart';

class BaseController extends GetxController {
  static BaseController instance = Get.find();
  final Rx<int> selectedMenu = 0.obs;

  final screens = [
    Routes.HOME,
    Routes.ACTIVITY,
    Routes.DAILY_TARGET,
    Routes.PROFILE,
  ];

  // Function to handle menu item click
  void updateSelectedMenu(int index) {
    if (index == selectedMenu.value) {
      return;
    }
    selectedMenu.value = index;
    Get.offAllNamed(screens[index], id: 1);
  }

  void updateSelectedMenuByRoute(String routeName) {
    // You'll need to map your routes to navbar indices here
    int index = screens.indexOf(routeName);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      selectedMenu.value = index;
    });
  }
}
