import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:young_care/app/modules/activity/controllers/activity_controller.dart';

class DailySummaryTile extends StatelessWidget {
  const DailySummaryTile({
    super.key,
    required this.summary,
    this.isLoading = false,
    this.onRefresh,
  });

  final DailyActivitySummary summary;
  final bool isLoading;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final DailyHealthScore? score = summary.healthScore;
    final String stepsLabel = _formatNumber(summary.steps);
    final String heartRateLabel =
        summary.heartRate != null ? summary.heartRate!.toString() : '—';
    final String spo2Label =
        summary.spo2 != null ? summary.spo2!.toString() : '—';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBAD0D0), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Today\'s Activity Summary',
                  style: GoogleFonts.lexendDeca(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF03624C),
                  ),
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              if (onRefresh != null)
                IconButton(
                  onPressed: isLoading ? null : onRefresh,
                  icon: const Icon(Icons.refresh, size: 20),
                  color: const Color(0xFF03624C),
                  tooltip: 'Refresh data',
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              _MetricBadge(
                label: 'Steps',
                value: stepsLabel,
                unit: 'steps',
              ),
              _MetricBadge(
                label: 'Heart rate',
                value: heartRateLabel,
                unit: summary.heartRate != null ? 'bpm' : null,
              ),
              _MetricBadge(
                label: 'SpO₂',
                value: spo2Label,
                unit: summary.spo2 != null ? '%' : null,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (score != null) ...[
            _HealthScoreCard(score: score),
          ] else ...[
            _MissingHealthScoreCard(onRefresh: onRefresh),
          ],
        ],
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

class _MetricBadge extends StatelessWidget {
  const _MetricBadge({
    required this.label,
    required this.value,
    this.unit,
  });

  final String label;
  final String value;
  final String? unit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xffEAF7F3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBAD0D0), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF03624C),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: GoogleFonts.lexendDeca(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF03624C),
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 4),
                Text(
                  unit!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF03624C),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _HealthScoreCard extends StatelessWidget {
  const _HealthScoreCard({required this.score});

  final DailyHealthScore score;

  @override
  Widget build(BuildContext context) {
    final List<_ComponentScore> components = <_ComponentScore>[
      _ComponentScore(label: 'Activity', value: score.activityScore),
      if (score.heartRateScore != null)
        _ComponentScore(label: 'Heart rate', value: score.heartRateScore!),
      if (score.spo2Score != null)
        _ComponentScore(label: 'SpO₂', value: score.spo2Score!),
    ];

    final String scoreLabel = score.value.toStringAsFixed(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xff2CC295),
                Color(0xff03624C),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daily Health Score',
                style: GoogleFonts.lexendDeca(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    scoreLabel,
                    style: GoogleFonts.lexendDeca(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '/100',
                    style: GoogleFonts.lexendDeca(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                score.category,
                style: GoogleFonts.lexendDeca(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                score.recommendation,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: components
              .map(
                (component) => _ScoreChip(
                  label: component.label,
                  value: component.value,
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _MissingHealthScoreCard extends StatelessWidget {
  const _MissingHealthScoreCard({this.onRefresh});

  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xffEAF7F3),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFBAD0D0), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Health Score',
            style: GoogleFonts.lexendDeca(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF03624C),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Heart rate or SpO₂ data is not available for today yet. '
            'Make sure your device is connected and send a new reading.',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF03624C),
            ),
          ),
          if (onRefresh != null) ...[
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh, size: 18),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF03624C),
              ),
              label: const Text('Try again'),
            ),
          ],
        ],
      ),
    );
  }
}

class _ScoreChip extends StatelessWidget {
  const _ScoreChip({
    required this.label,
    required this.value,
  });

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    final String valueLabel = value.toStringAsFixed(0);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBAD0D0), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF03624C),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            valueLabel,
            style: GoogleFonts.lexendDeca(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF03624C),
            ),
          ),
        ],
      ),
    );
  }
}

class _ComponentScore {
  const _ComponentScore({
    required this.label,
    required this.value,
  });

  final String label;
  final double value;
}
