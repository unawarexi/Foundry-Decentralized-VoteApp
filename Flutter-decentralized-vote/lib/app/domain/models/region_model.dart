/// VoteSecure region — matches the Express Region model.
class RegionModel {
  final String id;
  final String name;
  final String countryCode;
  final String? stateCode;
  final String level; // NATIONAL | STATE | LOCAL
  final bool isActive;
  final DateTime createdAt;

  const RegionModel({
    required this.id,
    required this.name,
    required this.countryCode,
    this.stateCode,
    required this.level,
    this.isActive = true,
    required this.createdAt,
  });

  factory RegionModel.fromJson(Map<String, dynamic> json) {
    return RegionModel(
      id: json['id'] as String,
      name: json['name'] as String,
      countryCode: json['countryCode'] as String,
      stateCode: json['stateCode'] as String?,
      level: json['level'] as String? ?? 'STATE',
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'countryCode': countryCode,
        if (stateCode != null) 'stateCode': stateCode,
        'level': level,
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
      };

  String get displayName => stateCode != null ? '$name, $countryCode' : name;
}

