import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_frontend_vote/app/domain/models/wallet_model.dart';
import 'package:flutter_frontend_vote/app/domain/repositories/wallet_repository.dart';

final walletRepositoryProvider =
    Provider<WalletRepository>((ref) => WalletRepository());

final walletBalanceProvider = FutureProvider<WalletBalanceModel>((ref) async {
  return ref.read(walletRepositoryProvider).getBalance();
});

final walletTransactionsProvider =
    FutureProvider<List<WalletTransactionModel>>((ref) async {
  return ref.read(walletRepositoryProvider).getTransactions();
});

/// Connected wallet address (set after WalletConnect succeeds).
final connectedWalletAddressProvider = StateProvider<String?>((ref) => null);

/// Whether the user's account has a linked wallet.
final hasLinkedWalletProvider = Provider<bool>((ref) {
  // Derived from auth user model — walletAddress is set after binding.
  return false; // resolved via currentUserProvider in UI layer
});
