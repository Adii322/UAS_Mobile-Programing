import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:young_care/app/core/constants/my_icon.dart';
import 'package:young_care/app/modules/activity/widgets/activity_tile.dart';
import 'package:young_care/app/modules/data_history/models/data_history_models.dart';
import 'package:young_care/app/routes/app_pages.dart';

class ActivityView extends StatelessWidget {
  const ActivityView({super.key});
  @override
  Widget build(BuildContext context) {
    void openHistory(DataHistoryMetricType type) {
      Get.toNamed(
        Routes.DATA_HISTORY,
        arguments: type,
      );
    }

    return Scaffold(
      backgroundColor: Color(0XFFF2F2F2),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    "Activity",
                    style: GoogleFonts.lexendDeca(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(Icons.notifications),
                ],
              ),
              SizedBox(height: 10),
              Divider(color: Color(0XFFBAD0D0)),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  spacing: 10,
                  children: [
                    GestureDetector(
                      onTap: () => Get.toNamed(Routes.ACTIVITY_SUMMARY),
                      child: ActivityTile(
                        label: "Daily Summary",
                        icon: SvgPicture.asset(MyIcon.heartRateIcon),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => openHistory(DataHistoryMetricType.steps),
                      child: ActivityTile(
                        label: "Steps",
                        icon: SvgPicture.asset(MyIcon.stepsIcon),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.toNamed(Routes.PEDOMETER),
                      child: ActivityTile(
                        label: "Pedometer",
                        icon: SvgPicture.asset(MyIcon.pedometerIcon),
                      ),
                    ),
                    GestureDetector(
                      onTap: () =>
                          openHistory(DataHistoryMetricType.burnCalories),
                      child: ActivityTile(
                        label: "Burn Calories",
                        icon: SvgPicture.asset(MyIcon.burnCaloriesIcon),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => openHistory(DataHistoryMetricType.heartRate),
                      child: ActivityTile(
                        label: "Heart Rate",
                        icon: SvgPicture.asset(MyIcon.heartRateIcon),
                      ),
                    ),
                    GestureDetector(
                      onTap: () =>
                          openHistory(DataHistoryMetricType.maxHeartRate),
                      child: ActivityTile(
                        label: "Maximum Heart Rate",
                        icon: SvgPicture.asset(MyIcon.maxHeartRateIcon),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => openHistory(DataHistoryMetricType.mets),
                      child: ActivityTile(
                        label: "METS Results Interpretasion",
                        icon: SvgPicture.asset(MyIcon.metsIcon),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => openHistory(DataHistoryMetricType.oxygen),
                      child: ActivityTile(
                        label: "Oxygen/Unit",
                        icon: SvgPicture.asset(MyIcon.oxygenIcon),
                      ),
                    ),
                    GestureDetector(
                      onTap: () =>
                          openHistory(DataHistoryMetricType.cardioRespiratory),
                      child: ActivityTile(
                        label: "Cardiorespiratory Fitness Presentation",
                        icon: SvgPicture.asset(MyIcon.cardioRespiratoryIcon),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
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
