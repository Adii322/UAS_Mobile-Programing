import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:young_care/app/core/constants/my_image.dart';
import 'package:young_care/app/modules/auth/controllers/auth_controller.dart';
import 'package:young_care/app/routes/app_pages.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});
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
                        Text(
                          "Login",
                          style: GoogleFonts.lexendDeca(
                            color: Color(0xff03624C),
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 38),
                        Form(
                          key: controller.formKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: controller.emailController,
                                style: GoogleFonts.lexendDeca(),
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  final text = value?.trim() ?? '';
                                  if (text.isEmpty) {
                                    return 'Email tidak boleh kosong';
                                  }
                                  if (!GetUtils.isEmail(text)) {
                                    return 'Format email tidak valid';
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
                                () => TextFormField(
                                  controller: controller.passwordController,
                                  obscureText: controller.isObscured.value,
                                  style: GoogleFonts.lexendDeca(),
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) =>
                                      controller.login(),
                                  validator: (value) {
                                    final text = value ?? '';
                                    if (text.trim().isEmpty) {
                                      return 'Password tidak boleh kosong';
                                    }
                                    if (text.length < 6) {
                                      return 'Password minimal 6 karakter';
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
                              SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  "Forgot your password?",
                                  style: GoogleFonts.lexendDeca(
                                    fontSize: 10,
                                    color: Color(0xff6F7D7D),
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
                                    onPressed: controller.isLoginLoading.value
                                        ? null
                                        : controller.login,
                                    child: controller.isLoginLoading.value
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
                                            "Login",
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
                                  text: "Don't have an account yet?  ",
                                  style: GoogleFonts.lexendDeca(
                                    color: Color(0xff6F7D7D),
                                  ),
                                  children: [
                                    WidgetSpan(
                                      alignment: PlaceholderAlignment.middle,
                                      child: GestureDetector(
                                        onTap: () =>
                                            Get.offAndToNamed(Routes.REGISTER),
                                        child: Text.rich(
                                          TextSpan(
                                            text: "Register",
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
