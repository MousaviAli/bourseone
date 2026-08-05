enum TaskAttachmentType { symbol, note, file, image, voice }

class TaskAttachment {
  final TaskAttachmentType type;
  final String label; // symbol code, file name, or note text preview

  const TaskAttachment({required this.type, required this.label});
}

class TaskItem {
  final String id;
  final String title;
  final DateTime dueAt;
  final bool isDone;
  final List<TaskAttachment> attachments;
  final bool createdByAssistant;

  const TaskItem({
    required this.id,
    required this.title,
    required this.dueAt,
    this.isDone = false,
    this.attachments = const [],
    this.createdByAssistant = false,
  });

  TaskItem copyWith({bool? isDone}) => TaskItem(
        id: id,
        title: title,
        dueAt: dueAt,
        isDone: isDone ?? this.isDone,
        attachments: attachments,
        createdByAssistant: createdByAssistant,
      );
}
