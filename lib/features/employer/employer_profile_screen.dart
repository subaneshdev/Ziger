import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../auth/auth_provider.dart';

class EmployerProfileScreen extends StatelessWidget {
  const EmployerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.userProfile;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('My Profile', style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: (user?.profilePhotoUrl != null && 
                        user!.profilePhotoUrl!.isNotEmpty &&
                        user!.profilePhotoUrl!.startsWith('http'))
                        ? NetworkImage(user!.profilePhotoUrl!)
                        : null,
                    backgroundColor: Colors.grey.shade200,
                    child: (user?.profilePhotoUrl == null || 
                            user!.profilePhotoUrl!.isEmpty || 
                            !user!.profilePhotoUrl!.startsWith('http'))
                        ? const Icon(Icons.person, size: 50, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.fullName ?? 'Employer Name',
                    style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    user?.email ?? 'email@example.com',
                    style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            
            _buildProfileOption(
              icon: Icons.person_outline,
              label: 'Edit Profile',
              onTap: () {},
            ),
            _buildProfileOption(
              icon: Icons.payment,
              label: 'Payment Methods',
              onTap: () {},
            ),
            _buildProfileOption(
              icon: Icons.history,
              label: 'Transaction History',
              onTap: () => context.push('/wallet'),
            ),
            _buildProfileOption(
              icon: Icons.settings_outlined,
              label: 'Settings',
              onTap: () {},
            ),
            const SizedBox(height: 20),
             _buildProfileOption(
              icon: Icons.logout,
              label: 'Log Out',
              onTap: () {
                auth.logout();
                context.go('/login');
              },
              isDestructive: true,
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 30),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 5)),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(icon: const Icon(Icons.home_outlined, color: Colors.white54), onPressed: () => context.push('/employer/home')),
              IconButton(icon: const Icon(Icons.add_circle_outline, color: Colors.white54), onPressed: () => context.push('/employer/create-gig')),
              IconButton(icon: const Icon(Icons.chat_bubble_outline, color: Colors.white54), onPressed: () => context.push('/chats')),
              IconButton(icon: const Icon(Icons.person, color: Colors.white), onPressed: () {}),
            ],
          ),
       ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive ? Colors.red.shade50 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: isDestructive ? Colors.red : Colors.black),
      ),
      title: Text(
        label,
        style: GoogleFonts.outfit(
          color: isDestructive ? Colors.red : Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
    );
  }
}
