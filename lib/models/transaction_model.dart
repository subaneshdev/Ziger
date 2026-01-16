
import 'package:intl/intl.dart';

class Transaction {
  final String id;
  final double amount;
  final String type; // CREDIT, DEBIT
  final String description;
  final String timestamp;

  Transaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.description,
    required this.timestamp,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String,
      description: json['description'] as String,
      timestamp: json['createdAt'] as String, 
    );
  }

  String get formattedDate {
    // timestamp is ISO 8601 string
    try {
      final dt = DateTime.parse(timestamp);
      return DateFormat('MMM d, h:mm a').format(dt);
    } catch (e) {
      return timestamp;
    }
  }

  bool get isCredit => type == 'CREDIT';
}
