import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LogisticsStep extends StatelessWidget {
  final Map<String, dynamic> data;
  final Function(String key, dynamic value) onUpdate;
  final VoidCallback onNext;

  const LogisticsStep({
    super.key,
    required this.data,
    required this.onUpdate,
    required this.onNext,
  });

  Future<void> _selectDateTime(BuildContext context, String key) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2027),
    );
    if (pickedDate == null) return;

    if (!context.mounted) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime == null) return;

    final DateTime combined = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
    
    onUpdate(key, combined);
  }

  // Helper to format date/time
  String _formatDateTime(DateTime? dt) {
    if (dt == null) return '';
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final startTime = data['start_time'] as DateTime?;
    final endTime = data['end_time'] as DateTime?;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Time & Location',
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Location
          _buildLabel('Location Name'),
          TextFormField(
            initialValue: data['location_name'],
             onChanged: (val) => onUpdate('location_name', val),
            decoration: _inputDecoration('e.g., Central Park, NYC', Icons.location_on),
          ),
          const SizedBox(height: 12),
          // Map Placeholder
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   const Icon(Icons.map, color: Colors.grey, size: 40),
                   const SizedBox(height: 8),
                   Text('Map Select (Coming Soon)', style: GoogleFonts.outfit(color: Colors.grey)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Start Date
          _buildLabel('Start Date & Time'),
          GestureDetector(
             onTap: () => _selectDateTime(context, 'start_time'),
             child: AbsorbPointer(
               child: TextFormField(
                 decoration: _inputDecoration(startTime == null ? 'Select Start Date & Time' : _formatDateTime(startTime), Icons.calendar_today),
                 controller: TextEditingController(text: _formatDateTime(startTime)), 
               ),
             ),
          ),
          const SizedBox(height: 20),

          // End Date
          _buildLabel('End Date & Time'),
          GestureDetector(
             onTap: () => _selectDateTime(context, 'end_time'),
             child: AbsorbPointer(
               child: TextFormField(
                 decoration: _inputDecoration(endTime == null ? 'Select End Date & Time' : _formatDateTime(endTime), Icons.calendar_today),
                 controller: TextEditingController(text: _formatDateTime(endTime)),
               ),
             ),
          ),

          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                 if (data['location_name'] == null || (data['location_name'] as String).isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a Location Name')));
                    return;
                 }
                 if (data['start_time'] == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a Start Date & Time')));
                    return;
                 }
                 if (data['end_time'] == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select an End Date & Time')));
                    return;
                 }
                 final start = data['start_time'] as DateTime;
                 final end = data['end_time'] as DateTime;
                 if (end.isBefore(start)) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('End time cannot be before start time')));
                    return;
                 }

                 onNext();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Next: Review', style: GoogleFonts.outfit(color: Colors.white)),
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

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
