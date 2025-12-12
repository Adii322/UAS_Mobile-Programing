import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:young_care/app/common/controller/bluetooth_controller.dart';
import 'package:young_care/app/modules/profile/widgets/device_card.dart';

import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});
  @override
  Widget build(BuildContext context) {
    final bluetoothController = Get.find<BluetoothController>();
    return Scaffold(
      backgroundColor: Color(0XFFF2F2F2),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              children: [
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      "Profile",
                      style: GoogleFonts.lexendDeca(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => controller.showSettingsSheet(context),
                      child: const Icon(
                        Icons.settings,
                        color: Color(0XFF03624C),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Divider(color: Color(0XFFBAD0D0)),
                SizedBox(height: 20),
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 65,
                      backgroundImage: NetworkImage(
                        'https://i.pravatar.cc/300',
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 5,
                      child: Icon(
                        Icons.edit_square,
                        size: 30,
                        color: Color(0XFF6F7D7D),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Obx(
                  () => Text(
                    controller.userController.user.value?.name ?? "",
                    style: GoogleFonts.lexendDeca(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text("Indonesia", style: GoogleFonts.lexendDeca()),
                SizedBox(height: 27),
                DeviceCard(
                  onTap: () => bluetoothController.retryConnection(),
                ),
                SizedBox(height: 20),
                Obx(() {
                  if (controller.isEditing.value) {
                    return TextButton(
                      onPressed: controller.cancelEditing,
                      child: Text(
                        "Cancel",
                        style: GoogleFonts.lexendDeca(color: Color(0XFF6F7D7D)),
                      ),
                    );
                  }
                  return TextButton(
                    onPressed: controller.enableEditing,
                    child: Text(
                      "Edit Profile",
                      style: GoogleFonts.lexendDeca(color: Color(0XFF042222)),
                    ),
                  );
                }),
                SizedBox(height: 20),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 34),
                  child: Obx(() {
                    final isEditing = controller.isEditing.value;
                    return Form(
                      key: controller.formKey,
                      child: Column(
                        spacing: 14,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Text(
                                  "Name",
                                  style: GoogleFonts.lexendDeca(
                                    color: Color(0XFF6F7D7D),
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              SizedBox(height: 8),
                              TextFormField(
                                controller: controller.nameTextController,
                                enabled: isEditing,
                                style: GoogleFonts.lexendDeca(),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                  fillColor: Colors.white,
                                  filled: true,
                                  hintText: "Name",
                                  hintStyle: GoogleFonts.lexendDeca(
                                    color: Color(0XFF6F7D7D),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Nama wajib diisi";
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Text(
                                  "Birthday",
                                  style: GoogleFonts.lexendDeca(
                                    color: Color(0XFF6F7D7D),
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              SizedBox(height: 8),
                              TextFormField(
                                controller: controller.birthdayTextController,
                                enabled: isEditing,
                                readOnly: true,
                                onTap: () {
                                  if (isEditing) {
                                    controller.pickBirthday(context);
                                  }
                                },
                                style: GoogleFonts.lexendDeca(),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                  fillColor: Colors.white,
                                  filled: true,
                                  hintText: "Birthday",
                                  hintStyle: GoogleFonts.lexendDeca(
                                    color: Color(0XFF6F7D7D),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Tanggal lahir wajib diisi";
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Text(
                                  "Age",
                                  style: GoogleFonts.lexendDeca(
                                    color: Color(0XFF6F7D7D),
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              SizedBox(height: 8),
                              TextFormField(
                                controller: controller.ageTextController,
                                enabled: false,
                                style: GoogleFonts.lexendDeca(),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                  fillColor: Colors.white,
                                  filled: true,
                                  hintText: "Age",
                                  hintStyle: GoogleFonts.lexendDeca(
                                    color: Color(0XFF6F7D7D),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Text(
                                  "Gender",
                                  style: GoogleFonts.lexendDeca(
                                    color: Color(0XFF6F7D7D),
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              SizedBox(height: 8),
                              DropdownButtonFormField<bool>(
                                initialValue: controller.isMale.value,
                                items: [
                                  DropdownMenuItem(
                                    value: true,
                                    child: Text(
                                      "Male",
                                      style: GoogleFonts.lexendDeca(),
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: false,
                                    child: Text(
                                      "Female",
                                      style: GoogleFonts.lexendDeca(),
                                    ),
                                  ),
                                ],
                                onChanged: isEditing
                                    ? (value) {
                                        if (value != null) {
                                          controller.isMale.value = value;
                                        }
                                      }
                                    : null,
                                decoration: InputDecoration(
                                  enabled: isEditing,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                  fillColor: Colors.white,
                                  filled: true,
                                  hintText: "Gender",
                                  hintStyle: GoogleFonts.lexendDeca(
                                    color: Color(0XFF6F7D7D),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null) {
                                    return "Gender wajib dipilih";
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Text(
                                  "Weight (Kg)",
                                  style: GoogleFonts.lexendDeca(
                                    color: Color(0XFF6F7D7D),
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              SizedBox(height: 8),
                              TextFormField(
                                controller: controller.weightTextController,
                                enabled: isEditing,
                                keyboardType: TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                style: GoogleFonts.lexendDeca(),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                  fillColor: Colors.white,
                                  filled: true,
                                  hintText: "Weight",
                                  hintStyle: GoogleFonts.lexendDeca(
                                    color: Color(0XFF6F7D7D),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Berat badan wajib diisi";
                                  }
                                  final parsed = double.tryParse(value.trim());
                                  if (parsed == null) {
                                    return "Gunakan angka yang valid";
                                  }
                                  if (parsed < 0) {
                                    return "Berat badan tidak boleh negatif";
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Text(
                                  "Height (Cm)",
                                  style: GoogleFonts.lexendDeca(
                                    color: Color(0XFF6F7D7D),
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              SizedBox(height: 8),
                              TextFormField(
                                controller: controller.heightTextController,
                                enabled: isEditing,
                                keyboardType: TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                style: GoogleFonts.lexendDeca(),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                  fillColor: Colors.white,
                                  filled: true,
                                  hintText: "Height",
                                  hintStyle: GoogleFonts.lexendDeca(
                                    color: Color(0XFF6F7D7D),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Tinggi badan wajib diisi";
                                  }
                                  final parsed = double.tryParse(value.trim());
                                  if (parsed == null) {
                                    return "Gunakan angka yang valid";
                                  }
                                  if (parsed < 0) {
                                    return "Tinggi badan tidak boleh negatif";
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Text(
                                  "Job",
                                  style: GoogleFonts.lexendDeca(
                                    color: Color(0XFF6F7D7D),
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              SizedBox(height: 8),
                              TextFormField(
                                controller: controller.jobTextController,
                                enabled: isEditing,
                                style: GoogleFonts.lexendDeca(),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                  fillColor: Colors.white,
                                  filled: true,
                                  hintText: "Job",
                                  hintStyle: GoogleFonts.lexendDeca(
                                    color: Color(0XFF6F7D7D),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 40,),
                          Obx(() {
                            if (controller.isEditing.value) {
                              return SizedBox(
                                width: Get.size.width / 1.5,
                                child: ElevatedButton(
                                  onPressed: () => controller.saveProfile(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0XFF03624C),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                  ),
                                  child: Text(
                                    "Save Profile",
                                    style: GoogleFonts.lexendDeca(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              );
                            }
                            return SizedBox();
                          }),
                        ],
                      ),
                    );
                  }),
                ),
                SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
