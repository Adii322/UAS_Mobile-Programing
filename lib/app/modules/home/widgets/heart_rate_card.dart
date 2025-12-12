import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HeartRateCard extends StatelessWidget {
  const HeartRateCard({
    super.key,
    required this.isLoading,
    this.heartRate,
    this.errorMessage,
  });

  final bool isLoading;
  final int? heartRate;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: const [Color(0xff00df82), Color(0xff2ea7a9)],
          stops: const [0.25, 0.75],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: const Color(0xFFBAD0D0BA).withAlpha(195), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Heart Rate',
            style: GoogleFonts.lexendDeca(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            _valueText,
            style: GoogleFonts.lexendDeca(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String get _valueText {
    if (isLoading) {
      return 'Loading...';
    }
    if (errorMessage != null && errorMessage!.isNotEmpty) {
      return errorMessage!;
    }
    if (heartRate != null) {
      return '${heartRate!} bpm';
    }
    return 'No record today';
  }
}
