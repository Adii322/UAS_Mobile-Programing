import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:young_care/app/modules/daily_target/widgets/daily_target_card.dart';
import 'package:young_care/app/modules/daily_target/widgets/running_challenge_card.dart';

import '../controllers/daily_target_controller.dart';

class DailyTargetView extends GetView<DailyTargetController> {
  DailyTargetView({super.key});

  final List<String> labelChallenge = [
    "Run 50km in 10 days",
    "Complete 3 daily runs",
    "Achieve 10k steps daily",
    "Distance Marathon 42km",
  ];

  final List<DailyTargetCardModel> dailyTargetCards = [
    DailyTargetCardModel(
      label: "Complete 30 minutes of running today",
      progress: 0.75,
    ),
    DailyTargetCardModel(label: "Reach 8000 steps for the day", progress: 0.50),
    DailyTargetCardModel(label: "Drink 2 liters of water", progress: 0.90),
    DailyTargetCardModel(
      label: "Perform 15 minutes of strength training",
      progress: 0.10,
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
                    "Daily Target",
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
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Running Challenges",
                          style: GoogleFonts.lexendDeca(
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          "See All",
                          style: GoogleFonts.lexendDeca(
                            color: Color(0XFF6FCDAD),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 22),
                    SizedBox(
                      height: 180,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) =>
                            RunningChallengeCard(label: labelChallenge[index]),
                        separatorBuilder: (context, index) =>
                            SizedBox(width: 16),
                        itemCount: labelChallenge.length,
                      ),
                    ),
                    SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Daily Target",
                          style: GoogleFonts.lexendDeca(
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          "See All",
                          style: GoogleFonts.lexendDeca(
                            color: Color(0XFF6FCDAD),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    ListView.separated(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) =>
                          DailyTargetCard(data: dailyTargetCards[index]),
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 16),
                      itemCount: dailyTargetCards.length,
                    ),
                    SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Update Daily Target",
                        style: GoogleFonts.lexendDeca(
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    Form(
                      key: controller.formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: controller.targetController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: controller.validateDailyTarget,
                            decoration: InputDecoration(
                              labelText: 'Daily target (langkah)',
                              hintText: 'Masukkan target langkah harian',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          SizedBox(height: 12),
                          Obx(
                            () => ElevatedButton(
                              onPressed: controller.isSaving.value
                                  ? null
                                  : controller.updateDailyTarget,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0XFF03624C),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: controller.isSaving.value
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : Text(
                                      'Simpan Target',
                                      style: GoogleFonts.lexendDeca(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                          SizedBox(height: 40),
                        ],
                      ),
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
