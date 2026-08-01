import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../models/task_item.dart';
import '../../../../widgets/glass_card.dart';
import '../../providers/task_providers.dart';

class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('تسک‌ها و یادداشت‌ها')),
      body: tasks.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
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
                    child: Row(
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
                                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
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
                          icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.textMuted),
                          onPressed: () => ref.read(taskControllerProvider.notifier).remove(t.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.neonGreen,
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تسک جدید'),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: 'عنوان تسک')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('انصراف')),
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
                      ),
                    );
              }
              Navigator.pop(context);
            },
            child: const Text('افزودن'),
          ),
        ],
      ),
    );
  }
}
