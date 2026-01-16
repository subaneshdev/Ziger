import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryStep extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategoryStep({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  final List<Map<String, dynamic>> _categories = const [
    {'id': 'catering', 'label': 'Catering', 'icon': Icons.restaurant_menu},
    {'id': 'packers', 'label': 'Packers', 'icon': Icons.inventory_2},
    {'id': 'driver', 'label': 'Driver', 'icon': Icons.directions_car},
    {'id': 'cleaning', 'label': 'Cleaning', 'icon': Icons.cleaning_services},
    {'id': 'communication', 'label': 'MC / Host', 'icon': Icons.mic},
    {'id': 'event_coord', 'label': 'Coordinator', 'icon': Icons.event_available},
    {'id': 'stall', 'label': 'Stall Work', 'icon': Icons.storefront},
    {'id': 'construction', 'label': 'Construction', 'icon': Icons.construction},
    {'id': 'volunteers', 'label': 'Volunteers', 'icon': Icons.volunteer_activism},
    {'id': 'performer', 'label': 'Performers', 'icon': Icons.theater_comedy},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What kind of help do you need?',
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select a category to customize your gig requirements.',
            style: GoogleFonts.outfit(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.3,
              ),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = cat['id'] == selectedCategory;
                return GestureDetector(
                  onTap: () => onCategorySelected(cat['id']),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.black : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.grey.shade200,
                        width: 2,
                      ),
                      boxShadow: [
                        if (!isSelected)
                          BoxShadow(
                            color: Colors.grey.shade100,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          cat['icon'],
                          size: 32,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          cat['label'],
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
