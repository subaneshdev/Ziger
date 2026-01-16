import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReviewStep extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onSubmit;
  final bool isSubmitting;

  const ReviewStep({
    super.key,
    required this.data,
    required this.onSubmit,
    this.isSubmitting = false,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review & Post',
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          _buildSummaryCard(),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: isSubmitting ? null : () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Confirm Payment'),
                    content: Text('A total of \$${data['payout']} will be held from your wallet. Do you want to proceed?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                      FilledButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          onSubmit();
                        },
                        child: const Text('Confirm & Post'),
                      ),
                    ],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text('Post Gig', style: GoogleFonts.outfit(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRow('Category', data['category'].toString().toUpperCase()),
          const Divider(height: 24),
          _buildRow('Title', data['title']),
          const SizedBox(height: 12),
          _buildRow('Pay', '\$${data['payout']} (${data['payment_type']})'),
          const Divider(height: 24),
          _buildRow('Location', data['location_name'] ?? 'TBD'),
          const SizedBox(height: 12),
          _buildRow('Start', data['start_time']?.toString().split(' ')[0] ?? 'TBD'),
          const Divider(height: 24),
           Text('Requirements:', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.grey)),
           const SizedBox(height: 8),
           ...(data['requirements'] as Map<String, dynamic>).entries.map((e) => Padding(
             padding: const EdgeInsets.only(bottom: 4.0),
             child: Text('• ${e.key}: ${e.value}', style: GoogleFonts.outfit()),
           )),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 100, child: Text(label, style: GoogleFonts.outfit(color: Colors.grey))),
        Expanded(child: Text(value, style: GoogleFonts.outfit(fontWeight: FontWeight.w600))),
      ],
    );
  }
}
