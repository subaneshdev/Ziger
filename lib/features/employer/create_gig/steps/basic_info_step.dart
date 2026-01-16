import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../services/api_service.dart';

class BasicInfoStep extends StatelessWidget {
  final Map<String, dynamic> data;
  final Function(String key, dynamic value) onUpdate;
  final VoidCallback onNext;

  const BasicInfoStep({
    super.key,
    required this.data,
    required this.onUpdate,
    required this.onNext,
  });

  Future<void> _refineDescription() async {
     final currentText = data['description'];
     if (currentText == null || currentText.isEmpty) return;

     try {
       final response = await ApiService().post('/ai/refine', {'text': currentText});
       if (response != null && response['refinedText'] != null) {
         onUpdate('description', response['refinedText']);
       }
     } catch (e) {
       debugPrint('AI Refine Error: $e');
     }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Basic Details',
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Title
          _buildLabel('Job Title'),
          TextFormField(
            initialValue: data['title'],
            decoration: _inputDecoration('e.g., Event Waiter needed urgently'),
            onChanged: (val) => onUpdate('title', val),
          ),
          const SizedBox(height: 20),

          // Description
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLabel('Description / Instructions'),
              TextButton.icon(
                onPressed: _refineDescription,
                icon: const Icon(Icons.auto_awesome, size: 16, color: Colors.purple),
                label: Text('Refine with AI', style: GoogleFonts.outfit(color: Colors.purple, fontWeight: FontWeight.bold, fontSize: 12)),
                style: TextButton.styleFrom(
                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                   backgroundColor: Colors.purple.withOpacity(0.1),
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ],
          ),
          TextFormField(
            controller: TextEditingController(text: data['description'])..selection = TextSelection.fromPosition(TextPosition(offset: (data['description'] as String).length)),
            maxLines: 4,
            decoration: _inputDecoration('Describe the work in detail...'),
            onChanged: (val) => onUpdate('description', val),
          ),
          const SizedBox(height: 20),

          // Worker Count
          _buildLabel('Number of Workers'),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  int current = data['workers_required'] as int;
                  if (current > 1) onUpdate('workers_required', current - 1);
                },
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Text(
                '${data['workers_required']}',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () {
                  int current = data['workers_required'] as int;
                  onUpdate('workers_required', current + 1);
                },
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Payment Type
          _buildLabel('Payment Type'),
          Row(
            children: [
              _buildRadioOption('Fixed Price', 'fixed'),
              const SizedBox(width: 16),
              _buildRadioOption('Per Hour', 'hourly'),
            ],
          ),
          const SizedBox(height: 20),

          // Payout Amount
          _buildLabel(data['payment_type'] == 'fixed' ? 'Total Amount (\$)' : 'Hourly Rate (\$)'),
          TextFormField(
            initialValue: data['payout'] == 0.0 ? '' : data['payout'].toString(),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: _inputDecoration('0.00'),
            onChanged: (val) => onUpdate('payout', double.tryParse(val) ?? 0.0),
          ),

          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                final title = data['title'] as String?;
                final description = data['description'] as String?;
                final payout = data['payout'] as double?;

                if (title == null || title.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a Job Title')));
                  return;
                }
                if (description == null || description.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a Description')));
                  return;
                }
                if (payout == null || payout <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid Payout amount')));
                  return;
                }

                onNext();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Next: Requirements', style: GoogleFonts.outfit(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.black)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _buildRadioOption(String label, String value) {
    bool selected = data['payment_type'] == value;
    return GestureDetector(
      onTap: () => onUpdate('payment_type', value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.black : Colors.white,
          border: Border.all(color: selected ? Colors.black : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: selected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
