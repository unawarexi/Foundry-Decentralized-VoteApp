import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CandidatePartyIdentity extends StatefulWidget {
  final VoidCallback? onNext;
  final Map<String, dynamic> formData;

  const CandidatePartyIdentity({
    super.key,
    this.onNext,
    required this.formData,
  });

  @override
  State<CandidatePartyIdentity> createState() => _CandidatePartyIdentityState();
}

class _CandidatePartyIdentityState extends State<CandidatePartyIdentity>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;

  // Controllers
  final _fullNameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _partyNameController = TextEditingController();
  final _partyDescriptionController = TextEditingController();
  final _partyMottoController = TextEditingController();
  final _partyWebsiteController = TextEditingController();
  final _nationalIdController = TextEditingController();

  File? _profileImage;
  File? _partyLogo;
  File? _profileBanner;
  String? _selectedGender;
  String? _selectedEthnicity;
  String? _selectedReligion;
  DateTime? _selectedDate;

  final List<String> _genderOptions = [
    'Male',
    'Female',
    'Other',
    'Prefer not to say',
  ];
  final List<String> _ethnicityOptions = [
    'Yoruba',
    'Igbo',
    'Hausa',
    'Fulani',
    'Ijaw',
    'Kanuri',
    'Ibibio',
    'Tiv',
    'Other',
  ];
  final List<String> _religionOptions = [
    'Christianity',
    'Islam',
    'Traditional',
    'Other',
    'Prefer not to say',
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
    _fullNameController.text = widget.formData['fullName'] ?? '';
    _displayNameController.text = widget.formData['displayName'] ?? '';
    _partyNameController.text = widget.formData['partyName'] ?? '';
    _partyDescriptionController.text =
        widget.formData['partyDescription'] ?? '';
    _partyMottoController.text = widget.formData['partyMotto'] ?? '';
    _partyWebsiteController.text = widget.formData['partyWebsite'] ?? '';
    _nationalIdController.text = widget.formData['nationalId'] ?? '';
    _selectedGender = widget.formData['gender'];
    _selectedEthnicity = widget.formData['ethnicity'];
    _selectedReligion = widget.formData['religion'];
    _selectedDate = widget.formData['dateOfBirth'];
  }

  void _saveData() {
    widget.formData['fullName'] = _fullNameController.text;
    widget.formData['displayName'] = _displayNameController.text;
    widget.formData['partyName'] = _partyNameController.text;
    widget.formData['partyDescription'] = _partyDescriptionController.text;
    widget.formData['partyMotto'] = _partyMottoController.text;
    widget.formData['partyWebsite'] = _partyWebsiteController.text;
    widget.formData['nationalId'] = _nationalIdController.text;
    widget.formData['gender'] = _selectedGender;
    widget.formData['ethnicity'] = _selectedEthnicity;
    widget.formData['religion'] = _selectedReligion;
    widget.formData['dateOfBirth'] = _selectedDate;
    widget.formData['profileImage'] = _profileImage;
    widget.formData['partyLogo'] = _partyLogo;
    widget.formData['profileBanner'] = _profileBanner;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fullNameController.dispose();
    _displayNameController.dispose();
    _partyNameController.dispose();
    _partyDescriptionController.dispose();
    _partyMottoController.dispose();
    _partyWebsiteController.dispose();
    _nationalIdController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(String type) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        switch (type) {
          case 'profile':
            _profileImage = File(pickedFile.path);
            break;
          case 'logo':
            _partyLogo = File(pickedFile.path);
            break;
          case 'banner':
            _profileBanner = File(pickedFile.path);
            break;
        }
      });
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(1990),
      firstDate: DateTime(1950),
      lastDate: DateTime.now().subtract(
        const Duration(days: 6570),
      ), // 18 years ago
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: const Color(0xFF6C5CE7)),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
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
    if (value == null || value.trim().isEmpty) return null;
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  void _handleNext() {
    if (_formKey.currentState!.validate()) {
      if (_selectedGender == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please select gender')));
        return;
      }
      if (_selectedDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select date of birth')),
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
                      'Candidate & Party Identity',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF2D3436),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Basic identity, party affiliation, and visual representation',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Profile Photo Upload
                    _buildImageUploadSection(
                      'Profile Photo *',
                      _profileImage,
                      () => _pickImage('profile'),
                      isCircular: true,
                    ),
                    const SizedBox(height: 24),

                    // Candidate Information
                    _buildTextField(
                      controller: _fullNameController,
                      label: 'Full Legal Name *',
                      validator: (value) =>
                          _validateRequired(value, 'Full name'),
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _displayNameController,
                      label: 'Display Name / Alias',
                      icon: Icons.badge_outlined,
                    ),
                    const SizedBox(height: 16),

                    // Gender Dropdown
                    _buildDropdownField(
                      label: 'Gender *',
                      value: _selectedGender,
                      items: _genderOptions,
                      onChanged: (value) =>
                          setState(() => _selectedGender = value),
                      icon: Icons.wc_outlined,
                    ),
                    const SizedBox(height: 16),

                    // Date of Birth
                    _buildDateField(),
                    const SizedBox(height: 16),

                    // Ethnicity and Religion (Optional)
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdownField(
                            label: 'Ethnicity',
                            value: _selectedEthnicity,
                            items: _ethnicityOptions,
                            onChanged: (value) =>
                                setState(() => _selectedEthnicity = value),
                            icon: Icons.public_outlined,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDropdownField(
                            label: 'Religion',
                            value: _selectedReligion,
                            items: _religionOptions,
                            onChanged: (value) =>
                                setState(() => _selectedReligion = value),
                            icon: Icons.church_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // National ID
                    _buildTextField(
                      controller: _nationalIdController,
                      label: 'National ID / Voter ID Number *',
                      validator: (value) =>
                          _validateRequired(value, 'National ID'),
                      icon: Icons.credit_card_outlined,
                    ),
                    const SizedBox(height: 32),

                    // Party Information Section
                    Text(
                      'Party Information',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF6C5CE7),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _partyNameController,
                      label: 'Political Party Name *',
                      validator: (value) =>
                          _validateRequired(value, 'Party name'),
                      icon: Icons.flag_outlined,
                    ),
                    const SizedBox(height: 16),

                    // Party Logo Upload
                    _buildImageUploadSection(
                      'Party Logo *',
                      _partyLogo,
                      () => _pickImage('logo'),
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _partyDescriptionController,
                      label: 'Party Description *',
                      validator: (value) =>
                          _validateRequired(value, 'Party description'),
                      icon: Icons.description_outlined,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _partyMottoController,
                      label: 'Party Motto or Slogan',
                      icon: Icons.format_quote_outlined,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _partyWebsiteController,
                      label: 'Party Website / Link',
                      validator: _validateEmail,
                      icon: Icons.link_outlined,
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 16),

                    // Profile Banner Upload
                    _buildImageUploadSection(
                      'Profile Banner',
                      _profileBanner,
                      () => _pickImage('banner'),
                      isRectangular: true,
                    ),
                    const SizedBox(height: 32),

                    // Next Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _handleNext,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C5CE7),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
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
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
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
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    IconData? icon,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DropdownButtonFormField<String>(
      value: value,
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

  Widget _buildDateField() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: _selectDate,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Date of Birth *',
          prefixIcon: const Icon(
            Icons.calendar_today_outlined,
            color: Color(0xFF6C5CE7),
          ),
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
        child: Text(
          _selectedDate != null
              ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
              : 'Select date of birth',
          style: TextStyle(
            color: _selectedDate != null
                ? (isDark ? Colors.white : Colors.black87)
                : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildImageUploadSection(
    String title,
    File? image,
    VoidCallback onTap, {
    bool isCircular = false,
    bool isRectangular = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(isCircular ? 60 : 12),
          child: Container(
            width: isRectangular ? double.infinity : (isCircular ? 120 : 200),
            height: isRectangular ? 100 : (isCircular ? 120 : 150),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[100],
              borderRadius: BorderRadius.circular(isCircular ? 60 : 12),
              border: Border.all(
                color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
                style: BorderStyle.solid,
                width: 2,
              ),
            ),
            child: image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(isCircular ? 60 : 12),
                    child: Image.file(image, fit: BoxFit.cover),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo_outlined,
                        size: 32,
                        color: const Color(0xFF6C5CE7),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Upload ${title.replaceAll(' *', '')}',
                        style: TextStyle(
                          color: const Color(0xFF6C5CE7),
                          fontWeight: FontWeight.w500,
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
