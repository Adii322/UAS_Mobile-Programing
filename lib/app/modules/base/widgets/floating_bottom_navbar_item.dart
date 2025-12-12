import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FloatingBottomNavbarItem extends StatelessWidget {
  const FloatingBottomNavbarItem({super.key, required this.icon, required this.color});
  final String icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(icon, color: color);
  }
}
