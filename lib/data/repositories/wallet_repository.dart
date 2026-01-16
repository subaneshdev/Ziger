import '../../models/transaction_model.dart';

abstract class WalletRepository {
  Future<double> getBalance(String userId);
  Future<List<Transaction>> getTransactions(String userId);
  Future<void> deposit(String userId, double amount);
}
