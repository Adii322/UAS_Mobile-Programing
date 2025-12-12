import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:young_care/app/core/constants/my_icon.dart';
import 'package:young_care/app/modules/base/widgets/floating_bottom_navbar_item.dart';

class FloatingBottomNavbar extends StatelessWidget {
  const FloatingBottomNavbar({super.key, required this.selectedIndex, required this.onTap});

  final int selectedIndex;
  final Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20, left: Get.size.width / 18, right: Get.size.width / 18),
      decoration: BoxDecoration(
        color: Color(0XFFF0A5443),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            onPressed: () => onTap(0),
            icon: FloatingBottomNavbarItem(icon: MyIcon.homeIcon, color: selectedIndex == 0 ? Colors.white : Colors.grey)),
          IconButton(
            onPressed: () => onTap(1),
            icon: SizedBox(
              height: 25,
              child: FloatingBottomNavbarItem(icon: MyIcon.pedometerIcon, color: selectedIndex == 1 ? Colors.white : Colors.grey))),
          IconButton(
            onPressed: () => onTap(2),
            icon: FloatingBottomNavbarItem(icon: MyIcon.targetIcon, color: selectedIndex == 2 ? Colors.white : Colors.grey)),
          IconButton(
            onPressed: () => onTap(3),
            icon: FloatingBottomNavbarItem(icon: MyIcon.profileIcon, color: selectedIndex == 3 ? Colors.white : Colors.grey)),
        ]
      ),
    );
  }
}