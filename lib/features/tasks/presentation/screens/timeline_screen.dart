import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/calendar_export.dart';
import '../../../../models/task_item.dart';
import '../../../../widgets/glass_card.dart';
import '../../../market/providers/market_providers.dart';
import '../../providers/task_providers.dart';
import '../widgets/task_calendar_view.dart';

enum _ViewMode { list, calendar }

final _viewModeProvider = StateProvider<_ViewMode>((ref) => _ViewMode.list);

class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskControllerProvider);
    final viewMode = ref.watch(_viewModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تقویم و تسک'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SegmentedButton<_ViewMode>(
              segments: const [
                ButtonSegment(value: _ViewMode.list, label: Text('لیست'), icon: Icon(Icons.list_alt)),
                ButtonSegment(value: _ViewMode.calendar, label: Text('تقویم'), icon: Icon(Icons.calendar_month_outlined)),
              ],
              selected: {viewMode},
              onSelectionChanged: (s) => ref.read(_viewModeProvider.notifier).state = s.first,
            ),
          ),
        ),
      ),
      body: viewMode == _ViewMode.calendar
          ? const SingleChildScrollView(child: TaskCalendarView())
          : (tasks.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'می‌تونید از طریق چت با دستیار هم تسک بسازید - مثلاً بگید «فردا ساعت ۱۲ جلسه دارم»',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: tasks.length,
                  itemBuilder: (_, i) {
                    final t = tasks[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: t.isDone,
                                  onChanged: (_) => ref.read(taskControllerProvider.notifier).toggleDone(t.id),
                                  activeColor: AppColors.neonGreen,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        t.title,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          decoration: t.isDone ? TextDecoration.lineThrough : null,
                                          color: t.isDone ? AppColors.textMuted : AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text(
                                            '${t.dueAt.year}/${t.dueAt.month}/${t.dueAt.day} - ${t.dueAt.hour}:00',
                                            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                          ),
                                          if (t.createdByAssistant) ...[
                                            const SizedBox(width: 6),
                                            const Icon(Icons.auto_awesome, size: 11, color: AppColors.gold),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.event_available_outlined, size: 18, color: AppColors.blue),
                                  tooltip: 'افزودن به تقویم گوگل',
                                  onPressed: () => CalendarExport.openInGoogleCalendar(t),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete_outline, size: 18, color: AppColors.textMuted),
                                  onPressed: () => ref.read(taskControllerProvider.notifier).remove(t.id),
                                ),
                              ],
                            ),
                            if (t.attachments.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(right: 44, top: 2, bottom: 4),
                                child: Wrap(
                                  spacing: 6,
                                  children: t.attachments
                                      .map((a) => ActionChip(
                                            label: Text(a.label, style: const TextStyle(fontSize: 10.5)),
                                            avatar: Icon(
                                              a.type == TaskAttachmentType.symbol
                                                  ? Icons.show_chart
                                                  : Icons.attach_file,
                                              size: 13,
                                            ),
                                            backgroundColor: AppColors.cardElevated,
                                            visualDensity: VisualDensity.compact,
                                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            // Tapping a linked symbol jumps straight to its detail page -
                                            // the task<->symbol link is two-way (see stock_detail_screen's
                                            // "related tasks" section for the reverse direction).
                                            onPressed: a.type == TaskAttachmentType.symbol
                                                ? () => context.push('/stock/${a.label}')
                                                : null,
                                          ))
                                      .toList(),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                )),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.neonGreen,
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    final attachedSymbols = <String>{};

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: const Text('تسک جدید'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(controller: controller, decoration: const InputDecoration(hintText: 'عنوان تسک')),
              const SizedBox(height: 12),
              if (attachedSymbols.isNotEmpty)
                Wrap(
                  spacing: 6,
                  children: attachedSymbols
                      .map((s) => Chip(
                            label: Text(s, style: const TextStyle(fontSize: 11)),
                            onDeleted: () => setState(() => attachedSymbols.remove(s)),
                          ))
                      .toList(),
                ),
              TextButton.icon(
                icon: const Icon(Icons.show_chart, size: 16),
                label: const Text('پیوست نماد'),
                onPressed: () async {
                  final all = await ref.read(marketRepositoryProvider).getAllSymbols();
                  if (!dialogContext.mounted) return;
                  final picked = await showModalBottomSheet<String>(
                    context: dialogContext,
                    backgroundColor: AppColors.surface,
                    builder: (_) => SizedBox(
                      height: 400,
                      child: ListView(
                        children: all
                            .map((s) => ListTile(
                                  title: Text(s.symbol),
                                  subtitle: Text(s.companyName, style: const TextStyle(fontSize: 11)),
                                  onTap: () => Navigator.pop(dialogContext, s.symbol),
                                ))
                            .toList(),
                      ),
                    ),
                  );
                  if (picked != null) setState(() => attachedSymbols.add(picked));
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('انصراف')),
            TextButton(
              onPressed: () {
                final title = controller.text.trim();
                if (title.isNotEmpty) {
                  final now = DateTime.now();
                  ref.read(taskControllerProvider.notifier).add(
                        TaskItem(
                          id: 't_${DateTime.now().microsecondsSinceEpoch}',
                          title: title,
                          dueAt: DateTime(now.year, now.month, now.day, now.hour + 1),
                          attachments: attachedSymbols
                              .map((s) => TaskAttachment(type: TaskAttachmentType.symbol, label: s))
                              .toList(),
                        ),
                      );
                }
                Navigator.pop(dialogContext);
              },
              child: const Text('افزودن'),
            ),
          ],
        ),
      ),
    );
  }
}
