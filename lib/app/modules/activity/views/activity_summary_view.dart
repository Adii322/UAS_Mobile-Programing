import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:young_care/app/data/models/resource.dart';
import 'package:young_care/app/modules/activity/controllers/activity_controller.dart';
import 'package:young_care/app/modules/activity/widgets/daily_summary_tile.dart';

class ActivitySummaryView extends GetView<ActivityController> {
  const ActivitySummaryView({super.key});

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime initial = controller.selectedDate.value;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial.isAfter(now) ? now : initial,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
    );

    if (picked != null) {
      await controller.loadDailySummary(date: picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XFFF2F2F2),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.refresh,
          color: const Color(0xFF2CC295),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: Get.back,
                        child: const Icon(Icons.arrow_back_ios),
                      ),
                      Text(
                        'Daily Summary',
                        style: GoogleFonts.lexendDeca(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Icon(Icons.notifications),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(color: Color(0XFFBAD0D0)),
                  const SizedBox(height: 20),
                  _DateSelector(
                    onSelectDate: () => _selectDate(context),
                  ),
                  const SizedBox(height: 20),
                  Obx(() {
                    final Resource<DailyActivitySummary> state =
                        controller.dailySummary.value;
                    final DailyActivitySummary? summary = state.data;

                    if (state.isLoading && summary == null) {
                      return const _DailySummaryLoading();
                    }

                    if (state.hasError && summary == null) {
                      final String message =
                          state.message ?? 'Failed to load activity summary.';
                      return _DailySummaryError(
                        message: message,
                        onRetry: controller.refresh,
                      );
                    }

                    if (summary == null) {
                      return _DailySummaryError(
                        message: 'No data available for this date.',
                        onRetry: controller.refresh,
                      );
                    }

                    return DailySummaryTile(
                      summary: summary,
                      isLoading: state.isLoading,
                      onRefresh: controller.refresh,
                    );
                  }),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DateSelector extends GetView<ActivityController> {
  const _DateSelector({required this.onSelectDate});

  final VoidCallback onSelectDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFBAD0D0), width: 0.5),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Obx(
            () => Text(
              controller.selectedDateLabel,
              style: GoogleFonts.lexendDeca(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF03624C),
              ),
            ),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: onSelectDate,
            icon: const Icon(Icons.edit_calendar, size: 18),
            label: const Text('Select date'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF03624C),
            ),
          ),
        ],
      ),
    );
  }
}

class _DailySummaryLoading extends StatelessWidget {
  const _DailySummaryLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBAD0D0), width: 0.5),
      ),
      child: Row(
        children: const [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Loading activity summary...',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF03624C),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DailySummaryError extends StatelessWidget {
  const _DailySummaryError({
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xffFFEDEA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF8C4BA), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Activity Summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF7A1106),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF7A1106),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Try again'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF7A1106),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
