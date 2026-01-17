import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/supabase_service.dart';
import '../../core/theme.dart';
import '../auth/auth_provider.dart';
import 'package:provider/provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final SupabaseService _supabase = SupabaseService();
  List<Map<String, dynamic>> _pendingUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPendingUsers();
  }

  Future<void> _fetchPendingUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await _supabase.getPendingKycUsers();
      setState(() {
        _pendingUsers = users;
      });
    } catch (e) {
      debugPrint('Error fetching pending users: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(String userId, String status) async {
    try {
      await _supabase.updateKycStatus(userId, status);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User $status')));
      _fetchPendingUsers(); // Refresh list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
               Provider.of<AuthProvider>(context, listen: false).logout();
               context.go('/login');
            },
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pendingUsers.isEmpty
              ? const Center(child: Text('No pending KYC requests'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _pendingUsers.length,
                  itemBuilder: (context, index) {
                    final user = _pendingUsers[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(user),
                            const Divider(),
                            _buildSection('Address', '${user['address']}, ${user['city']}, ${user['state']} - ${user['pincode']}'),
                            const SizedBox(height: 8),
                            _buildSection('Bank Details', 
                              '${user['bank_account_name']}\nAc: ${user['bank_account_number']}\nIFSC: ${user['bank_ifsc']}\nUPI: ${user['upi_id'] ?? '-'}'),
                             const SizedBox(height: 8),
                            _buildWorkPrefs(user['work_preferences']),
                            const SizedBox(height: 12),
                            const Text('Documents:', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  if (user['id_card_front_url'] != null) _buildDocThumb(context, user['id_card_front_url'], 'Front'),
                                  if (user['id_card_back_url'] != null) ...[const SizedBox(width: 8), _buildDocThumb(context, user['id_card_back_url'], 'Back')],
                                  if (user['selfie_url'] != null) ...[const SizedBox(width: 8), _buildDocThumb(context, user['selfie_url'], 'Selfie')],
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () => _updateStatus(user['id'], 'rejected'),
                                  icon: const Icon(Icons.close, color: Colors.red),
                                  label: const Text('Reject', style: TextStyle(color: Colors.red)),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton.icon(
                                  onPressed: () => _updateStatus(user['id'], 'approved'),
                                  icon: const Icon(Icons.check),
                                  label: const Text('Approve'),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> user) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: const Icon(Icons.person, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user['full_name'] ?? 'Unknown Name',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              '${user['id_type']}: ${user['id_card_number'] ?? 'N/A'}',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
        Text(content, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildWorkPrefs(dynamic prefs) {
    if (prefs == null) return const SizedBox.shrink();
    // Supabase returns JSONB as Map
    final map = prefs as Map<String, dynamic>;
    final types = (map['types'] as List?)?.join(', ') ?? 'None';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Work Preferences', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
        Text('Types: $types'),
        Text('Radius: ${map['radius_km']} km | Travel: ${map['willing_to_travel'] == true ? "Yes" : "No"}'),
      ],
    );
  }

  Widget _buildDocThumb(BuildContext context, String url, String label) {
    if (!url.startsWith('http')) return const SizedBox.shrink();
    
    return GestureDetector(
      onTap: () {
        showDialog(context: context, builder: (_) => Dialog(child: Image.network(url)));
      },
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              url,
              height: 80,
              width: 80,
              fit: BoxFit.cover,
              errorBuilder: (c,e,s) => Container(
                height: 80, width: 80,
                color: Colors.grey[200], 
                child: const Icon(Icons.broken_image, size: 20),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
}
