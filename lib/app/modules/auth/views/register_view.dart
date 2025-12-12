import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:young_care/app/core/constants/my_image.dart';
import 'package:young_care/app/routes/app_pages.dart';

import '../controllers/auth_controller.dart';

class RegisterView extends GetView<AuthController> {
  const RegisterView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0XFFF2F2F2),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: Get.height,
            minWidth: Get.width,
          ),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: 150,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(MyImage.authBlobImage),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(minHeight: Get.height),
                child: SafeArea(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 60),
                        Text(
                          "Register",
                          style: GoogleFonts.lexendDeca(
                            color: Color(0xff03624C),
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 38),
                        Form(
                          key: controller.registerFormKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: controller.fullNameController,
                                style: GoogleFonts.lexendDeca(),
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  final text = value?.trim() ?? '';
                                  if (text.isEmpty) {
                                    return 'Full name can not be empty';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: BorderSide(
                                      color: Color(0xffD9D9D9),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: BorderSide(
                                      color: Color(0xffD9D9D9),
                                    ),
                                  ),
                                  fillColor: Colors.white,
                                  filled: true,
                                  hintText: "Full Name",
                                  hintStyle: GoogleFonts.lexendDeca(
                                    color: Color(0xff6F7D7D),
                                  ),
                                ),
                              ),
                              SizedBox(height: 14),
                              TextFormField(
                                controller: controller.registerEmailController,
                                style: GoogleFonts.lexendDeca(),
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  final text = value?.trim() ?? '';
                                  if (text.isEmpty) {
                                    return 'Email can not be empty';
                                  }
                                  if (!GetUtils.isEmail(text)) {
                                    return 'Email format not valid';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: BorderSide(
                                      color: Color(0xffD9D9D9),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: BorderSide(
                                      color: Color(0xffD9D9D9),
                                    ),
                                  ),
                                  fillColor: Colors.white,
                                  filled: true,
                                  hintText: "Email",
                                  hintStyle: GoogleFonts.lexendDeca(
                                    color: Color(0xff6F7D7D),
                                  ),
                                ),
                              ),
                              SizedBox(height: 14),
                              Obx(
                                () => DropdownButtonFormField<String>(
                                  value: controller.selectedGender.value,
                                  isExpanded: true,
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Gender must be selected';
                                    }
                                    return null;
                                  },
                                  items: [
                                    DropdownMenuItem(
                                      value: 'male',
                                      child: Text('Male', style: GoogleFonts.lexendDeca(color: Colors.black),),
                                    ),
                                    DropdownMenuItem(
                                      value: 'female',
                                      child: Text('Female', style: GoogleFonts.lexendDeca(color: Colors.black)),
                                    ),
                                  ],
                                  onChanged: (value) =>
                                      controller.selectedGender.value = value,
                                  style: GoogleFonts.lexendDeca(),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(24),
                                      borderSide: BorderSide(
                                        color: Color(0xffD9D9D9),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(24),
                                      borderSide: BorderSide(
                                        color: Color(0xffD9D9D9),
                                      ),
                                    ),
                                    fillColor: Colors.white,
                                    filled: true,
                                    hintText: "Gender",
                                    hintStyle: GoogleFonts.lexendDeca(
                                      color: Color(0xff6F7D7D),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 14),
                              TextFormField(
                                controller: controller.jobController,
                                style: GoogleFonts.lexendDeca(),
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  final text = value?.trim() ?? '';
                                  if (text.isEmpty) {
                                    return 'Job can not be empty';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: BorderSide(
                                      color: Color(0xffD9D9D9),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: BorderSide(
                                      color: Color(0xffD9D9D9),
                                    ),
                                  ),
                                  fillColor: Colors.white,
                                  filled: true,
                                  hintText: "Job",
                                  hintStyle: GoogleFonts.lexendDeca(
                                    color: Color(0xff6F7D7D),
                                  ),
                                ),
                              ),
                              SizedBox(height: 14),
                              TextFormField(
                                controller: controller.birthdayController,
                                style: GoogleFonts.lexendDeca(),
                                readOnly: true,
                                onTap: () => controller.pickBirthday(context),
                                validator: (_) {
                                  if (controller.selectedBirthday.value ==
                                      null) {
                                    return 'Birthday must be selected';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: BorderSide(
                                      color: Color(0xffD9D9D9),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: BorderSide(
                                      color: Color(0xffD9D9D9),
                                    ),
                                  ),
                                  fillColor: Colors.white,
                                  filled: true,
                                  hintText: "Birthday",
                                  hintStyle: GoogleFonts.lexendDeca(
                                    color: Color(0xff6F7D7D),
                                  ),
                                  suffixIcon: Icon(
                                    Icons.calendar_today_outlined,
                                    size: 18,
                                    color: Color(0xff555555),
                                  ),
                                ),
                              ),
                              SizedBox(height: 14),
                              TextFormField(
                                controller: controller.heightController,
                                style: GoogleFonts.lexendDeca(),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  final text = value?.trim() ?? '';
                                  if (text.isEmpty) {
                                    return 'Height can not be empty';
                                  }
                                  final number = double.tryParse(text);
                                  if (number == null) {
                                    return 'Height must be number';
                                  }
                                  if (number <= 0) {
                                    return 'Height must be greater than 0';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: BorderSide(
                                      color: Color(0xffD9D9D9),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: BorderSide(
                                      color: Color(0xffD9D9D9),
                                    ),
                                  ),
                                  fillColor: Colors.white,
                                  filled: true,
                                  hintText: "Height",
                                  hintStyle: GoogleFonts.lexendDeca(
                                    color: Color(0xff6F7D7D),
                                  ),
                                ),
                              ),
                              SizedBox(height: 14),
                              TextFormField(
                                controller: controller.weightController,
                                style: GoogleFonts.lexendDeca(),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  final text = value?.trim() ?? '';
                                  if (text.isEmpty) {
                                    return 'Weight must be filled';
                                  }
                                  final number = double.tryParse(text);
                                  if (number == null) {
                                    return 'Weight must be number';
                                  }
                                  if (number <= 0) {
                                    return 'Weight must greather than 0';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: BorderSide(
                                      color: Color(0xffD9D9D9),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: BorderSide(
                                      color: Color(0xffD9D9D9),
                                    ),
                                  ),
                                  fillColor: Colors.white,
                                  filled: true,
                                  hintText: "Weight",
                                  hintStyle: GoogleFonts.lexendDeca(
                                    color: Color(0xff6F7D7D),
                                  ),
                                ),
                              ),
                              SizedBox(height: 14),
                              Obx(
                                () => TextFormField(
                                  controller:
                                      controller.registerPasswordController,
                                  obscureText: controller.isObscured.value,
                                  style: GoogleFonts.lexendDeca(),
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) => controller.register(),
                                  validator: (value) {
                                    final text = value ?? '';
                                    if (text.trim().isEmpty) {
                                      return 'Password must be filled';
                                    }
                                    if (text.length < 6) {
                                      return 'Password minimal 6 character';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(24),
                                      borderSide: BorderSide(
                                        color: Color(0xffD9D9D9),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(24),
                                      borderSide: BorderSide(
                                        color: Color(0xffD9D9D9),
                                      ),
                                    ),
                                    fillColor: Colors.white,
                                    filled: true,
                                    hintText: "Password",
                                    hintStyle: GoogleFonts.lexendDeca(
                                      color: Color(0xff6F7D7D),
                                    ),
                                    suffixIcon: GestureDetector(
                                      onTap: controller.toggleObscured,
                                      child: Icon(
                                        controller.isObscured.value
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        size: 18,
                                        color: Color(0xff555555),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 26),
                              Obx(
                                () => SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor: WidgetStatePropertyAll(
                                        Color(0xff02C88E),
                                      ),
                                    ),
                                    onPressed: controller.isRegisterLoading.value
                                        ? null
                                        : controller.register,
                                    child: controller.isRegisterLoading.value
                                        ? SizedBox(
                                            height: 18,
                                            width: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                            ),
                                          )
                                        : Text(
                                            "Register",
                                            style: GoogleFonts.lexendDeca(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 14),
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  text: "Already have an account?  ",
                                  style: GoogleFonts.lexendDeca(
                                    color: Color(0xff6F7D7D),
                                  ),
                                  children: [
                                    WidgetSpan(
                                      alignment: PlaceholderAlignment.middle,
                                      child: GestureDetector(
                                        onTap: () =>
                                            Get.offAndToNamed(Routes.LOGIN),
                                        child: Text.rich(
                                          TextSpan(
                                            text: "Login",
                                            style: GoogleFonts.lexendDeca(
                                              color: Color(0xff03624C),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 150),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                child: Transform.flip(
                  flipX: true,
                  flipY: true,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 150,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(MyImage.authBlobImage),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
