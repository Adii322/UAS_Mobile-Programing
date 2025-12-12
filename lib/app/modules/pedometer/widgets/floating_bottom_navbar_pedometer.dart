import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';

class FloatingBottomNavbarPedometer extends StatelessWidget {
  const FloatingBottomNavbarPedometer({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20, left: Get.size.width / 18, right: Get.size.width / 18),
      padding: EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Color(0XFFF0A5443),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: children
      ),
    );
  }
}