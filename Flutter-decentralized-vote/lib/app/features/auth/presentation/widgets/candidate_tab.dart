import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/core/constants/colors.dart';
import 'auth_widgets.dart';

/// Tab for Candidate specific information
class CandidateTab extends StatelessWidget {
  final bool isDark;
  final bool hasManifesto;
  final bool hasVideoIntro;
  final bool hasQualifications;
  final bool hasPictures;
  
  // New Controllers
  final TextEditingController roleNameController;
  final TextEditingController rolePurposeController;
  final TextEditingController partyNameController;
  final TextEditingController achievementsController;
  final TextEditingController careerJourneyController;
  final TextEditingController biographyController;
  final String? selectedRole;
  final Function(String?) onRoleChanged;

  final VoidCallback onUploadManifesto;
  final VoidCallback onUploadVideo;
  final VoidCallback onUploadQualifications;
  final VoidCallback onUploadPictures;

  const CandidateTab({
    super.key,
    required this.isDark,
    this.hasManifesto = false,
    this.hasVideoIntro = false,
    this.hasQualifications = false,
    this.hasPictures = false,
    required this.roleNameController,
    required this.rolePurposeController,
    required this.partyNameController,
    required this.achievementsController,
    required this.careerJourneyController,
    required this.biographyController,
    this.selectedRole,
    required this.onRoleChanged,
    required this.onUploadManifesto,
    required this.onUploadVideo,
    required this.onUploadQualifications,
    required this.onUploadPictures,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: AuthAccentTag(label: 'LEADERSHIP PROFILE'),
        ),
        const SizedBox(height: 18),

        VSDropdown<String>(
          label: 'Election Role Category',
          hint: 'Select target office',
          value: selectedRole,
          items: [
            'Presidential / CEO',
            'Gubernatorial / Executive',
            'Legislative / Board',
            'Judicial / Oversight',
            'Local Government / Municipal',
          ],
          onChanged: onRoleChanged,
        ),
        const SizedBox(height: 14),

        VSTextField(
          controller: roleNameController,
          focusNode: FocusNode(),
          label: 'Specific Role Name',
          hint: 'e.g. Executive Governor of Lagos State',
        ),
        const SizedBox(height: 14),

        VSTextField(
          controller: partyNameController,
          focusNode: FocusNode(),
          label: 'Political Party / Organization Name',
          hint: 'Full legal name of the entity',
        ),
        const SizedBox(height: 14),

        VSTextField(
          controller: rolePurposeController,
          focusNode: FocusNode(),
          label: 'Mission Statement & Purpose',
          hint: 'Briefly describe your main objective',
          maxLines: 3,
        ),
        const SizedBox(height: 14),

        VSTextField(
          controller: biographyController,
          focusNode: FocusNode(),
          label: 'Detailed Biography',
          hint: 'Tell the voters about your background',
          maxLines: 5,
        ),
        const SizedBox(height: 14),

        VSTextField(
          controller: achievementsController,
          focusNode: FocusNode(),
          label: 'Key Achievements',
          hint: 'List your past successes in this or related fields',
          maxLines: 4,
        ),
        const SizedBox(height: 14),

        VSTextField(
          controller: careerJourneyController,
          focusNode: FocusNode(),
          label: 'Career Journey',
          hint: 'Summary of your professional experience',
          maxLines: 4,
        ),
        const SizedBox(height: 24),

        const Align(
          alignment: Alignment.centerLeft,
          child: AuthAccentTag(label: 'CANDIDATE DISCLOSURES'),
        ),
        const SizedBox(height: 18),
        
        VSFileUpload(
          label: 'Campaign Manifesto',
          hint: 'PDF Document (Max 10MB)',
          icon: Icons.description_outlined,
          hasFile: hasManifesto,
          onTap: onUploadManifesto,
        ),
        const SizedBox(height: 14),
        
        VSFileUpload(
          label: 'Video Introduction (15-30 Mins)',
          hint: 'MP4 / MOV High Quality',
          icon: Icons.video_library_outlined,
          hasFile: hasVideoIntro,
          onTap: onUploadVideo,
        ),
        const SizedBox(height: 14),
        
        VSFileUpload(
          label: 'Academic & Professional Qualifications',
          hint: 'Merged PDF Document',
          icon: Icons.school_outlined,
          hasFile: hasQualifications,
          onTap: onUploadQualifications,
        ),
        const SizedBox(height: 14),
        
        VSFileUpload(
          label: 'Official Campaign Portraits',
          hint: 'ZIP Archive of JPG/PNG',
          icon: Icons.photo_library_outlined,
          hasFile: hasPictures,
          onTap: onUploadPictures,
        ),
        const SizedBox(height: 32),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: TColors.secondary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: TColors.secondary.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.gavel_rounded, color: TColors.secondary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'By uploading these documents, you certify their authenticity under federal election laws.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: isDark ? TColors.textDarkSecondary : TColors.textLightSecondary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
