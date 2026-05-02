class WalletTransactionModel {
  final String id;
  final String userId;
  final String type; // DEPOSIT | WITHDRAWAL | REWARD | REFUND
  final double amount;
  final String currency;
  final String status; // PENDING | CONFIRMED | FAILED
  final String? txHash;
  final String? description;
  final DateTime createdAt;

  const WalletTransactionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.currency,
    required this.status,
    this.txHash,
    this.description,
    required this.createdAt,
  });

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) =>
      WalletTransactionModel(
        id: json['id'] as String,
        userId: json['userId'] as String,
        type: json['type'] as String? ?? 'DEPOSIT',
        amount: (json['amount'] as num).toDouble(),
        currency: json['currency'] as String? ?? 'NGN',
        status: json['status'] as String? ?? 'PENDING',
        txHash: json['txHash'] as String?,
        description: json['description'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'type': type,
        'amount': amount,
        'currency': currency,
        'status': status,
        if (txHash != null) 'txHash': txHash,
        if (description != null) 'description': description,
        'createdAt': createdAt.toIso8601String(),
      };

  bool get isConfirmed => status == 'CONFIRMED';
  bool get isPending => status == 'PENDING';
}

class WalletBalanceModel {
  final double available;
  final double pending;
  final String currency;
  final String? walletAddress;

  const WalletBalanceModel({
    required this.available,
    required this.pending,
    required this.currency,
    this.walletAddress,
  });

  factory WalletBalanceModel.fromJson(Map<String, dynamic> json) =>
      WalletBalanceModel(
        available: (json['available'] as num).toDouble(),
        pending: (json['pending'] as num? ?? 0).toDouble(),
        currency: json['currency'] as String? ?? 'NGN',
        walletAddress: json['walletAddress'] as String?,
      );
}
