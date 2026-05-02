class PartyModel {
  final String id;
  final String name;
  final String? acronym;
  final String? logoUrl;
  final String? description;
  final String? color; // hex
  final String status; // PENDING | APPROVED | SUSPENDED
  final String? website;
  final int memberCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PartyModel({
    required this.id,
    required this.name,
    this.acronym,
    this.logoUrl,
    this.description,
    this.color,
    required this.status,
    this.website,
    this.memberCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PartyModel.fromJson(Map<String, dynamic> json) => PartyModel(
        id: json['id'] as String,
        name: json['name'] as String,
        acronym: json['acronym'] as String?,
        logoUrl: json['logoUrl'] as String?,
        description: json['description'] as String?,
        color: json['color'] as String?,
        status: json['status'] as String? ?? 'PENDING',
        website: json['website'] as String?,
        memberCount: json['memberCount'] as int? ?? 0,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (acronym != null) 'acronym': acronym,
        if (logoUrl != null) 'logoUrl': logoUrl,
        'status': status,
        'memberCount': memberCount,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  bool get isApproved => status == 'APPROVED';
  String get displayName => acronym != null ? '$name ($acronym)' : name;
}
