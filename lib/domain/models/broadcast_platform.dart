/// 配信プラットフォーム情報。
/// カレンダーの Description/Location 欄に埋め込む。
enum BroadcastType { streaming, terrestrial, bs, cs }

class BroadcastPlatform {
  const BroadcastPlatform({
    required this.name,
    required this.type,
    required this.region,
    this.url,
  });

  final String name;          // "DAZN" | "U-NEXT" | "ABEMA" | "NHK" | "フジテレビ"
  final BroadcastType type;
  final String region;        // "JP" | "global"
  final String? url;

  factory BroadcastPlatform.fromMap(Map<String, dynamic> map) {
    return BroadcastPlatform(
      name: map['name'] as String,
      type: BroadcastType.values.byName(map['type'] as String),
      region: map['region'] as String,
      url: map['url'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'type': type.name,
        'region': region,
        if (url != null) 'url': url,
      };
}
