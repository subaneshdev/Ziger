import 'wallet_repository.dart';
import '../../services/api_service.dart';
import '../../models/transaction_model.dart';

class ApiWalletRepository implements WalletRepository {
  final ApiService _api = ApiService();

  @override
  Future<double> getBalance(String userId) async {
    final response = await _api.get('/wallet/balance');
    if (response != null && response['balance'] != null) {
      return (response['balance'] as num).toDouble();
    }
    return 0.0;
  }

  @override
  Future<List<Transaction>> getTransactions(String userId) async {
    final response = await _api.get('/wallet/transactions');
    if (response == null) return [];
    return (response as List).map((json) => Transaction.fromJson(json)).toList();
  }

  @override
  Future<void> deposit(String userId, double amount) async {
    await _api.post('/wallet/deposit', {'amount': amount});
  }
}
