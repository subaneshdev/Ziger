import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DynamicRequirementsStep extends StatelessWidget {
  final String category;
  final Map<String, dynamic> requirements;
  final Function(String key, dynamic value) onUpdate;
  final VoidCallback onNext;

  const DynamicRequirementsStep({
    super.key,
    required this.category,
    required this.requirements,
    required this.onUpdate,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Specific Requirements',
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Details for ${category.toUpperCase()}',
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),

          // Dynamic Fields based on Category
          ..._buildDynamicFields(),

          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Next: Logistics', style: GoogleFonts.outfit(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDynamicFields() {
    switch (category) {
      case 'catering':
        return [
          _buildTextField('dress_code', 'Dress Code', 'e.g., Black Shirt & Trousers'),
          _buildDropdown('gloves_mask', 'Gloves/Mask Required?', ['Yes', 'No']),
          _buildTextField('guest_count', 'Number of Guests', 'e.g., 50'),
        ];
      case 'packers':
        return [
          _buildTextField('package_type', 'Package Type', 'e.g., Furniture, Boxes'),
          _buildDropdown('fragile', 'Fragile Handling?', ['Yes', 'No']),
          _buildTextField('weight_range', 'Weight Range', 'e.g., 10-20kg'),
          _buildTextField('safety_gear', 'Safety Gear', 'e.g., Gloves, Boots'),
        ];
      case 'driver':
        return [
          _buildDropdown('vehicle_type', 'Vehicle Required', ['Bike', 'Car', 'Van', 'Truck']),
          _buildTextField('license_type', 'License Type', 'e.g., Light Motor Vehicle'),
          _buildTextField('route_details', 'Route / Area', 'e.g., City Center to Airport'),
          _buildDropdown('fuel_responsibility', 'Fuel Responsibility', ['Company', 'Driver']),
        ];
      case 'cleaning':
        return [
          _buildDropdown('space_type', 'Space Type', ['Home', 'Office', 'Venue']),
          _buildTextField('area_size', 'Area Size (sq ft)', 'e.g., 1200'),
          _buildDropdown('scope', 'Cleaning Scope', ['Basic', 'Deep Clean']),
          _buildDropdown('supplies_needed', 'Supplies Provided?', ['Yes', 'No, Bring Your Own']),
        ];
      case 'communication':
        return [
          _buildTextField('languages', 'Languages Required', 'e.g., English, Spanish'),
          _buildDropdown('event_type', 'Event Type', ['Corporate', 'Party', 'Wedding']),
          _buildTextField('audience_size', 'Audience Size', 'e.g., 200+'),
        ];
      case 'construction':
        return [
          _buildDropdown('trade_type', 'Trade Type', ['Helper', 'Mason', 'Electrician', 'Plumber']),
          _buildDropdown('ppe_required', 'PPE Required?', ['Yes', 'No']),
          _buildTextField('certification', 'Certifications (Optional)', 'Any safety cards?'),
        ];
      case 'event_coord':
        return [
          _buildTextField('event_type', 'Event Type', 'e.g., Concert'),
          _buildTextField('crowd_size', 'Estimated Crowd', 'e.g., 1000'),
          _buildDropdown('physical_work', 'Physical Work Involved?', ['Yes, Light', 'Yes, Heavy', 'No']),
        ];
       case 'stall':
        return [
          _buildTextField('stall_type', 'Stall Type', 'e.g., Food, Merch'),
          _buildDropdown('cash_handling', 'Cash Handling Required?', ['Yes', 'No']),
          _buildTextField('sales_exp', 'Sales Experience', 'e.g., 1+ Years'),
        ];
      default:
        return [
           const Text("No specific requirements for this category."),
        ];
    }
  }

  Widget _buildTextField(String key, String label, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: requirements[key]?.toString(),
            onChanged: (val) => onUpdate(key, val),
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String key, String label, List<String> options) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: requirements[key] as String?,
            items: options.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
            onChanged: (val) => onUpdate(key, val),
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}
