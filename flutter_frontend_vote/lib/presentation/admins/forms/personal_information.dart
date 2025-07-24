import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class PersonalInformation extends StatefulWidget {
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  final Map<String, dynamic> formData;

  const PersonalInformation({
    super.key,
    this.onNext,
    this.onPrevious,
    required this.formData,
  });

  @override
  State<PersonalInformation> createState() => _PersonalInformationState();
}

class _PersonalInformationState extends State<PersonalInformation>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;

  // Controllers
  final _nationalityController = TextEditingController();
  final _stateOriginController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _twitterController = TextEditingController();
  final _websiteController = TextEditingController();
  final _heightController = TextEditingController();
  final _occupationController = TextEditingController();
  final _languagesController = TextEditingController();

  String? _selectedMaritalStatus;
  String? _selectedReligion;
  File? _governmentId;
  bool _isPhoneVerified = false;
  bool _isEmailVerified = false;

  final List<String> _maritalStatusOptions = [
    'Single',
    'Married',
    'Divorced',
    'Widowed',
    'Separated',
  ];

  final List<String> _religionOptions = [
    'Christianity',
    'Islam',
    'Traditional',
    'Other',
    'Prefer not to say',
  ];

  final List<String> _nigerianStates = [
    'Abia',
    'Adamawa',
    'Akwa Ibom',
    'Anambra',
    'Bauchi',
    'Bayelsa',
    'Benue',
    'Borno',
    'Cross River',
    'Delta',
    'Ebonyi',
    'Edo',
    'Ekiti',
    'Enugu',
    'Federal Capital Territory',
    'Gombe',
    'Imo',
    'Jigawa',
    'Kaduna',
    'Kano',
    'Katsina',
    'Kebbi',
    'Kogi',
    'Kwara',
    'Lagos',
    'Nasarawa',
    'Niger',
    'Ogun',
    'Ondo',
    'Osun',
    'Oyo',
    'Plateau',
    'Rivers',
    'Sokoto',
    'Taraba',
    'Yobe',
    'Zamfara',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.5, 0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
    _loadExistingData();
  }

  void _loadExistingData() {
    _nationalityController.text = widget.formData['nationality'] ?? 'Nigerian';
    _stateOriginController.text = widget.formData['stateOrigin'] ?? '';
    _addressController.text = widget.formData['address'] ?? '';
    _phoneController.text = widget.formData['phone'] ?? '';
    _emailController.text = widget.formData['email'] ?? '';
    _linkedinController.text = widget.formData['linkedin'] ?? '';
    _twitterController.text = widget.formData['twitter'] ?? '';
    _websiteController.text = widget.formData['website'] ?? '';
    _heightController.text = widget.formData['height'] ?? '';
    _occupationController.text = widget.formData['occupation'] ?? '';
    _languagesController.text = widget.formData['languages'] ?? '';
    _selectedMaritalStatus = widget.formData['maritalStatus'];
    _selectedReligion = widget.formData['religion'];
    _governmentId = widget.formData['governmentId'];
    _isPhoneVerified = widget.formData['phoneVerified'] ?? false;
    _isEmailVerified = widget.formData['emailVerified'] ?? false;
  }

  void _saveData() {
    widget.formData['nationality'] = _nationalityController.text;
    widget.formData['stateOrigin'] = _stateOriginController.text;
    widget.formData['address'] = _addressController.text;
    widget.formData['phone'] = _phoneController.text;
    widget.formData['email'] = _emailController.text;
    widget.formData['linkedin'] = _linkedinController.text;
    widget.formData['twitter'] = _twitterController.text;
    widget.formData['website'] = _websiteController.text;
    widget.formData['height'] = _heightController.text;
    widget.formData['occupation'] = _occupationController.text;
    widget.formData['languages'] = _languagesController.text;
    widget.formData['maritalStatus'] = _selectedMaritalStatus;
    widget.formData['religion'] = _selectedReligion;
    widget.formData['governmentId'] = _governmentId;
    widget.formData['phoneVerified'] = _isPhoneVerified;
    widget.formData['emailVerified'] = _isEmailVerified;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nationalityController.dispose();
    _stateOriginController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _linkedinController.dispose();
    _twitterController.dispose();
    _websiteController.dispose();
    _heightController.dispose();
    _occupationController.dispose();
    _languagesController.dispose();
    super.dispose();
  }

  Future<void> _pickGovernmentId() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _governmentId = File(pickedFile.path);
      });
    }
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    if (!RegExp(
      r'^(\+234|0)[7-9][0-1]\d{8}$',
    ).hasMatch(value.replaceAll(' ', ''))) {
      return 'Enter a valid Nigerian phone number';
    }
    return null;
  }

  String? _validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (!RegExp(
      r'^https?:\/\/[\w\-]+(\.[\w\-]+)+([\w\-\.,@?^=%&amp;:/~\+#]*[\w\-\@?^=%&amp;/~\+#])?$',
    ).hasMatch(value)) {
      return 'Enter a valid URL';
    }
    return null;
  }

  void _verifyPhone() {
    // Simulate phone verification
    setState(() {
      _isPhoneVerified = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Phone number verified successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _verifyEmail() {
    // Simulate email verification
    setState(() {
      _isEmailVerified = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Email verified successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _handleNext() {
    if (_formKey.currentState!.validate()) {
      if (_selectedMaritalStatus == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select marital status')),
        );
        return;
      }
      if (_governmentId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload government ID')),
        );
        return;
      }
      if (!_isPhoneVerified || !_isEmailVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please verify phone and email')),
        );
        return;
      }
      _saveData();
      widget.onNext?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeInAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Text(
                      'Personal Information & Contact',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF2D3436),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Personal and official contact info for validation',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Basic Information
                    _buildTextField(
                      controller: _nationalityController,
                      label: 'Nationality *',
                      validator: (value) =>
                          _validateRequired(value, 'Nationality'),
                      icon: Icons.flag_outlined,
                    ),
                    const SizedBox(height: 16),

                    _buildDropdownField(
                      label: 'State/Region of Origin *',
                      value: _stateOriginController.text.isEmpty
                          ? null
                          : _stateOriginController.text,
                      items: _nigerianStates,
                      onChanged: (value) => setState(
                        () => _stateOriginController.text = value ?? '',
                      ),
                      icon: Icons.location_on_outlined,
                      isRequired: true,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _addressController,
                      label: 'Residential Address *',
                      validator: (value) => _validateRequired(value, 'Address'),
                      icon: Icons.home_outlined,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),

                    // Contact Information
                    Text(
                      'Contact Information',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF6C5CE7),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildVerificationField(
                      controller: _phoneController,
                      label: 'Phone Number *',
                      validator: _validatePhone,
                      icon: Icons.phone_outlined,
                      isVerified: _isPhoneVerified,
                      onVerify: _verifyPhone,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(11),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _buildVerificationField(
                      controller: _emailController,
                      label: 'Email Address *',
                      validator: _validateEmail,
                      icon: Icons.email_outlined,
                      isVerified: _isEmailVerified,
                      onVerify: _verifyEmail,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 24),

                    // Social Media (Optional)
                    Text(
                      'Social Media & Web Presence',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.grey[300] : Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _linkedinController,
                      label: 'LinkedIn Profile',
                      validator: _validateUrl,
                      icon: Icons.work_outline,
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _twitterController,
                      label: 'Twitter/X Handle',
                      icon: Icons.alternate_email,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _websiteController,
                      label: 'Official Website / Campaign Page',
                      validator: _validateUrl,
                      icon: Icons.language_outlined,
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 24),

                    // Additional Information
                    Text(
                      'Additional Information',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.grey[300] : Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _heightController,
                            label: 'Height (cm)',
                            icon: Icons.straighten_outlined,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDropdownField(
                            label: 'Marital Status *',
                            value: _selectedMaritalStatus,
                            items: _maritalStatusOptions,
                            onChanged: (value) =>
                                setState(() => _selectedMaritalStatus = value),
                            icon: Icons.people_outline,
                            isRequired: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _occupationController,
                      label: 'Occupation / Profession *',
                      validator: (value) =>
                          _validateRequired(value, 'Occupation'),
                      icon: Icons.business_center_outlined,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _languagesController,
                      label: 'Languages Spoken *',
                      validator: (value) =>
                          _validateRequired(value, 'Languages'),
                      icon: Icons.translate_outlined,
                      hintText: 'e.g., English, Yoruba, Hausa',
                    ),
                    const SizedBox(height: 16),

                    _buildDropdownField(
                      label: 'Religion',
                      value: _selectedReligion,
                      items: _religionOptions,
                      onChanged: (value) =>
                          setState(() => _selectedReligion = value),
                      icon: Icons.church_outlined,
                    ),
                    const SizedBox(height: 24),

                    // Government ID Upload
                    _buildDocumentUploadSection(),
                    const SizedBox(height: 32),

                    // Navigation Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: widget.onPrevious,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF6C5CE7)),
                              foregroundColor: const Color(0xFF6C5CE7),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              'Previous',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _handleNext,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6C5CE7),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              'Next Step',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    IconData? icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
    String? hintText,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: icon != null
            ? Icon(icon, color: const Color(0xFF6C5CE7))
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6C5CE7), width: 2),
        ),
        filled: true,
        fillColor: isDark ? Colors.grey[900] : Colors.grey[50],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    IconData? icon,
    bool isRequired = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DropdownButtonFormField<String>(
      value: value,
      validator: isRequired
          ? (value) => value == null ? '$label is required' : null
          : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null
            ? Icon(icon, color: const Color(0xFF6C5CE7))
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6C5CE7), width: 2),
        ),
        filled: true,
        fillColor: isDark ? Colors.grey[900] : Colors.grey[50],
      ),
      items: items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildVerificationField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    required IconData icon,
    required bool isVerified,
    required VoidCallback onVerify,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: TextFormField(
            controller: controller,
            validator: validator,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: Icon(icon, color: const Color(0xFF6C5CE7)),
              suffixIcon: isVerified
                  ? const Icon(Icons.verified, color: Colors.green)
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF6C5CE7),
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: isDark ? Colors.grey[900] : Colors.grey[50],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: isVerified ? null : onVerify,
            style: ElevatedButton.styleFrom(
              backgroundColor: isVerified
                  ? Colors.green
                  : const Color(0xFF6C5CE7),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(
              isVerified ? 'Verified' : 'Verify',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentUploadSection() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Government-issued ID *',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickGovernmentId,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
                style: BorderStyle.solid,
                width: 2,
              ),
            ),
            child: _governmentId != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(_governmentId!, fit: BoxFit.cover),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.upload_file_outlined,
                        size: 32,
                        color: const Color(0xFF6C5CE7),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Upload Government ID',
                        style: TextStyle(
                          color: const Color(0xFF6C5CE7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Driver\'s License, NIN, Passport, etc.',
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
