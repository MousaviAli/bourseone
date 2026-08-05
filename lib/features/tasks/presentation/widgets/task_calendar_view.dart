import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/calendar_export.dart';
import '../../../../models/task_item.dart';
import '../../providers/task_providers.dart';

final _visibleMonthProvider = StateProvider<Jalali>((ref) => Jalali.now());
final _selectedDayProvider = StateProvider<Jalali>((ref) => Jalali.now());

/// Month-grid calendar (Jalali) with a dot under any day that has tasks;
/// tapping a day shows that day's tasks below the grid.
class TaskCalendarView extends ConsumerWidget {
  const TaskCalendarView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visibleMonth = ref.watch(_visibleMonthProvider);
    final selectedDay = ref.watch(_selectedDayProvider);
    final tasks = ref.watch(taskControllerProvider);

    // Map each day-of-month (that has >=1 task) to true, for a quick dot lookup.
    final tasksByDay = <int, List<TaskItem>>{};
    for (final t in tasks) {
      final j = Jalali.fromDateTime(t.dueAt);
      if (j.year == visibleMonth.year && j.month == visibleMonth.month) {
        tasksByDay.putIfAbsent(j.day, () => []).add(t);
      }
    }

    final firstOfMonth = Jalali(visibleMonth.year, visibleMonth.month, 1);
    final daysInMonth = firstOfMonth.monthLength;
    final leadingBlanks = firstOfMonth.weekDay % 7; // weekDay: 1=Sat..7=Fri -> Sat should have 0 leading blanks
    final monthName = firstOfMonth.formatter.mN;

    final selectedDayTasks = tasksByDay[selectedDay.day] ?? [];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => ref.read(_visibleMonthProvider.notifier).state =
                    _addMonths(visibleMonth, -1),
              ),
              Text('$monthName ${visibleMonth.year}',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => ref.read(_visibleMonthProvider.notifier).state =
                    _addMonths(visibleMonth, 1),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: ['ش', 'ی', 'د', 'س', 'چ', 'پ', 'ج']
                .map((d) => Expanded(
                      child: Center(
                        child: Text(d, style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                      ),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
            itemCount: leadingBlanks + daysInMonth,
            itemBuilder: (_, i) {
              if (i < leadingBlanks) return const SizedBox.shrink();
              final day = i - leadingBlanks + 1;
              final hasTasks = tasksByDay.containsKey(day);
              final isSelected = day == selectedDay.day &&
                  visibleMonth.year == selectedDay.year &&
                  visibleMonth.month == selectedDay.month;
              final isToday = Jalali(visibleMonth.year, visibleMonth.month, day) == Jalali.now();

              return InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => ref.read(_selectedDayProvider.notifier).state =
                    Jalali(visibleMonth.year, visibleMonth.month, day),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.neonGreen.withOpacity(0.18) : null,
                    border: isToday && !isSelected ? Border.all(color: AppColors.blue, width: 1) : null,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$day',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                          color: isSelected ? AppColors.neonGreen : AppColors.textPrimary,
                        ),
                      ),
                      if (hasTasks)
                        Container(
                          width: 4, height: 4,
                          margin: const EdgeInsets.only(top: 2),
                          decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const Divider(height: 28),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              'تسک‌های ${selectedDay.day} ${selectedDay.formatter.mN}',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (selectedDayTasks.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text('تسکی برای این روز ثبت نشده',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          )
        else
          ...selectedDayTasks.map((t) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  dense: true,
                  leading: Checkbox(
                    value: t.isDone,
                    onChanged: (_) => ref.read(taskControllerProvider.notifier).toggleDone(t.id),
                    activeColor: AppColors.neonGreen,
                  ),
                  title: Text(t.title,
                      style: TextStyle(
                        decoration: t.isDone ? TextDecoration.lineThrough : null,
                        fontSize: 13,
                      )),
                  subtitle: Text('ساعت ${t.dueAt.hour}:00', style: const TextStyle(fontSize: 10.5)),
                  trailing: IconButton(
                    icon: const Icon(Icons.event_available_outlined, size: 18, color: AppColors.blue),
                    tooltip: 'افزودن به تقویم گوگل',
                    onPressed: () => CalendarExport.openInGoogleCalendar(t),
                  ),
                ),
              )),
      ],
    );
  }

  Jalali _addMonths(Jalali j, int delta) {
    var year = j.year;
    var month = j.month + delta;
    while (month > 12) {
      month -= 12;
      year += 1;
    }
    while (month < 1) {
      month += 12;
      year -= 1;
    }
    final maxDay = Jalali(year, month, 1).monthLength;
    final day = j.day > maxDay ? maxDay : j.day;
    return Jalali(year, month, day);
  }
}
