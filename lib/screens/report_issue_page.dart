import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFFE0E6FF);
  static const cardBackground = Color(0xFFD2DAFB);
  static const primary = Color(0xFF5B8DEF);
  static const textPrimary = Color(0xFF2B2B2B);
  static const textSecondary = Color(0xFF6B6B6B);
}

class ReportIssuePage extends StatefulWidget {
  const ReportIssuePage({super.key});

  @override
  State<ReportIssuePage> createState() => _ReportIssuePageState();
}

class _ReportIssuePageState extends State<ReportIssuePage> {
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  void dispose() {
    subjectController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void _submitIssue() {
    final subject = subjectController.text.trim();
    final description = descriptionController.text.trim();

    if (subject.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen konu ve açıklama alanını doldur.')));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sorun bildirimi gönderildi.')));

    subjectController.clear();
    descriptionController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 22),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: SizedBox(
                height: 52,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () => Navigator.pop(context),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(Icons.arrow_back, size: 42, color: Colors.black),
                        ),
                      ),
                    ),
                    const Center(
                      child: Text(
                        'Sorun Bildir',
                        style: TextStyle(fontFamily: 'Inter', fontSize: 24, fontWeight: FontWeight.w700, color: Colors.black, height: 1.0),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Yaşadığın sorunu bize bildir',
                          style: TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.1),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Karşılaştığın hatayı ve uygulamada ne yaparken oluştuğunu detaylı şekilde yazabilirsin.',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Konu',
                          style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 10),
                        _CustomInputField(controller: subjectController, hintText: 'Örn. Sayaç çalışmıyor', maxLines: 1),
                        const SizedBox(height: 22),
                        const Text(
                          'Açıklama',
                          style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 10),
                        _CustomInputField(controller: descriptionController, hintText: 'Sorunu detaylı şekilde açıkla...', maxLines: 7),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: ElevatedButton(
                            onPressed: _submitIssue,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 224, 39, 39),
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            ),
                            child: const Text(
                              'Gönder',
                              style: TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLines;

  const _CustomInputField({required this.controller, required this.hintText, required this.maxLines});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w400, color: Color(0xFF9AA0AE)),
        filled: true,
        fillColor: const Color(0xFFF7F8FC),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFD9DDE8), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
      ),
    );
  }
}
