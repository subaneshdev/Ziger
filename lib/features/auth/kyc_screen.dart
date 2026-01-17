import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import 'auth_provider.dart';

class KycScreen extends StatefulWidget {
  const KycScreen({super.key});

  @override
  State<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends State<KycScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // --- Step 1: Basic & Address ---
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  String _gender = 'Male';

  // --- Step 2: Identity ---
  String _idType = 'Aadhaar';
  final TextEditingController _idNumberController = TextEditingController();
  File? _idFront;
  File? _idBack;
  File? _selfie;
  File? _profileImage; // New Profile Image
  final ImagePicker _picker = ImagePicker();

  // --- Step 3: Bank Details ---
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _accountNumController = TextEditingController();
  final TextEditingController _ifscController = TextEditingController();
  final TextEditingController _upiController = TextEditingController();
  
  // --- Step 4: Work Preferences ---
  double _radius = 10;
  bool _willingToTravel = true;
  final List<String> _selectedGigTypes = [];
  final List<String> _gigOptions = ['Delivery', 'Driver', 'Cleaning', 'Repair', 'Event Hand', 'Caregiver'];

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _addressController.dispose();
    _idNumberController.dispose();
    _bankNameController.dispose();
    _accountNumController.dispose();
    _ifscController.dispose();
    _upiController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(String type) async {
    final XFile? photo = await _picker.pickImage(source: type == 'selfie' ? ImageSource.camera : ImageSource.gallery);
    if (photo != null) {
      setState(() {
        if (type == 'front') _idFront = File(photo.path);
        if (type == 'back') _idBack = File(photo.path);
        if (type == 'selfie') _selfie = File(photo.path);
        if (type == 'profile') _profileImage = File(photo.path);
      });
    }
  }

