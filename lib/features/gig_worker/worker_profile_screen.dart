import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../features/auth/auth_provider.dart';

class WorkerProfileScreen extends StatelessWidget {
  const WorkerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().userProfile;
    // Determine image provider safely
    final ImageProvider? imageProvider = (user?.profilePhotoUrl != null && user!.profilePhotoUrl!.isNotEmpty)
        ? NetworkImage(user!.profilePhotoUrl!)
        : null;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () {
               Provider.of<AuthProvider>(context, listen: false).logout();
               context.go('/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 60), // Top spacing
            // Profile Image Section with Abstract Shapes
            SizedBox(
              height: 380, // Adjust based on screen size
              child: Stack(
                alignment: Alignment.center,
                children: [
                   // Background Shapes (Abstract) - approximate positioning
                   Positioned(
                     top: 40,
                     left: 40,
                     child: Container(
                       width: 150,
                       height: 150,
                       decoration: const BoxDecoration(
                         color: Color(0xFFFDEFD6), // Cream color
                         shape: BoxShape.circle,
                       ),
                     ),
                   ),
                   Positioned(
                     bottom: 40,
                     right: 0,
                     child: Container(
                       width: 140,
                       height: 140,
                       decoration: const BoxDecoration(
                         color: Color(0xFFCEF4E6), // Mint/Cyan light
                         shape: BoxShape.circle,
                       ),
                     ),
                   ),
                   Positioned(
                     bottom: 100,
                     left: 0,
                     child: Container(
                       width: 100,
                       height: 100,
                       decoration: const BoxDecoration(
                         color: Color(0xFFB39DDB), // Light Purple
                         borderRadius: BorderRadius.only(
                            topRight: Radius.circular(100),
                            bottomRight: Radius.circular(100),
                         ),
                       ),
                     ),
                   ),
                   
                   // User Image
                   // If transparent background images are used, we can overlay them.
                   // Assuming standard profile photo, we make it prominent.
                   Positioned(
                     top: 0,
                     child: CircleAvatar(
                        radius: 120, // Large size
                        backgroundColor: Colors.grey.shade100,
                        backgroundImage: imageProvider,
                        child: imageProvider == null
                            ? const Icon(Icons.person, size: 80, color: Colors.grey)
                            : null,
                     ),
                   ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),

            // Name
            Text(
              user?.fullName ?? 'No Name',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            
            const SizedBox(height: 8),

            // Status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.transparent, 
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    user?.role == 'worker' ? 'Actively Looking' : 'Hiring',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1E293B), // Dark slate
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFCEF4E6), // Mint color
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, size: 16, color: Colors.black),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Stats Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatItem('Active', '${user?.activeOrders ?? 0}'),
                  _buildStatItem('Completed', '${user?.completedOrders ?? 0}'),
                  GestureDetector(
                    onTap: () => context.push('/wallet'),
                    child: _buildStatItem('Wallet', '\$${user?.walletBalance ?? 0.0}'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Bottom Card "Complete Profile"
            Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0), // Peach/Light Orange
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Complete Profile',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Personal | Job Experience | Certification',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      color: Colors.black,
                      onPressed: () {
                         // TODO: Navigate to edit profile
                      },
                    ),
                  ),
                ],
              ),
            ),
             const SizedBox(height: 10),
             TextButton(
               onPressed: () {
                 context.go('/role-selection');
               },
               child: Text('Switch Role', style: GoogleFonts.outfit(color: Colors.blue)),
             ),
             const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 16,
            color: Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
