import 'package:flutter/material.dart';

import '../../core/utils/timezone_utils.dart';
import '../../domain/models/match.dart';

/// 試合カード Widget。
/// カード内に配信プラットフォーム情報も表示 (要件 C に対応)。
class MatchCard extends StatelessWidget {
  const MatchCard({super.key, required this.match});

  final Match match;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // リーグ名 + 日時
            Row(
              children: [
                Expanded(
                  child: Text(
                    match.leagueNameJa,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: colorScheme.primary,
                        ),
                  ),
                ),
                _StatusChip(status: match.status),
              ],
            ),
            const SizedBox(height: 8),

            // チーム名 (ホーム vs アウェイ)
            Row(
              children: [
                Expanded(
                  child: Text(
                    match.homeTeamNameJa,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'vs',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                Expanded(
                  child: Text(
                    match.awayTeamNameJa,
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 日時 (JST)
            Row(
              children: [
                const Icon(Icons.schedule, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  match.startTimeJST,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey),
                ),
              ],
            ),

            // 配信プラットフォーム
            if (match.broadcastPlatforms.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                children: match.broadcastPlatforms
                    .map(
                      (p) => Chip(
                        label: Text(p.name),
                        labelStyle: const TextStyle(fontSize: 11),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    )
                    .toList(),
              ),
            ],

            // 会場
            if (match.venue != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    match.venue!,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final MatchStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      MatchStatus.live => ('LIVE', Colors.red),
      MatchStatus.finished => ('終了', Colors.grey),
      MatchStatus.postponed => ('延期', Colors.orange),
      MatchStatus.cancelled => ('中止', Colors.red.shade900),
      MatchStatus.scheduled => ('予定', Colors.green),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 0.8),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
