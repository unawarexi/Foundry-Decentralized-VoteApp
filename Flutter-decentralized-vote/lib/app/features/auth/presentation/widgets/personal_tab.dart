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
  final TextEditingController sloganController;
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
  final String? selectedReligion;
  final List<String> selectedLanguages;
  final Function(String?) onMaritalStatusChanged;
  final Function(String?) onGenderChanged;
  final Function(String?) onFamilyRoleChanged;
  final Function(String?) onCountryChanged;
  final Function(String?) onStateChanged;
  final Function(String?) onLGAChanged;
  final Function(String?) onReligionChanged;
  final Function(List<String>) onLanguagesChanged;
  // Profile picture (avatarUrl)
  final bool hasProfilePicture;
  final VoidCallback onUploadProfilePicture;
  // Organisation / company logo (logoUrl on User)
  final bool hasOrgLogo;
  final VoidCallback onUploadOrgLogo;

  const PersonalTab({
    super.key,
    required this.isDark,
    required this.nameController,
    required this.emailController,
    required this.dobController,
    required this.occupationController,
    required this.addressController,
    required this.sloganController,
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
    this.selectedReligion,
    this.selectedLanguages = const [],
    required this.onMaritalStatusChanged,
    required this.onGenderChanged,
    required this.onFamilyRoleChanged,
    required this.onCountryChanged,
    required this.onStateChanged,
    required this.onLGAChanged,
    required this.onReligionChanged,
    required this.onLanguagesChanged,
    this.hasProfilePicture = false,
    required this.onUploadProfilePicture,
    this.hasOrgLogo = false,
    required this.onUploadOrgLogo,
  });

  static const _languages = [
    'English', 'French', 'Arabic', 'Hausa', 'Yoruba', 'Igbo', 'Swahili',
    'Portuguese', 'Fulani', 'Amharic', 'Spanish', 'Mandarin', 'Hindi',
    'Pidgin English', 'Zulu', 'Shona',
  ];

  static const _religions = [
    'Christianity', 'Islam', 'Traditional / Indigenous', 'Hinduism',
    'Buddhism', 'Judaism', 'Atheism / No Religion', 'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Profile Picture + Org Logo ────────────────────────────────────
        const Align(
          alignment: Alignment.centerLeft,
          child: AuthAccentTag(label: 'PROFILE PHOTOS'),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            VSAvatarPicker(
              label: 'Profile Photo',
              hasImage: hasProfilePicture,
              onTap: onUploadProfilePicture,
              size: 90,
              isRound: true,
              placeholderIcon: Icons.person_outline_rounded,
            ),
            VSAvatarPicker(
              label: 'Org / Company Logo',
              hasImage: hasOrgLogo,
              onTap: onUploadOrgLogo,
              size: 90,
              isRound: false,
              placeholderIcon: Icons.business_outlined,
            ),
          ],
        ),
        const SizedBox(height: 22),

        // ── Personal Identification ───────────────────────────────────────
        const Align(
          alignment: Alignment.centerLeft,
          child: AuthAccentTag(label: 'PERSONAL IDENTITY'),
        ),
        const SizedBox(height: 14),
        VSTextField(
          controller: nameController,
          focusNode: FocusNode(),
          label: 'Full Legal Names',
          hint: 'Surname First Name Middle Name',
          isFocused: false,
          prefixIcon: const Icon(Icons.person_outline, size: 18),
        ),
        const SizedBox(height: 14),
        VSTextField(
          controller: emailController,
          focusNode: FocusNode(),
          label: 'Email Address',
          hint: 'official@citizen.gov',
          isFocused: false,
          prefixIcon: const Icon(Icons.alternate_email, size: 18),
        ),
        const SizedBox(height: 14),
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
                items: const ['Male', 'Female', 'Other'],
                onChanged: onGenderChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: VSDropdown<String>(
                label: 'Marital Status',
                hint: 'Select',
                value: selectedMaritalStatus,
                items: const ['Single', 'Married', 'Divorced', 'Widowed'],
                onChanged: onMaritalStatusChanged,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: VSDropdown<String>(
                label: 'Family Role',
                hint: 'Select',
                value: selectedFamilyRole,
                items: const ['Head of Household', 'Spouse', 'Dependent', 'Child'],
                onChanged: onFamilyRoleChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        VSTextField(
          controller: occupationController,
          focusNode: FocusNode(),
          label: 'Occupation',
          hint: 'e.g. Civil Servant',
          isFocused: false,
        ),
        const SizedBox(height: 14),
        VSTextField(
          controller: sloganController,
          focusNode: FocusNode(),
          label: 'Personal Motto / Slogan',
          hint: 'e.g. "By the people, for the people"',
          isFocused: false,
          prefixIcon: const Icon(Icons.format_quote_rounded, size: 18),
        ),
        const SizedBox(height: 22),

        // ── Cultural Information ───────────────────────────────────────────
        const Align(
          alignment: Alignment.centerLeft,
          child: AuthAccentTag(label: 'CULTURAL PROFILE'),
        ),
        const SizedBox(height: 14),
        VSDropdown<String>(
          label: 'Religion',
          hint: 'Select Religion (optional)',
          value: selectedReligion,
          items: _religions,
          onChanged: onReligionChanged,
        ),
        const SizedBox(height: 14),
        VSMultiChipSelector(
          label: 'Languages Spoken',
          options: _languages,
          selected: selectedLanguages,
          onChanged: onLanguagesChanged,
        ),
        const SizedBox(height: 22),

        // ── Residential Data ──────────────────────────────────────────────
        const Align(
          alignment: Alignment.centerLeft,
          child: AuthAccentTag(label: 'RESIDENTIAL DATA'),
        ),
        const SizedBox(height: 14),
        VSDropdown<String>(
          label: 'Country of Origin',
          hint: 'Select Country',
          value: selectedCountry,
          items: const ['Nigeria', 'United States', 'United Kingdom', 'Canada', 'Ghana', 'Kenya', 'South Africa'],
          onChanged: onCountryChanged,
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: VSDropdown<String>(
                label: 'State of Origin',
                hint: 'Select State',
                value: selectedState,
                items: const ['Lagos', 'Abuja', 'Kano', 'Rivers', 'New York', 'London', 'Ontario'],
                onChanged: onStateChanged,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: VSDropdown<String>(
                label: 'LGA / Municipality',
                hint: 'Select LGA',
                value: selectedLGA,
                items: const ['Ikeja', 'Eti-Osa', 'Surulere', 'Brooklyn', 'Westminster', 'Toronto'],
                onChanged: onLGAChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        VSTextField(
          controller: addressController,
          focusNode: FocusNode(),
          label: 'Permanent Address',
          hint: 'House No, Street Name, City/Town',
          isFocused: false,
          prefixIcon: const Icon(Icons.location_on_outlined, size: 18),
        ),
      ],
    );
  }
}

