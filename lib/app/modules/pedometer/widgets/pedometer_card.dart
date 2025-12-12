import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class PedometerCard extends StatelessWidget {
  const PedometerCard({super.key, required this.label, required this.icon, required this.value});

  final String label;
  final String icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0xFFBAD0D0), width: 0.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xff00df82), Color(0xff2ea7a9)],
                    stops: [0.25, 0.75],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(child: SvgPicture.asset(icon)),
              ),
              SizedBox(width: 8,),
               Expanded(child: Text(label, textAlign: TextAlign.center, style: GoogleFonts.lexendDeca(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xff2CC295))))
            ],
          ),
          SizedBox(height: 12,),
          Text(value, style: GoogleFonts.lexendDeca(fontSize: 20, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
