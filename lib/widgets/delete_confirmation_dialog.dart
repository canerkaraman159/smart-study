import 'package:flutter/material.dart';

Future<void> showDeleteTasksDialog(BuildContext context, VoidCallback onConfirm) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 48),
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(.15), blurRadius: 18, offset: const Offset(0, 6))],
          ),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Uyarı",
                  style: TextStyle(fontSize: 13, color: Color(0xFF7D7D7D), fontWeight: FontWeight.w500),
                ),
              ),

              const SizedBox(height: 14),

              const Text(
                "Emin Misin?",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: Color(0xFF2B2B2B)),
              ),

              const SizedBox(height: 16),

              const Text(
                "Tamamlanmış tüm görevler kalıcı\nolarak silinecektir. İşlem geri\nalınamaz.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, height: 1.45, color: Color(0xFF8B8B8B)),
              ),

              const SizedBox(height: 26),

              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE8E8E8),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text(
                          "Hayır",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF2B2B2B)),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onConfirm();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF3B33),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text(
                          "Sil",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
