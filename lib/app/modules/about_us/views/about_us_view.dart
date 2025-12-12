import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:young_care/app/core/constants/my_image.dart';

import '../controllers/about_us_controller.dart';

class AboutUsView extends GetView<AboutUsController> {
  const AboutUsView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0XFFF2F2F2),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Icon(Icons.arrow_back_ios),
                    ),
                    Spacer(),
                    Text(
                      "About us",
                      style: GoogleFonts.lexendDeca(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Spacer(),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Divider(color: Color(0XFFBAD0D0)),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Text(
                      textAlign: TextAlign.center,
                      "INFORMASI PENELITIAN HIBAH RISTEKDIKTI 2025",
                      style: GoogleFonts.lexendDeca(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 14),
                    Text(
                      textAlign: TextAlign.center,
                      "Implementasi Aktifitas Fisik dan Penerapan Gaya Hidup Sehat Remaja Sedentary Behavior Prevensi PKVA",
                      style: GoogleFonts.lexendDeca(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff03624C),
                      ),
                    ),
                    SizedBox(height: 14),
                    Image.asset(MyImage.aboutUsImage),
                    SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            textAlign: TextAlign.left,
                            "Ketua:",
                            style: GoogleFonts.lexendDeca(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xff03624C),
                            ),
                          ),
                          Text(
                            textAlign: TextAlign.left,
                            "Dr. Ns. Anna Faizah S.Kep., M.bmd",
                            style: GoogleFonts.lexendDeca(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 14),
                          Text(
                            textAlign: TextAlign.left,
                            "Anggota:",
                            style: GoogleFonts.lexendDeca(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xff03624C),
                            ),
                          ),
                          Text(
                            textAlign: TextAlign.left,
                            "Dr. Dr. Eng. Ansarullah Lawi, M.Eng",
                            style: GoogleFonts.lexendDeca(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            textAlign: TextAlign.left,
                            "Bdn Susanti., S.ST., M.Bmd., PhD",
                            style: GoogleFonts.lexendDeca(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            textAlign: TextAlign.left,
                            "Ir. Gunawan Toto Hadiyanto ST., M.M",
                            style: GoogleFonts.lexendDeca(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            textAlign: TextAlign.left,
                            "Dr. Ir. Jogie Suaduon, S.ST., M.Pd",
                            style: GoogleFonts.lexendDeca(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
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
