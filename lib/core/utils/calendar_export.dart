import 'package:url_launcher/url_launcher.dart';
import '../../models/task_item.dart';

/// Builds a Google Calendar "add event" link and opens it in the browser/
/// Calendar app - the user confirms and saves it on their own Google
/// account. This is intentionally a one-tap *export* link rather than a
/// full OAuth-based two-way sync: it needs no Google API credentials, no
/// sign-in flow, and no extra native setup, so it works immediately.
///
/// For true two-way sync (auto-import Google Calendar events into the
/// app, or auto-push without a confirmation tap), you'd add
/// `google_sign_in` + the Calendar API with a backend-issued OAuth token -
/// a meaningfully bigger integration to build once this simpler version
/// is confirmed to be enough.
class CalendarExport {
  CalendarExport._();

  static String _fmt(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${dt.year}${two(dt.month)}${two(dt.day)}T${two(dt.hour)}${two(dt.minute)}00';
  }

  static Uri googleCalendarUrl(TaskItem task, {Duration duration = const Duration(hours: 1)}) {
    final start = task.dueAt;
    final end = start.add(duration);
    final params = {
      'action': 'TEMPLATE',
      'text': task.title,
      'dates': '${_fmt(start)}/${_fmt(end)}',
      'ctz': 'Asia/Tehran',
      if (task.attachments.isNotEmpty)
        'details': 'ایجادشده در ایزی‌استاک - پیوست‌ها: ${task.attachments.map((a) => a.label).join('، ')}',
    };
    return Uri.https('calendar.google.com', '/calendar/render', params);
  }

  static Future<bool> openInGoogleCalendar(TaskItem task) {
    final url = googleCalendarUrl(task);
    return launchUrl(url, mode: LaunchMode.externalApplication);
  }
}
