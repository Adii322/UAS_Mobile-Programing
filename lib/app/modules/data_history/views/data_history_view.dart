import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:young_care/app/data/models/resource.dart';
import 'package:young_care/app/modules/data_history/controllers/data_history_controller.dart';
import 'package:young_care/app/modules/data_history/models/data_history_models.dart';
import 'package:young_care/app/modules/data_history/widgets/history_metric_card.dart';

class DataHistoryView extends GetView<DataHistoryController> {
  const DataHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF042222)),
          onPressed: () => Get.back(),
        ),
        title: Obx(() {
          final metric = controller.selectedMetric;
          final title =
              metric == null ? 'Data History' : '${metric.label} History';
          return Text(
            title,
            style: GoogleFonts.lexendDeca(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF042222),
            ),
          );
        }),
      ),
      body: Obx(() {
        final state = controller.metrics.value;
        final metric = controller.selectedMetric;

        return RefreshIndicator(
          color: const Color(0xFF2CC295),
          onRefresh: controller.refresh,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              _MetricFilter(
                metrics: controller.allMetrics,
                selectedType: controller.selectedType,
                onSelected: controller.selectMetric,
              ),
              const SizedBox(height: 16),
              if (state.isLoading && metric == null)
                const SizedBox(
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (state.status == ResourceStatus.empty ||
                  metric == null ||
                  !metric.hasData)
                _EmptyState(
                  isLoading: state.isLoading,
                  message: 'Belum ada catatan riwayat dalam 7 hari terakhir.',
                )
              else
                HistoryMetricCard(metric: metric),
              if (state.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    state.message ?? 'Gagal memuat data',
                    style: GoogleFonts.lexendDeca(
                      fontSize: 12,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

class _MetricFilter extends StatelessWidget {
  const _MetricFilter({
    required this.metrics,
    required this.selectedType,
    required this.onSelected,
  });

  final List<DataHistoryMetric> metrics;
  final DataHistoryMetricType selectedType;
  final void Function(DataHistoryMetricType type) onSelected;

  @override
  Widget build(BuildContext context) {
    if (metrics.isEmpty) {
      return const SizedBox.shrink();
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: metrics
            .map(
              (metric) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(
                    metric.label,
                    style: GoogleFonts.lexendDeca(
                      fontSize: 12,
                      color: selectedType == metric.type
                          ? Colors.white
                          : const Color(0xFF03624C),
                    ),
                  ),
                  selected: selectedType == metric.type,
                  selectedColor: const Color(0xFF2CC295),
                  backgroundColor: const Color(0xFFEAF7F3),
                  showCheckmark: false,
                  onSelected: (_) => onSelected(metric.type),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.isLoading,
    required this.message,
  });

  final bool isLoading;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7F3),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFBAD0D0), width: 0.5),
      ),
      child: Column(
        children: [
          Icon(
            isLoading ? Icons.sync : Icons.insights_outlined,
            size: 48,
            color: const Color(0xFF2CC295),
          ),
          const SizedBox(height: 12),
          Text(
            isLoading ? 'Memuat data...' : message,
            style: GoogleFonts.lexendDeca(
              fontSize: 14,
              color: const Color(0xFF6F7D7D),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
