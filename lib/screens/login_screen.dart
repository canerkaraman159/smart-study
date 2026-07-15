import 'package:flutter/material.dart';
import 'package:study_app/main.dart';
import '../core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isPasswordHidden = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              const SizedBox(height: 34),

              Text(
                'SMART STUDY',
                style: GoogleFonts.kaiseiOpti(fontSize: 18, fontWeight: FontWeight.w400, letterSpacing: 2.0, color: const Color(0xFF5F5F5F)),
              ),

              const SizedBox(height: 34),

              const Text(
                'Giriş Yap',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.black, height: 1),
              ),

              const SizedBox(height: 14),

              const Text(
                'Devam etmek için e-posta ve şifrenizi\ngirin.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textSecondary, height: 1.45),
              ),

              const SizedBox(height: 30),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE5E5E5), width: 1),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 14, offset: const Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'E-posta',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
                    ),

                    const SizedBox(height: 10),

                    TextField(
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'canerkaraman159@gmail.com',
                        hintStyle: const TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.w500),
                        prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF8A8A8A), size: 22),
                        suffixIcon: const Icon(Icons.check, color: Color(0xFF8A8A8A), size: 22),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 19),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(color: Color(0xFFD0D0D0), width: 1.1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(color: AppColors.primary, width: 1.35),
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    const Text(
                      'Şifre',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
                    ),

                    const SizedBox(height: 10),

                    TextField(
                      obscureText: isPasswordHidden,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87, letterSpacing: 2),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: '************',
                        hintStyle: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 2),
                        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF8A8A8A), size: 22),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              isPasswordHidden = !isPasswordHidden;
                            });
                          },
                          icon: Icon(
                            isPasswordHidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: const Color(0xFF8A8A8A),
                            size: 22,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 19),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(color: Color(0xFFD0D0D0), width: 1.1),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(color: AppColors.primary, width: 1.35),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Şifremi Unuttum?',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.primary),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    Center(
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Misafir olarak devam et',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, AppRoutes.home);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B8DEF),
                    foregroundColor: Colors.white,
                    elevation: 8,
                    shadowColor: Colors.black26,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: const Text(
                    'Giriş Yap',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white, height: 1),
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
