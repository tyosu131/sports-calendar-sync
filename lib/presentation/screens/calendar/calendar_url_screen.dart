import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../application/providers/calendar_provider.dart';

/// カレンダーURL発行画面。
/// .ics URL のコピー・共有・Google Calendar への直接追加を提供。
///
/// ウィジェットツリー:
///   Scaffold
///   └── SingleChildScrollView
///       └── Column
///           ├── _CalendarUrlCard (URL表示 + コピー)
///           ├── _AddToGoogleCalendarButton
///           ├── _ShareButton
///           └── _HowToSection (使い方説明)
class CalendarUrlScreen extends ConsumerWidget {
  const CalendarUrlScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final url = ref.watch(calendarUrlProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('カレンダー同期')),
      body: url == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _CalendarUrlCard(url: url),
                  const SizedBox(height: 20),
                  _AddToGoogleCalendarButton(url: url),
                  const SizedBox(height: 12),
                  _ShareButton(url: url),
                  const SizedBox(height: 32),
                  const _HowToSection(),
                ],
              ),
            ),
    );
  }
}

class _CalendarUrlCard extends StatelessWidget {
  const _CalendarUrlCard({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'あなたの専用カレンダーURL',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      url,
                      style: const TextStyle(fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: url));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('URLをコピーしました')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddToGoogleCalendarButton extends StatelessWidget {
  const _AddToGoogleCalendarButton({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final googleUrl = Uri.parse(
      'https://www.google.com/calendar/render?cid=${Uri.encodeComponent(url)}',
    );

    return FilledButton.icon(
      icon: const Icon(Icons.calendar_today),
      label: const Text('Google カレンダーに追加'),
      onPressed: () async {
        if (await canLaunchUrl(googleUrl)) {
          await launchUrl(googleUrl, mode: LaunchMode.externalApplication);
        }
      },
    );
  }
}

class _ShareButton extends StatelessWidget {
  const _ShareButton({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      icon: const Icon(Icons.share),
      label: const Text('URLを共有'),
      onPressed: () => Share.share(url, subject: 'Sports Calendar Sync URL'),
    );
  }
}

class _HowToSection extends StatelessWidget {
  const _HowToSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '使い方',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        ..._steps.map(
          (step) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 12,
                  child: Text(
                    step.$1,
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(step.$2)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static const _steps = [
    ('1', 'URLをコピーまたは「Google カレンダーに追加」をタップ'),
    ('2', 'iCal (.ics) 形式のカレンダーが自動で購読されます'),
    ('3', '試合日程が更新されると、カレンダーも自動で同期されます'),
    ('4', '詳細欄に配信プラットフォーム（DAZN, ABEMAなど）も表示されます'),
  ];
}
