import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/repositories/wallet_repository.dart';
import '../../models/transaction_model.dart';
import '../../features/auth/auth_provider.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  double _balance = 0.0;
  List<Transaction> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final user = context.read<AuthProvider>().userProfile;
    if (user == null) return;

    final repo = context.read<WalletRepository>();
    setState(() => _isLoading = true);

    try {
      final balance = await repo.getBalance(user.id);
      final txns = await repo.getTransactions(user.id);
      if (mounted) {
        setState(() {
          _balance = balance;
          _transactions = txns;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Wallet Error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deposit() async {
    final user = context.read<AuthProvider>().userProfile;
    if (user == null) return;
    
    // Simple Dialog for deposit
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Funds'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Amount (\$)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(controller.text);
              if (amount != null && amount > 0) {
                Navigator.pop(context);
                await context.read<WalletRepository>().deposit(user.id, amount);
                _fetchData(); // Refresh
              }
            },
            child: const Text('Deposit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wallet', style: GoogleFonts.outfit(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.grey.shade50,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Balance Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Color(0xFF1E3A8A), Colors.blue.shade700]),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 10, offset: Offset(0, 5))],
                      ),
                      child: Column(
                        children: [
                          Text('Available Balance', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14)),
                          const SizedBox(height: 8),
                          Text(
                             NumberFormat.currency(symbol: '\$').format(_balance),
                            style: GoogleFonts.outfit(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _deposit,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Funds'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Color(0xFF1E3A8A),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    Text('Recent Transactions', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),

                    if (_transactions.isEmpty)
                      const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('No transactions yet'))),

                    ..._transactions.map((txn) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: txn.isCredit ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              txn.isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                              color: txn.isCredit ? Colors.green : Colors.red,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(txn.description, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                                Text(txn.formattedDate, style: GoogleFonts.outfit(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                          ),
                          Text(
                            '${txn.isCredit ? '+' : '-'}\$${txn.amount.toStringAsFixed(2)}',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              color: txn.isCredit ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ),
    );
  }
}
