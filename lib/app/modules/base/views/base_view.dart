import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:young_care/app/modules/base/widgets/floating_bottom_navbar.dart';
import 'package:young_care/app/routes/app_pages.dart';

import '../controllers/base_controller.dart';

class BaseView extends GetView<BaseController> {
  const BaseView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      bottomNavigationBar: Obx(
        () => FloatingBottomNavbar(
          selectedIndex: controller.selectedMenu.value,
          onTap: controller.updateSelectedMenu,
        )
      ),
      body: Navigator(
        key: Get.nestedKey(1),
        initialRoute: Routes.HOME,
        onGenerateRoute: (settings) {
          final match = AppPages.mainChildren.firstWhereOrNull(
            (e) => e.name == settings.name,
          );

          if (match != null) {
            // Trigger binding-nya (manual karena tidak auto dari Get)
            match.binding?.dependencies();
            controller.updateSelectedMenuByRoute(match.name);
            return GetPageRoute(
              popGesture: false,
              settings: settings,
              page: match.page,
              transition: Transition.noTransition,
            );
          } else {
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                appBar: AppBar(title: Text("hehe")),
                body: Center(child: Text('Page not found')),
              ),
            );
          }
        },
      ),
    );
  }
}