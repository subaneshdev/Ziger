import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import 'auth_provider.dart';

class EmployerKycScreen extends StatefulWidget {
  const EmployerKycScreen({super.key});

  @override
  State<EmployerKycScreen> createState() => _EmployerKycScreenState();
}

class _EmployerKycScreenState extends State<EmployerKycScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // --- Step 1: Basic Details ---
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  // --- Step 2: Business Details ---
  String _employerType = 'Individual';
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _natureController = TextEditingController(); // e.g., Retail, IT
  final TextEditingController _businessAddressController = TextEditingController();

  // --- Step 3: Identity Verification ---
  String _idType = 'Aadhaar';
  final TextEditingController _idNumberController = TextEditingController();
  File? _idFront;
  File? _idBack;
  File? _selfie;

  // --- Step 4: Payment & Billing ---
  String _paymentMethod = 'UPI';
  final TextEditingController _billingNameController = TextEditingController();
  final TextEditingController _gstController = TextEditingController();
  final TextEditingController _invoiceAddressController = TextEditingController();

  // --- Step 5: Compliance ---
  bool _agreedToTerms = false;


  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _businessNameController.dispose();
    _natureController.dispose();
    _businessAddressController.dispose();
    _idNumberController.dispose();
    _billingNameController.dispose();
    _gstController.dispose();
    _invoiceAddressController.dispose();
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

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please agree to the terms to proceed')));
      return;
    }

    if (_idFront == null || _idBack == null || _profileImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please upload Profile Photo and all required Verification Photos')));
      return;
    }

    final data = {
      // Step 1
      'full_name': _nameController.text,
      'email': _emailController.text,
      
      // Step 2
      'employer_type': _employerType,
      'business_name': _businessNameController.text,
      'nature_of_work': _natureController.text,
      'business_address': _businessAddressController.text,

      // Step 3
      'id_type': _idType,
      'id_card_number': _idNumberController.text,

      // Step 4
      'payment_method': _paymentMethod,
      'billing_name': _billingNameController.text,
      'gst_number': _gstController.text,
      'invoice_address': _invoiceAddressController.text,

      // Step 5
      'is_agreed_to_terms': _agreedToTerms,
    };

    final success = await context.read<AuthProvider>().submitKyc(
      data, 
      idFront: _idFront,
      idBack: _idBack,
      selfie: null, // HIDDEN FOR DEV
      profileImage: _profileImage,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Employer KYC Submitted Successfully!')));
      context.go('/employer/home');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Submission Failed. Try again.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    
    // Safety check if already approved (similar to worker logic)
    if (authProvider.isKycApproved && authProvider.userProfile?.role == 'employer') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
           if(mounted) context.go('/employer/home');
        });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employer Verification'),
        actions: [
          IconButton(
            onPressed: () {
              context.read<AuthProvider>().logout();
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
                type: StepperType.vertical,
                physics: const ClampingScrollPhysics(),
                currentStep: _currentStep,
                onStepContinue: () {
                   // Validate current step requirements
                   if (_currentStep == 0) { // Basics
                      if (_profileImage == null) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please upload a profile photo')));
                        return;
                      }
                   }
                   if (_currentStep == 2) { // Identity
                      if (_idFront == null || _idBack == null) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please upload both ID Front and Back photos')));
                        return;
                      }
                   }

                   if (_currentStep < 4) {
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
                         if (_currentStep > 0) ...[
                           Expanded(
                             child: OutlinedButton(
                               onPressed: details.onStepCancel,
                               child: const Text('Back'),
                             ),
                           ),
                           const SizedBox(width: 12),
                         ],
                         Expanded(
                           child: ElevatedButton(
                             onPressed: details.onStepContinue,
                             child: Text(_currentStep == 4 ? 'Complete' : 'Next'),
                           ),
                         ),
                       ],
                     ),
                   );
                },
                steps: [
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(),
                  _buildStep4(),
                  _buildStep5(),
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
          Center(
            child: GestureDetector(
              onTap: () => _pickImage('profile'),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                child: _profileImage == null
                    ? const Icon(Icons.business, size: 50, color: Colors.grey)
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
            validator: (v) => v!.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email Address', border: OutlineInputBorder()),
            validator: (v) => v!.contains('@') ? null : 'Invalid Email',
          ),
        ],
      ),
    );
  }

  Step _buildStep2() {
    return Step(
      title: const Text('Business'),
      isActive: _currentStep >= 1,
      content: Column(
        children: [
          DropdownButtonFormField<String>(
            value: _employerType,
            items: ['Individual', 'Small Business', 'Company'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() => _employerType = v!),
            decoration: const InputDecoration(labelText: 'Employer Type', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _businessNameController,
            decoration: const InputDecoration(labelText: 'Business Name (Optional)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _natureController,
            decoration: const InputDecoration(labelText: 'Nature of Work / Industry', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _businessAddressController,
            decoration: const InputDecoration(labelText: 'Business / Work Address', border: OutlineInputBorder()),
             maxLines: 2,
          ),
        ],
      ),
    );
  }

  Step _buildStep3() {
    return Step(
      title: const Text('Identity'),
      isActive: _currentStep >= 2,
      content: Column(
        children: [
          DropdownButtonFormField<String>(
            value: _idType,
            items: ['Aadhaar', 'PAN', 'Driving License', 'Passport'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() => _idType = v!),
            decoration: const InputDecoration(labelText: 'Government ID Type', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _idNumberController,
            decoration: const InputDecoration(labelText: 'ID Number', border: OutlineInputBorder()),
            validator: (v) => v!.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          _buildImagePicker('front', 'ID Front', _idFront),
          const SizedBox(height: 8),
          _buildImagePicker('back', 'ID Back', _idBack),
          const SizedBox(height: 8),
          // _buildImagePicker('selfie', 'Live Selfie', _selfie), // HIDDEN FOR DEV
        ],
      ),
    );
  }

  Step _buildStep4() {
    return Step(
      title: const Text('Payment'),
      isActive: _currentStep >= 3,
      content: Column(
        children: [
           DropdownButtonFormField<String>(
             value: _paymentMethod,
             items: ['UPI', 'Card', 'Net Banking'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
             onChanged: (v) => setState(() => _paymentMethod = v!),
             decoration: const InputDecoration(labelText: 'Preferred Payment Method', border: OutlineInputBorder()),
           ),
           const SizedBox(height: 12),
           TextFormField(
             controller: _billingNameController,
             decoration: const InputDecoration(labelText: 'Billing Name', border: OutlineInputBorder()),
           ),
           const SizedBox(height: 12),
           TextFormField(
             controller: _gstController,
             decoration: const InputDecoration(labelText: 'GST Number (Optional)', border: OutlineInputBorder()),
           ),
           const SizedBox(height: 12),
           TextFormField(
             controller: _invoiceAddressController,
             decoration: const InputDecoration(labelText: 'Invoice Address (Optional)', border: OutlineInputBorder()),
             maxLines: 2,
           ),
        ],
      ),
    );
  }

  Step _buildStep5() {
     return Step(
       title: const Text('Terms'),
       isActive: _currentStep >= 4,
       content: Column(
         children: [
            CheckboxListTile(
              title: const Text('I agree to the Platform Terms & Conditions'),
              subtitle: const Text('I confirm responsibility for timely payments and consent to escrow-based payments.'),
              value: _agreedToTerms,
              onChanged: (v) => setState(() => _agreedToTerms = v!),
            ),
            const SizedBox(height: 12),
            if(!_agreedToTerms)
              const Text('You must agree to continue', style: TextStyle(color: Colors.red)),
         ],
       ),
     );
  }

  Widget _buildImagePicker(String type, String label, File? file) {
    return GestureDetector(
      onTap: () => _pickImage(type),
      child: Container(
         height: 80,
         width: double.infinity,
         margin: const EdgeInsets.only(bottom: 8),
         decoration: BoxDecoration(
           color: Colors.grey[100],
           border: Border.all(color: Colors.grey.shade300),
           borderRadius: BorderRadius.circular(8),
         ),
         child: file != null
           ? Row(children: [
               ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(file, width: 80, height: 80, fit: BoxFit.cover)),
               const SizedBox(width: 12),
               Text('Selected: ${file.path.split('/').last}', style: const TextStyle(fontSize: 12)),
             ])
           : Center(
               child: Row(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   Icon(type == 'selfie' ? Icons.camera : Icons.upload_file, color: Colors.grey),
                   const SizedBox(width: 8),
                   Text(label, style: const TextStyle(color: Colors.grey)),
                 ],
               ),
             ),
      ),
    );
  }
}
