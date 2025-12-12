import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:young_care/app/core/constants/my_icon.dart';
import 'package:young_care/app/modules/pedometer/widgets/floating_bottom_navbar_pedometer.dart';
import 'package:young_care/app/modules/pedometer/widgets/floating_bottom_navbar_pedometer_item.dart';
import 'package:young_care/app/modules/pedometer/widgets/pedometer_card.dart';
import 'package:young_care/app/modules/pedometer/widgets/result_card.dart';
import 'package:young_care/app/modules/pedometer/widgets/run_card.dart';
import 'package:young_care/app/routes/app_pages.dart';

import '../../base/controllers/base_controller.dart';
import '../controllers/pedometer_controller.dart';

class PedometerView extends GetView<PedometerController> {
  const PedometerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XFFF2F2F2),
      extendBody: true,
      bottomNavigationBar: FloatingBottomNavbarPedometer(
        children: [
          IconButton(
            onPressed: () {
              Get.until((route) => route.settings.name == Routes.BASE);
              BaseController.instance.updateSelectedMenu(0);
            },
            icon: const FloatingBottomNavbarPedometerItem(
              icon: MyIcon.homeIcon,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () async {
              final DateTime now = DateTime.now();
              final DateTime initialDate = controller.selectedDate.value;
              final DateTime firstDate = DateTime(
                now.year - 5,
                now.month,
                now.day,
              );
              final DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: initialDate.isAfter(now) ? now : initialDate,
                firstDate: firstDate,
                lastDate: now,
              );
              if (pickedDate != null) {
                await controller.loadForDate(pickedDate);
              }
            },
            icon: const FloatingBottomNavbarPedometerItem(
              icon: MyIcon.historyIcon,
              color: Colors.white,
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: FloatingActionButton(
          isExtended: true,
          elevation: 0,
          shape: const CircleBorder(
            side: BorderSide(color: Color(0xFF2CC295), width: 0.5),
          ),
          backgroundColor: Colors.white,
          onPressed: () {
            Get.toNamed(Routes.PEDOMETER_RUN);
          },
          child: const Icon(
            Icons.play_arrow_rounded,
            size: 40,
            color: Color(0xff03624C),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: const Icon(Icons.arrow_back_ios),
                    ),
                    Text(
                      "Pedometer",
                      style: GoogleFonts.lexendDeca(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Icon(Icons.notifications),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Divider(color: Color(0XFFBAD0D0)),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() {
                      return Row(
                        children: [
                          Expanded(
                            child: Text(
                              controller.selectedDateLabel,
                              style: GoogleFonts.lexendDeca(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xff042222),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                    const SizedBox(height: 16),
                    const _SessionSelectorChips(),
                    const SizedBox(height: 24),
                    const RunCard(),
                    const SizedBox(height: 24),
                    Obx(() {
                      final state = controller.dailyResults.value;
                      final isLoading = state.isLoading;
                      final hasError = state.hasError;
                      final result = controller.selectedResult.value;

                      String caloriesText;
                      String heartRateText;

                      if (isLoading) {
                        caloriesText = 'Loading...';
                        heartRateText = 'Loading...';
                      } else if (hasError) {
                        final message =
                            controller.errorMessage ?? 'Failed to load data';
                        caloriesText = message;
                        heartRateText = message;
                      } else if (result == null) {
                        caloriesText = 'No record';
                        heartRateText = 'No record';
                      } else {
                        caloriesText = controller.selectedCaloriesLabel;
                        heartRateText = controller.selectedHeartRateLabel;
                      }

                      return Row(
                        children: [
                          Expanded(
                            child: PedometerCard(
                              label: "Burnt Calories",
                              value: caloriesText,
                              icon: MyIcon.burnCaloriesIcon,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: PedometerCard(
                              label: "Heart Rate",
                              value: heartRateText,
                              icon: MyIcon.heartRateIcon,
                            ),
                          ),
                        ],
                      );
                    }),
                    const SizedBox(height: 28),
                    Text(
                      "Healthy Result",
                      style: GoogleFonts.lexendDeca(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xff042222),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Obx(() {
                      final state = controller.dailyResults.value;
                      final isLoading = state.isLoading;
                      final hasError = state.hasError;
                      final result = controller.selectedResult.value;

                      String summaryText;
                      String oxygenText;

                      if (isLoading) {
                        summaryText = 'Loading...';
                        oxygenText = 'Loading...';
                      } else if (hasError) {
                        final message =
                            controller.errorMessage ?? 'Failed to load data';
                        summaryText = message;
                        oxygenText = message;
                      } else if (result == null) {
                        final noRecord =
                            'No session recorded on ${controller.selectedDateLabel}.';
                        summaryText = noRecord;
                        oxygenText = noRecord;
                      } else {
                        summaryText = controller.selectedSummaryLabel;
                        oxygenText = controller.selectedOxygenLabel;
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ResultCard(
                            title: "Session Summary",
                            subtitle: summaryText,
                          ),
                          const SizedBox(height: 10),
                          ResultCard(
                            title: "Blood Oxygen",
                            subtitle: oxygenText,
                          ),
                        ],
                      );
                    }),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SessionSelectorChips extends GetView<PedometerController> {
  const _SessionSelectorChips();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final state = controller.dailyResults.value;
      if (state.isLoading) {
        return const SizedBox(
          height: 40,
          child: Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      }

      if (state.hasError) {
        return _SessionMessage(
          message: controller.errorMessage ?? 'Failed to load sessions.',
        );
      }

      final sessions = controller.sessions;
      if (sessions.isEmpty) {
        return _SessionMessage(
          message: 'No session recorded on ${controller.selectedDateLabel}.',
        );
      }

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: sessions
              .map(
                (session) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(
                      controller.sessionTimeLabel(session),
                      style: GoogleFonts.lexendDeca(
                        fontSize: 12,
                        color: controller.selectedResult.value == session
                            ? Colors.white
                            : const Color(0xff03624C),
                      ),
                    ),
                    showCheckmark: false,
                    selected: controller.selectedResult.value == session,
                    selectedColor: const Color(0xff2CC295),
                    backgroundColor: const Color(0xffEAF7F3),
                    onSelected: (_) => controller.selectResult(session),
                  ),
                ),
              )
              .toList(),
        ),
      );
    });
  }
}

class _SessionMessage extends StatelessWidget {
  const _SessionMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xffEAF7F3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBAD0D0), width: 0.5),
      ),
      child: Text(
        message,
        style: GoogleFonts.lexendDeca(
          fontSize: 12,
          color: const Color(0xff03624C),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
