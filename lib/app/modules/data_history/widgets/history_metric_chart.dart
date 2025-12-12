import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:young_care/app/modules/data_history/models/data_history_models.dart';

class HistoryMetricChart extends StatelessWidget {
  const HistoryMetricChart({
    super.key,
    required this.metric,
  });

  final DataHistoryMetric metric;

  @override
  Widget build(BuildContext context) {
    final List<DataHistoryPoint> points = metric.points;
    if (points.isEmpty) {
      return _buildPlaceholder(context, 'No data yet');
    }

    final List<DataHistoryPoint> nonZero =
        points.where((point) => point.value > 0).toList();
    if (nonZero.isEmpty) {
      return _buildPlaceholder(context, 'Belum ada catatan 7 hari terakhir');
    }

    final List<FlSpot> spots = List<FlSpot>.generate(
      points.length,
      (index) => FlSpot(
        index.toDouble(),
        points[index].value,
      ),
    );

    final double maxY = spots
        .map((spot) => spot.y)
        .fold<double>(0, (previousValue, element) => math.max(previousValue, element));
    final double minY = spots
        .map((spot) => spot.y)
        .fold<double>(double.infinity, (previousValue, element) => math.min(previousValue, element));

    final double computedMaxY = maxY <= 0 ? 1 : maxY * 1.1;
    final double computedMinY = minY == double.infinity || minY <= 0
        ? 0
        : math.max(0, minY * 0.9);

    final List<String> dayLabels = points
        .map((point) => _weekdayLabel(point.date))
        .toList();

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (spots.length - 1).toDouble(),
        minY: computedMinY,
        maxY: computedMaxY,
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: computedMaxY == 0 ? 1 : computedMaxY / 4,
          getDrawingHorizontalLine: (value) => FlLine(
            color: const Color(0xFFE0F2EE),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            color: const Color(0xFF2CC295),
            barWidth: 4,
            spots: spots,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, _, __, ___) => FlDotCirclePainter(
                color: Colors.white,
                strokeColor: const Color(0xFF2CC295),
                strokeWidth: 2,
                radius: 4,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: const [
                  Color(0xFF2CC295),
                  Color(0x002CC295),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final int index = value.round();
                if (index < 0 || index >= dayLabels.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    dayLabels[index],
                    style: GoogleFonts.lexendDeca(
                      fontSize: 10,
                      color: const Color(0xFF6F7D7D),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context, String message) {
    return Center(
      child: Text(
        message,
        style: GoogleFonts.lexendDeca(
          fontSize: 12,
          color: const Color(0xFF6F7D7D),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  String _weekdayLabel(DateTime date) {
    const List<String> names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final int index = date.weekday - 1;
    if (index < 0 || index >= names.length) return '';
    return names[index];
  }
}

