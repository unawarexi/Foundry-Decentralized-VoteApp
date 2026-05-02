import 'package:flutter_frontend_vote/core/network/api_client.dart';
import 'package:flutter_frontend_vote/core/apis/endpoints.dart';
import 'package:flutter_frontend_vote/app/domain/models/wallet_model.dart';

class WalletRepository {
  final _api = ApiClient.instance;

  Future<WalletBalanceModel> getBalance() async {
    final res = await _api.get(ApiEndpoints.walletBalance);
    return WalletBalanceModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<List<WalletTransactionModel>> getTransactions({int page = 1}) async {
    final res = await _api.get(
      ApiEndpoints.walletTransactions,
      queryParameters: {'page': page},
    );
    final list = res.data['data'] as List;
    return list.map((e) => WalletTransactionModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
