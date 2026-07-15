import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  IconData selectedIcon = Icons.menu_book;
  Color selectedColor = Colors.green;
  Color selectedBgColor = const Color(0xFFE5F4E8);

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  int selectedDuration = 30;

  final List<int> durationOptions = [15, 30, 45, 60];

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveTask() {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lütfen görev başlığı gir.')));
      return;
    }
    IconData selectedIcon = Icons.menu_book;
    Color selectedColor = Colors.green;
    Color selectedBgColor = const Color(0xFFE5F4E8);
    Navigator.pop(context, {
      'title': title,
      'description': description,
      'duration': '$selectedDuration dk',
      'date': _selectedDay,
      'iconCode': selectedIcon.codePoint,
      'iconColor': selectedColor.value,
      'iconBg': selectedBgColor.value,
    });
  }

  void _previousMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
    });
  }

  List<DateTime?> _buildCalendarDays() {
    final firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final lastDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);

    final firstWeekday = firstDayOfMonth.weekday % 7;
    final daysInMonth = lastDayOfMonth.day;

    final List<DateTime?> days = [];

    for (int i = 0; i < firstWeekday; i++) {
      days.add(null);
    }

    for (int day = 1; day <= daysInMonth; day++) {
      days.add(DateTime(_focusedDay.year, _focusedDay.month, day));
    }

    while (days.length % 7 != 0) {
      days.add(null);
    }

    return days;
  }

  bool _isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final days = _buildCalendarDays();

    const monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    const weekDays = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(22, 8, 22, 18),
        child: SizedBox(
          height: 58,
          child: ElevatedButton(
            onPressed: _saveTask,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 8,
              shadowColor: Colors.black26,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
            ),
            child: const Text(
              'Kaydet',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
          child: Column(
            children: [
              Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(color: Color(0xFFD9D9D9), shape: BoxShape.circle),
                      child: const Icon(Icons.close, color: Color(0xFF6B6B6B), size: 24),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Görev Ekle',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(width: 44),
                ],
              ),

              const SizedBox(height: 18),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 22),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(color: const Color(0xFFE8E8E8), width: 1),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _FieldLabel('Görev Başlığı'),
                        const SizedBox(height: 8),
                        _buildInputField(controller: _titleController, hintText: 'Görev başlığı giriniz', maxLines: 1),

                        const SizedBox(height: 18),

                        const _FieldLabel('Açıklama'),
                        const SizedBox(height: 8),
                        _buildInputField(controller: _descriptionController, hintText: 'Açıklama giriniz', maxLines: 4),

                        const SizedBox(height: 18),

                        const _FieldLabel('Çalışma Süresi'),
                        const SizedBox(height: 8),

                        Row(
                          children: durationOptions.map((minute) {
                            final isSelected = selectedDuration == minute;

                            return Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedDuration = minute;
                                  });
                                },
                                child: Container(
                                  height: 46,
                                  margin: const EdgeInsets.only(right: 8),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.primary : Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: isSelected ? AppColors.primary : const Color(0xFFD6D6D6), width: 1.1),
                                  ),
                                  child: Text(
                                    '$minute dk',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected ? Colors.white : AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const _FieldLabel('Tarih'),
                        const SizedBox(height: 8),

                        Container(
                          padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE1E1E1), width: 1),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: _previousMonth,
                                    icon: const Icon(Icons.chevron_left, size: 26, color: AppColors.textPrimary),
                                  ),
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        _buildDropdownBox(monthNames[_focusedDay.month - 1]),
                                        const SizedBox(width: 8),
                                        _buildDropdownBox('${_focusedDay.year}'),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: _nextMonth,
                                    icon: const Icon(Icons.chevron_right, size: 26, color: AppColors.textPrimary),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              Row(
                                children: weekDays.map((day) {
                                  return Expanded(
                                    child: Center(
                                      child: Text(
                                        day,
                                        style: const TextStyle(fontSize: 12, color: Color(0xFF8F8F8F), fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),

                              const SizedBox(height: 10),

                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: days.length,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 7,
                                  mainAxisSpacing: 8,
                                  crossAxisSpacing: 6,
                                  childAspectRatio: 1,
                                ),
                                itemBuilder: (context, index) {
                                  final day = days[index];
                                  final isSelected = _isSameDay(day, _selectedDay);

                                  if (day == null) {
                                    return const SizedBox.shrink();
                                  }

                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedDay = day;
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 160),
                                      decoration: BoxDecoration(
                                        color: isSelected ? AppColors.textPrimary : Colors.transparent,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${day.day}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: isSelected ? Colors.white : AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
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

  Widget _buildInputField({required TextEditingController controller, required String hintText, required int maxLines}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFFA5A5A5), fontSize: 14, fontWeight: FontWeight.w400),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFD6D6D6), width: 1.1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),
      ),
    );
  }

  Widget _buildDropdownBox(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD2D2D2), width: 1),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down_rounded, size: 17, color: Color(0xFF666666)),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
    );
  }
}
