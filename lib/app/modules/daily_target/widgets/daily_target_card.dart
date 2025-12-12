import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DailyTargetCardModel {
  final String label;
  final double progress;

  DailyTargetCardModel({required this.label, required this.progress});
}

class DailyTargetCard extends StatelessWidget {
  const DailyTargetCard({super.key, required this.data});

  final DailyTargetCardModel data;

  double getWidthProgress() {
    return data.progress * 65;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0XFFE5DFDA)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "Complete 30 minutes of running today",
              style: GoogleFonts.lexendDeca(
                color: Color(0XFF787470),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${(data.progress * 100).ceil()}%",
                style: GoogleFonts.inter(
                  color: Color(0xFF6FCDAD),
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 8),
              Container(
                width: 65,
                height: 8,
                decoration: BoxDecoration(
                  color: Color(0xFFDFFCF4),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Row(
                  children: [
                    Container(
                      width: getWidthProgress(),
                      decoration: BoxDecoration(
                        color: Color(0xFF6FCDAD),
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
