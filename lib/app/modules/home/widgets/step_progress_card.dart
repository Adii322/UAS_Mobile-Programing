import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class StepProgressCard extends StatelessWidget {
  const StepProgressCard({
    super.key,
    required this.isLoading,
    this.steps,
    this.dailyTarget,
    this.errorMessage,
  });

  final bool isLoading;
  final int? steps;
  final int? dailyTarget;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final int stepsValue = steps ?? 0;
    final int targetValue = dailyTarget ?? 0;
    final bool hasError =
        errorMessage != null && errorMessage!.trim().isNotEmpty;

    final double rawProgress =
        targetValue > 0 ? stepsValue / targetValue : 0.0;
    final double percent = rawProgress.clamp(0.0, 1.0);
    final String percentLabel = '${(percent * 100).round()}%';

    final String headline = isLoading
        ? 'Memuat...'
        : hasError
            ? '—'
            : _formatNumber(stepsValue);

    final String subtitle;
    if (isLoading) {
      subtitle = 'Mengambil data langkah';
    } else if (hasError) {
      subtitle = errorMessage!;
    } else if (targetValue > 0) {
      subtitle = 'Steps out of ${_formatNumber(targetValue)}';
    } else {
      subtitle = 'Total steps today';
    }

    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff00df82), Color(0xff2ea7a9)],
          stops: [0.25, 0.75],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFBAD0D0).withAlpha(195),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularPercentIndicator(
              radius: 70,
              lineWidth: 20,
              percent: percent,
              center: Text(
                percentLabel,
                style: GoogleFonts.lexendDeca(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              progressColor: const Color(0xff03624C),
              backgroundColor: Colors.white,
              reverse: true,
              circularStrokeCap: CircularStrokeCap.round,
            ),
            const SizedBox(width: 24),
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Steps',
                    style: GoogleFonts.lexendDeca(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    headline,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.lexendDeca(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: GoogleFonts.lexendDeca(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(int value) {
    final String digits = value.abs().toString();
    final StringBuffer buffer = StringBuffer();

    for (int index = 0; index < digits.length; index++) {
      final int positionFromEnd = digits.length - index;
      buffer.write(digits[index]);
      if (positionFromEnd > 1 && positionFromEnd % 3 == 1) {
        buffer.write('.');
      }
    }

    final String formatted = buffer.toString();
    return value < 0 ? '-$formatted' : formatted;
  }
}
