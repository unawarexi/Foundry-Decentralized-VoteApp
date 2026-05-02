class VerificationModel {
  final String id;
  final String userId;
  final String type; // FACE | LIVENESS | ID_SCAN | AGE
  final String status; // PENDING | PASSED | FAILED | EXPIRED
  final double? confidenceScore; // 0.0 – 1.0
  final String? failReason;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime? expiresAt;

  const VerificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.status,
    this.confidenceScore,
    this.failReason,
    this.metadata = const {},
    required this.createdAt,
    this.expiresAt,
  });

  factory VerificationModel.fromJson(Map<String, dynamic> json) =>
      VerificationModel(
        id: json['id'] as String,
        userId: json['userId'] as String,
        type: json['type'] as String,
        status: json['status'] as String? ?? 'PENDING',
        confidenceScore: json['confidenceScore'] != null
            ? (json['confidenceScore'] as num).toDouble()
            : null,
        failReason: json['failReason'] as String?,
        metadata:
            Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
        createdAt: DateTime.parse(json['createdAt'] as String),
        expiresAt: json['expiresAt'] != null
            ? DateTime.parse(json['expiresAt'] as String)
            : null,
      );

  bool get isPassed => status == 'PASSED';
  bool get isFailed => status == 'FAILED';
  bool get isExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!);
}
