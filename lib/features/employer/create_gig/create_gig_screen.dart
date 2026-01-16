import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'steps/category_step.dart';
import 'steps/basic_info_step.dart';
import 'steps/dynamic_requirements_step.dart';
import 'steps/logistics_step.dart';
import 'steps/review_step.dart';

import '../../../../data/repositories/task_repository.dart';
import '../../../../models/task_model.dart';
import '../../auth/auth_provider.dart';

class CreateGigScreen extends StatefulWidget {
  const CreateGigScreen({super.key});

  @override
  State<CreateGigScreen> createState() => _CreateGigScreenState();
}

class _CreateGigScreenState extends State<CreateGigScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 5;
  bool _isSubmitting = false;

  // Gig Data State
  final Map<String, dynamic> _gigData = {
    'category': '',
    'title': '',
    'description': '',
    'workers_required': 1,
    'payment_type': 'fixed',
    'payout': 0.0,
    'requirements': <String, dynamic>{},
    'location_name': '',
    'location_lat': 0.0,
    'location_lng': 0.0,
    'start_time': null,
    'end_time': null,
  };

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.pop(); 
    }
  }

  void _onStepChanged(int page) {
    setState(() {
      _currentStep = page;
    });
  }

  void _updateGigData(String key, dynamic value) {
    setState(() {
      _gigData[key] = value;
    });
  }

  void _updateRequirement(String key, dynamic value) {
    setState(() {
      final reqs = Map<String, dynamic>.from(_gigData['requirements']);
      reqs[key] = value;
      _gigData['requirements'] = reqs;
    });
  }

  Future<void> _submitGig() async {
    setState(() => _isSubmitting = true);
    
    try {
      final auth = context.read<AuthProvider>();
      final user = auth.userProfile;
      final newTask = Task(
        id: const Uuid().v4(), 
        employerId: user?.id ?? '', // Added employerId
        title: _gigData['title'],
        companyName: user?.fullName ?? 'Hiring', // Employer Name
        locationName: _gigData['location_name'] ?? 'Unknown',
        location: LatLng(_gigData['location_lat'], _gigData['location_lng']),
        payout: (_gigData['payout'] as num).toDouble(),
        distance: '0 km', // Placeholder
        time: (_gigData['start_time'] != null && _gigData['end_time'] != null)
            ? (_gigData['end_time'].difference(_gigData['start_time']).inHours).toString()
            : '4', // Default to 4 hours if not specified
        status: 'open',
        description: _gigData['description'],
        workersRequired: _gigData['workers_required'],
        paymentType: _gigData['payment_type'],
        startTime: _gigData['start_time'],
        endTime: _gigData['end_time'],
        category: _gigData['category'],
        requirements: _gigData['requirements'],
      );

      await context.read<TaskRepository>().createTask(newTask);

      if (mounted) {
        context.go('/employer/home');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gig Posted Successfully!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Error posting gig: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: _prevStep,
        ),
        title: Text(
          'Create Gig (${_currentStep + 1}/$_totalSteps)',
          style: GoogleFonts.outfit(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_currentStep + 1) / _totalSteps,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: _onStepChanged,
        children: [
          CategoryStep(
            selectedCategory: _gigData['category'],
            onCategorySelected: (cat) {
              _updateGigData('category', cat);
              _nextStep();
            },
          ),
          BasicInfoStep(
            data: _gigData,
            onUpdate: _updateGigData,
            onNext: _nextStep,
          ),
          DynamicRequirementsStep(
            category: _gigData['category'],
            requirements: _gigData['requirements'],
            onUpdate: _updateRequirement,
            onNext: _nextStep,
          ),
          LogisticsStep(
            data: _gigData,
            onUpdate: _updateGigData,
            onNext: _nextStep,
          ),
          ReviewStep(
            data: _gigData,
            onSubmit: _submitGig,
            isSubmitting: _isSubmitting,
          ),
        ],
      ),
    );
  }
}
