class VoteModel {
  final String id;
  final String userId;
  final String electionId;
  final String candidateId;
  final String? nullifier; // zk-proof nullifier (on-chain)
  final String? txHash; // blockchain tx hash
  final bool isOnChain;
  final DateTime createdAt;

  const VoteModel({
    required this.id,
    required this.userId,
    required this.electionId,
    required this.candidateId,
    this.nullifier,
    this.txHash,
    this.isOnChain = false,
    required this.createdAt,
  });

  factory VoteModel.fromJson(Map<String, dynamic> json) => VoteModel(
        id: json['id'] as String,
        userId: json['userId'] as String,
        electionId: json['electionId'] as String,
        candidateId: json['candidateId'] as String,
        nullifier: json['nullifier'] as String?,
        txHash: json['txHash'] as String?,
        isOnChain: json['isOnChain'] as bool? ?? false,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'electionId': electionId,
        'candidateId': candidateId,
        if (nullifier != null) 'nullifier': nullifier,
        if (txHash != null) 'txHash': txHash,
        'isOnChain': isOnChain,
        'createdAt': createdAt.toIso8601String(),
      };
}
