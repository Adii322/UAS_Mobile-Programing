import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:young_care/app/modules/data_history/models/data_history_models.dart';
import 'package:young_care/app/modules/data_history/widgets/history_metric_chart.dart';

class HistoryMetricCard extends StatelessWidget {
  const HistoryMetricCard({
    super.key,
    required this.metric,
  });

  final DataHistoryMetric metric;

  @override
  Widget build(BuildContext context) {
    final String? unit = metric.unit;
    final double? latest = metric.latestValue;
    final double? average = metric.averageValue;
    final double? max = metric.maxValue;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBAD0D0), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xff00df82), Color(0xff2ea7a9)],
                    stops: [0.25, 0.75],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    metric.iconAsset,
                    width: 28,
                    height: 28,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      metric.label,
                      style: GoogleFonts.lexendDeca(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF03624C),
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (latest != null && latest > 0)
                      Text(
                        _formatValue(latest, unit),
                        style: GoogleFonts.lexendDeca(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF042222),
                        ),
                      )
                    else
                      Text(
                        'Belum ada catatan',
                        style: GoogleFonts.lexendDeca(
                          fontSize: 14,
                          color: const Color(0xFF6F7D7D),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: HistoryMetricChart(metric: metric),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _MetricStat(
                label: 'Rata-rata',
                value: average,
                unit: unit,
              ),
              const SizedBox(width: 12),
              _MetricStat(
                label: 'Tertinggi',
                value: max,
                unit: unit,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatValue(double value, String? unit) {
    final bool isInteger = value == value.roundToDouble();
    final String formatted = isInteger
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(value >= 100 ? 1 : 2);
    return unit == null ? formatted : '$formatted $unit';
  }
}

class _MetricStat extends StatelessWidget {
  const _MetricStat({
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final double? value;
  final String? unit;

  @override
  Widget build(BuildContext context) {
    final TextStyle labelStyle = GoogleFonts.lexendDeca(
      fontSize: 12,
      color: const Color(0xFF6F7D7D),
    );
    final TextStyle valueStyle = GoogleFonts.lexendDeca(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: const Color(0xFF042222),
    );

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF7F3),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: labelStyle),
            const SizedBox(height: 4),
            Text(
              value != null && value! > 0
                  ? _formatValue(value!, unit)
                  : 'Tidak ada',
              style: valueStyle,
            ),
          ],
        ),
      ),
    );
  }

  String _formatValue(double value, String? unit) {
    final bool isInteger = value == value.roundToDouble();
    final String formatted = isInteger
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(value >= 100 ? 1 : 2);
    return unit == null ? formatted : '$formatted $unit';
  }
}

