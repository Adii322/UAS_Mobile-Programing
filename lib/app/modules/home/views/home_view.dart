import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:young_care/app/common/controller/bluetooth_controller.dart';
import 'package:young_care/app/core/constants/my_icon.dart';
import 'package:young_care/app/data/models/pedometer_result.dart';
import 'package:young_care/app/data/models/resource.dart';
import 'package:young_care/app/modules/home/widgets/heart_rate_card.dart';
import 'package:young_care/app/modules/home/widgets/home_tile.dart';
import 'package:young_care/app/modules/home/widgets/step_progress_card.dart';
import 'package:young_care/app/modules/home/widgets/article_tile.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XFFF2F2F2),
      body: RefreshIndicator(
        onRefresh: controller.refreshAll,
        color: const Color(0XFFF0A5443),
        child: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 24,
                        backgroundImage: NetworkImage(
                          'https://i.pravatar.cc/300',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hi, ${controller.userController.user.value?.name.split(' ').first ?? ''}!',
                            style: GoogleFonts.lexendDeca(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Text(
                            '"Lorem ipsum dolor sit amet”',
                            style: TextStyle(
                              fontSize: 10,
                              color: Color(0XFF6F7D7D),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Icon(Icons.notifications, size: 28),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Obx(() {
                    final Resource<PedometerResult> state =
                        controller.todayPedometer.value;
                    final pedometer = state.data;
                    final errorMessage = state.hasError
                        ? state.message ?? 'Failed to load'
                        : null;

                    if (state.isLoading) {
                      return Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: HeartRateCard(
                        isLoading: state.isLoading,
                        heartRate: pedometer?.heartRate,
                        errorMessage: errorMessage,
                                            ),
                      );
                    }
                    return HeartRateCard(
                      isLoading: state.isLoading,
                      heartRate: pedometer?.heartRate,
                      errorMessage: errorMessage,
                    );
                  }),
                  const SizedBox(height: 10),
                  Obx(() {
                    final Resource<int> state = controller.todaySteps.value;
                    final user = controller.userController.user.value;
                    return StepProgressCard(
                      isLoading: state.isLoading,
                      steps: state.data,
                      dailyTarget: user?.dailyTargetStep,
                      errorMessage: state.hasError ? state.message : null,
                    );
                  }),
                  // === Artikel Kesehatan Islami (Diperbarui) ===
                  const SizedBox(height: 24),
                  Text(
                    "Artikel Kesehatan Islami 🕌",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF03624C), // Menggunakan warna tema
                    ),
                  ),
                  const SizedBox(height: 12),

                  Obx(() {
                    if (controller.isLoadingArticles.value) {
                      // Mengganti CircularProgressIndicator dengan Shimmer untuk tampilan loading yang lebih bagus
                      return Column(
                        children: List.generate(3, (index) => _buildArticleShimmer()),
                      );
                    }
                    if (controller.articles.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(
                          child: Text(
                            "Tidak ada artikel untuk ditampilkan.",
                            style: GoogleFonts.poppins(color: Colors.grey),
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: controller.articles.take(5).map((article) {
                        return ArticleTile(article: article);
                      }).toList(),
                    );
                  }),
                  // === Akhir Artikel Kesehatan Islami ===
                  const SizedBox(height: 20),
                  Text(
                    "Today's Progress",
                    style: GoogleFonts.lexendDeca(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 10),
                  Obx(() {
                    final Resource<int> state = controller.todaySteps.value;
                    final bool isLoading = state.isLoading;
                    final bool hasError = state.hasError;
                    final int steps = state.data ?? 0;
                    String value;
                    String? unit = 'steps';

                    if (isLoading) {
                      value = 'Loading...';
                      unit = null;
                    } else if (hasError) {
                      value = state.message ?? 'Failed to load';
                      unit = null;
                    } else {
                      value = _formatNumber(steps);
                      if (steps <= 0) {
                        unit = null;
                      }
                    }

                    return HomeTile(
                      label: "Steps",
                      unit: unit,
                      value: value,
                      icon: SvgPicture.asset(MyIcon.stepsIcon),
                    );
                  }),
                  // ... (Bagian HomeTile lainnya)
                  const SizedBox(height: 10),
                  Obx(() {
                    final Resource<PedometerResult> state =
                        controller.todayPedometer.value;
                    final pedometer = state.data;
                    final isLoading = state.isLoading;
                    final hasError = state.hasError;

                    String value;
                    String? unit;

                    if (isLoading) {
                      value = 'Loading...';
                      unit = null;
                    } else if (hasError) {
                      value = state.message ?? 'Failed to load';
                      unit = null;
                    } else if (pedometer?.burnCalories != null) {
                      value = pedometer!.burnCalories!.toStringAsFixed(0);
                      unit = 'kcal';
                    } else {
                      value = 'No record today';
                      unit = null;
                    }

                    if (isLoading) {
                      return Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: HomeTile(
                          label: "Burn Calories",
                          unit: unit,
                          value: value,
                          icon: SvgPicture.asset(MyIcon.burnCaloriesIcon),
                        ),
                      );
                    }

                    return HomeTile(
                      label: "Burn Calories",
                      unit: unit,
                      value: value,
                      icon: SvgPicture.asset(MyIcon.burnCaloriesIcon),
                    );
                  }),
                  const SizedBox(height: 10),
                  Obx(() {
                    final Resource<PedometerResult> state =
                        controller.todayPedometer.value;
                    final pedometer = state.data;
                    final isLoading = state.isLoading;
                    final hasError = state.hasError;

                    String value;
                    String? unit;

                    if (isLoading) {
                      value = 'Loading...';
                      unit = null;
                    } else if (hasError) {
                      value = state.message ?? 'Failed to load';
                      unit = null;
                    } else if (pedometer?.heartRate != null) {
                      value = pedometer!.heartRate!.toString();
                      unit = 'bpm';
                    } else {
                      value = 'No record today';
                      unit = null;
                    }

                    if (isLoading) {
                      return Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: HomeTile(
                        label: "Heart Rate",
                        unit: unit,
                        value: value,
                        icon: SvgPicture.asset(MyIcon.heartRateIcon),
                                            ),
                      );
                    }

                    return GestureDetector(
                      onTap: () async {
                        Get.log("Minta");
                        final service = Get.find<BluetoothController>();
                        await service.requestVitalSigns();
                        Get.log("Selesai");
                      },
                      child: HomeTile(
                        label: "Heart Rate",
                        unit: unit,
                        value: value,
                        icon: SvgPicture.asset(MyIcon.heartRateIcon),
                      ),
                    );
                  }),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Tambahkan fungsi untuk Shimmer loading artikel
  Widget _buildArticleShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 14, width: double.infinity, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(height: 12, width: double.infinity, color: Colors.white),
                  const SizedBox(height: 4),
                  Container(height: 12, width: 100, color: Colors.white),
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