  Future<void> _submitKyc() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fix the errors in the form')));
      return;
    }

    if (_idFront == null || _idBack == null || _profileImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please upload Profile Photo and ID Proofs')));
      return;
    }

    final data = {
      // Step 1
      'full_name': _nameController.text,
      'date_of_birth': _dobController.text,
      'gender': _gender,
      'address': _addressController.text,
      'city': _cityController.text,
      'state': _stateController.text,
      'pincode': _pincodeController.text,
      
      // Step 2
      'id_type': _idType,
      'id_card_number': _idNumberController.text,
      
      // Step 3
      'bank_account_name': _bankNameController.text,
      'bank_account_number': _accountNumController.text,
      'bank_ifsc': _ifscController.text,
      'upi_id': _upiController.text,
      
      // Step 4
      'work_preferences': {
        'types': _selectedGigTypes,
        'radius_km': _radius,
        'willing_to_travel': _willingToTravel,
      },
    };

    final success = await context.read<AuthProvider>().submitKyc(
      data, 
      idFront: _idFront,
      idBack: _idBack,
      selfie: null, // HIDDEN FOR DEV
      profileImage: _profileImage,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('KYC Submitted Successfully!')));
      // Redirect to Home properly
      context.go('/worker/home');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Submission Failed. Try again.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.userProfile;
    final kycStatus = user?.kycStatus ?? 'pending';
    
    // Only show "Pending View" if we actually have submitted data.
    // Otherwise, assume it's a fresh user who needs to fill the form.
    final hasSubmittedData = user?.idCardNumber != null && user!.idCardNumber!.isNotEmpty;

    // Constraint: One Profile, One KYC.
    // If user has already submitted (determined by having ID number), prevent form    // Constraint: One Profile, One KYC.
    // if (user != null && user.idCardNumber != null && user.idCardNumber!.isNotEmpty) {
    //    // If approved or pending, go to home
    //    if (kycStatus == 'pending' || kycStatus == 'approved') {
    //       // Schedule redirect to prevent build loop
    //       WidgetsBinding.instance.addPostFrameCallback((_) {
    //          if (mounted) context.go('/worker/home');
    //       });
    //       return const Scaffold(body: Center(child: CircularProgressIndicator()));
    //    }
    // }

    // if (authProvider.userProfile?.kycStatus == 'pending') {
    //   return _buildPendingView();
    // }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Partner KYC'),
        actions: [
          IconButton(
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              context.go('/login');
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: authProvider.isLoading 
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: Stepper(
                type: StepperType.horizontal,
                currentStep: _currentStep,
                onStepContinue: () {
                   // Validate current step requirements
                   if (_currentStep == 0) {
                      if (_profileImage == null) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please upload a profile photo')));
                        return;
                      }
                   }
                   if (_currentStep == 1) {
                      if (_idFront == null || _idBack == null) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please upload both ID Front and Back photos')));
                        return;
                      }
                   }

                   if (_currentStep < 3) {
                     setState(() => _currentStep += 1);
                   } else {
                     _submitKyc();
                   }
                },
                onStepCancel: () {
                  if (_currentStep > 0) {
                    setState(() => _currentStep -= 1);
                  }
                },
                controlsBuilder: (context, details) {
                   return Padding(
                     padding: const EdgeInsets.only(top: 24.0),
                     child: Row(
                       children: [
                         Expanded(
                           child: ElevatedButton(
                             onPressed: details.onStepContinue,
                             child: Text(_currentStep == 3 ? 'Submit Application' : 'Next Step'),
                           ),
                         ),
                         if (_currentStep > 0) ...[
                           const SizedBox(width: 12),
                           TextButton(
                             onPressed: details.onStepCancel,
                             child: const Text('Back'),
                           ),
                         ],
                       ],
                     ),
                   );
                },
                steps: [
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(),
                  _buildStep4(),
                ],
              ),
            ),
    );
  }

  Step _buildStep1() {
    return Step(
      title: const Text('Basics'),
      isActive: _currentStep >= 0,
      content: Column(
        children: [
            // Profile Image Picker
            Center(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () => _pickImage('profile'),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                      child: _profileImage == null
                          ? const Icon(Icons.person, size: 50, color: Colors.grey)
                          : null,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit, size: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _dobController,
                  readOnly: true, // Prevent manual editing
                  decoration: const InputDecoration(labelText: 'DOB (YYYY-MM-DD)', border: OutlineInputBorder()),
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                  onTap: () async {
                     FocusScope.of(context).requestFocus(FocusNode());
                     final date = await showDatePicker(context: context, initialDate: DateTime(2000), firstDate: DateTime(1960), lastDate: DateTime.now());
                     if(date!=null) _dobController.text = date.toIso8601String().split('T')[0];
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _gender,
                  items: ['Male', 'Female', 'Other'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) => setState(() => _gender = v!),
                  decoration: const InputDecoration(labelText: 'Gender', border: OutlineInputBorder()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(controller: _addressController, decoration: const InputDecoration(labelText: 'Current Address', border: OutlineInputBorder()), maxLines: 2),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: TextFormField(controller: _cityController, decoration: const InputDecoration(labelText: 'City', border: OutlineInputBorder()))),
              const SizedBox(width: 8),
              Expanded(child: TextFormField(controller: _stateController, decoration: const InputDecoration(labelText: 'State', border: OutlineInputBorder()))),
              const SizedBox(width: 8),
              Expanded(child: TextFormField(controller: _pincodeController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Pincode', border: OutlineInputBorder()))),
            ],
          ),
        ],
      ),
    );
  }

  Step _buildStep2() {
    return Step(
      title: const Text('Identity'),
      isActive: _currentStep >= 1,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           DropdownButtonFormField<String>(
             value: _idType,
             items: ['Aadhaar', 'Driving License', 'Voter ID', 'Passport'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
             onChanged: (v) => setState(() => _idType = v!),
             decoration: const InputDecoration(labelText: 'ID Type', border: OutlineInputBorder()),
           ),
           const SizedBox(height: 12),
           TextFormField(
             controller: _idNumberController,
             decoration: const InputDecoration(labelText: 'ID Number', border: OutlineInputBorder()),
           ),
           const SizedBox(height: 24),
           const Text('Upload Documents', style: TextStyle(fontWeight: FontWeight.bold)),
           const SizedBox(height: 12),
           Row(
             children: [
               Expanded(child: _buildImagePicker('front', 'ID Front', _idFront)),
               const SizedBox(width: 12),
               Expanded(child: _buildImagePicker('back', 'ID Back', _idBack)),
             ],
           ),
           const SizedBox(height: 12),
           // _buildImagePicker('selfie', 'Take Live Selfie', _selfie), // HIDDEN FOR DEV

        ],
      ),
    );

  }

  Widget _buildImagePicker(String type, String label, File? file) {
    return GestureDetector(
      onTap: () => _pickImage(type),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: file != null 
          ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(file, fit: BoxFit.cover))
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                 Icon(type == 'selfie' ? Icons.camera : Icons.upload_file, color: Colors.grey),
                 Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
      ),
    );
  }

  Step _buildStep3() {
    return Step(
      title: const Text('Bank'),
      isActive: _currentStep >= 2,
      content: Column(
        children: [
          TextFormField(controller: _bankNameController, decoration: const InputDecoration(labelText: 'Account Holder Name', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextFormField(controller: _accountNumController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Account Number', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextFormField(controller: _ifscController, decoration: const InputDecoration(labelText: 'IFSC Code', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextFormField(controller: _upiController, decoration: const InputDecoration(labelText: 'UPI ID (Optional)', border: OutlineInputBorder())),
        ],
      ),
    );
  }

  Step _buildStep4() {
    return Step(
      title: const Text('Work'),
      isActive: _currentStep >= 3,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select Gig Types:', style: TextStyle(fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 8,
            children: _gigOptions.map((gig) {
              final isSelected = _selectedGigTypes.contains(gig);
              return FilterChip(
                label: Text(gig),
                selected: isSelected,
                onSelected: (val) {
                  setState(() {
                    if (val) _selectedGigTypes.add(gig);
                    else _selectedGigTypes.remove(gig);
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text('Working Radius: ${_radius.round()} km'),
          Slider(
            value: _radius,
            min: 1,
            max: 50,
            divisions: 49,
            label: '${_radius.round()} km',
            onChanged: (val) => setState(() => _radius = val),
          ),
          SwitchListTile(
            title: const Text('Willing to Travel?'),
            value: _willingToTravel,
            onChanged: (val) => setState(() => _willingToTravel = val),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingView() {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.timer_outlined, size: 80, color: Colors.orange),
              const SizedBox(height: 24),
              Text(
                'Verification In Progress',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Your expanded profile is under review by our team. This covers Identity, Banking, and Work verification.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSub, fontSize: 16),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                   Provider.of<AuthProvider>(context, listen: false).logout();
                   context.go('/login');
                },
                child: const Text('Logout'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
