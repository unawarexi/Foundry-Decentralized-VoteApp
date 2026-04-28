import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'auth_widgets.dart';

/// Tab for Personal Information — Federal Level Requirements
class PersonalTab extends StatelessWidget {
  final bool isDark;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController dobController;
  final TextEditingController occupationController;
  final TextEditingController addressController;
  final TextEditingController passwordController;
  final TextEditingController confirmController;
  final bool obscurePassword;
  final bool obscureConfirm;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirm;
  final String? selectedMaritalStatus;
  final String? selectedGender;
  final String? selectedFamilyRole;
  final String? selectedCountry;
  final String? selectedState;
  final String? selectedLGA;
  final Function(String?) onMaritalStatusChanged;
  final Function(String?) onGenderChanged;
  final Function(String?) onFamilyRoleChanged;
  final Function(String?) onCountryChanged;
  final Function(String?) onStateChanged;
  final Function(String?) onLGAChanged;

  const PersonalTab({
    super.key,
    required this.isDark,
    required this.nameController,
    required this.emailController,
    required this.dobController,
    required this.occupationController,
    required this.addressController,
    required this.passwordController,
    required this.confirmController,
    required this.obscurePassword,
    required this.obscureConfirm,
    required this.onTogglePassword,
    required this.onToggleConfirm,
    this.selectedMaritalStatus,
    this.selectedGender,
    this.selectedFamilyRole,
    this.selectedCountry,
    this.selectedState,
    this.selectedLGA,
    required this.onMaritalStatusChanged,
    required this.onGenderChanged,
    required this.onFamilyRoleChanged,
    required this.onCountryChanged,
    required this.onStateChanged,
    required this.onLGAChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        VSTextField(
          controller: nameController,
          focusNode: FocusNode(), // Simplified for now
          label: 'Full Legal Names',
          hint: 'Surname First Name Middle Name',
          isFocused: false,
          prefixIcon: const Icon(Icons.person_outline, size: 18),
        ),
        const SizedBox(height: 18),
        VSTextField(
          controller: emailController,
          focusNode: FocusNode(),
          label: 'Email Address',
          hint: 'official@citizen.gov',
          isFocused: false,
          prefixIcon: const Icon(Icons.alternate_email, size: 18),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: VSTextField(
                controller: dobController,
                focusNode: FocusNode(),
                label: 'Date of Birth',
                hint: 'DD/MM/YYYY',
                isFocused: false,
                prefixIcon: const Icon(Icons.calendar_today_outlined, size: 16),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: VSDropdown<String>(
                label: 'Gender',
                hint: 'Select',
                value: selectedGender,
                items: ['Male', 'Female', 'Other'],
                onChanged: onGenderChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: VSDropdown<String>(
                label: 'Marital Status',
                hint: 'Select',
                value: selectedMaritalStatus,
                items: ['Single', 'Married', 'Divorced', 'Widowed'],
                onChanged: onMaritalStatusChanged,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: VSDropdown<String>(
                label: 'Family Role',
                hint: 'Select',
                value: selectedFamilyRole,
                items: ['Head of Household', 'Spouse', 'Dependent', 'Child'],
                onChanged: onFamilyRoleChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: VSTextField(
                controller: occupationController,
                focusNode: FocusNode(),
                label: 'Occupation',
                hint: 'e.g. Civil Servant',
                isFocused: false,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: VSTextField(
                controller: TextEditingController(
                  text: '4',
                ), // Example family size
                focusNode: FocusNode(),
                label: 'Family Size',
                hint: 'e.g. 5',
                isFocused: false,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Align(
          alignment: Alignment.centerLeft,
          child: AuthAccentTag(label: 'RESIDENTIAL DATA'),
        ),
        const SizedBox(height: 18),
        VSDropdown<String>(
          label: 'Country of Origin',
          hint: 'Select Country',
          value: selectedCountry,
          items: [
            'Nigeria',
            'United States',
            'United Kingdom',
            'Canada',
          ],
          onChanged: onCountryChanged,
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: VSDropdown<String>(
                label: 'State of Origin',
                hint: 'Select State',
                value: selectedState,
                items: ['Lagos', 'New York', 'London', 'Ontario'],
                onChanged: onStateChanged,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: VSDropdown<String>(
                label: 'LGA / Municipality',
                hint: 'Select LGA',
                value: selectedLGA,
                items: ['Ikeja', 'Brooklyn', 'Westminster', 'Toronto'],
                onChanged: onLGAChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        VSTextField(
          controller: addressController,
          focusNode: FocusNode(),
          label: 'Permanent Address',
          hint: 'House No, Street Name, City/Town',
          isFocused: false,
          prefixIcon: const Icon(Icons.location_on_outlined, size: 18),
        ),
        const SizedBox(height: 24),
        const Align(
          alignment: Alignment.centerLeft,
          child: AuthAccentTag(label: 'SECURITY CREDENTIALS'),
        ),
        const SizedBox(height: 18),
        VSTextField(
          controller: passwordController,
          focusNode: FocusNode(),
          label: 'Create Password',
          hint: 'Min. 8 chars with symbols',
          isFocused: false,
          obscureText: obscurePassword,
          prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18),
          suffixIcon: GestureDetector(
            onTap: onTogglePassword,
            child: Icon(
              obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 18,
            ),
          ),
        ),
        const SizedBox(height: 18),
        VSTextField(
          controller: confirmController,
          focusNode: FocusNode(),
          label: 'Confirm Password',
          hint: 'Repeat your password',
          isFocused: false,
          obscureText: obscureConfirm,
          prefixIcon: const Icon(Icons.shield_outlined, size: 18),
          suffixIcon: GestureDetector(
            onTap: onToggleConfirm,
            child: Icon(
              obscureConfirm
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }
}
