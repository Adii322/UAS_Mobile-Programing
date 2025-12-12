import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:young_care/app/core/constants/my_icon.dart';
  
class DeviceCard extends StatelessWidget {
  const DeviceCard({
    super.key,
    this.onTap,
  });

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        margin: EdgeInsets.symmetric(horizontal: 36),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Color(0XFFBAD0D0), width: 0.7),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SvgPicture.asset(MyIcon.deviceIcon),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Device", style: GoogleFonts.lexendDeca(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0XFF042222))),
                Text("SMART WATCH L-14", style: GoogleFonts.lexendDeca(fontSize: 10, color: Color(0XFF042222)),)
              ],
            ),
            Icon(Icons.settings, color: Color(0XFF042222), size: 30,)
          ],
        ),
      ),
    );
  }
}
