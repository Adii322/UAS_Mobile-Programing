import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ResultCard extends StatelessWidget {
  const ResultCard({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0xFFBAD0D0), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.lexendDeca(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xff03624C),
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.lexendDeca(
              fontSize: 12,
              color: Color(0xff787470),
            ),
          ),
        ],
      ),
    );
  }
}
