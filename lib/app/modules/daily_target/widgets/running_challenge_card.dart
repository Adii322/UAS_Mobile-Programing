import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:young_care/app/core/constants/my_icon.dart';

class RunningChallengeCard extends StatelessWidget {
  const RunningChallengeCard({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Color(0XFFE5DFDA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        SvgPicture.asset(MyIcon.challengeIcon),
        Text(label, style: GoogleFonts.lexendDeca(color: Color(0XFF24211E), fontSize: 16, fontWeight: FontWeight.w500),),
        Text("May 2 - May 12", style: GoogleFonts.lexendDeca(color: Color(0XFF787470), fontSize: 14),)
      ]),
    );
  }
}
