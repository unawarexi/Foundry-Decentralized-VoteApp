import 'package:flutter/material.dart';

class CandidateAdditionConfirmation extends StatefulWidget {
  const CandidateAdditionConfirmation({super.key});

  @override
  State<CandidateAdditionConfirmation> createState() => _CandidateAdditionConfirmationState();
}

class _CandidateAdditionConfirmationState extends State<CandidateAdditionConfirmation>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _confirmAuthenticity = false;
  bool _acceptTerms = false;
  bool _acceptElectoralRules = false;
  String? _digitalSignature;

  // Mock candidate data for preview
  final Map<String, dynamic> candidateData = {
    'name': 'John Doe',
    'party': 'Progressive Alliance',
    'position': 'Governor',
    'email': 'john.doe@example.com',
    'phone': '+234 800 123 4567',
    'vision': 'Building a sustainable future for all citizens through innovation and inclusive governance.',
  };

  // List of added candidates
  List<Map<String, dynamic>> addedCandidates = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF0F0F23)
          : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Confirmation & Submission'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF64FFDA)
              : const Color(0xFF1976D2),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCandidatePreview(),
                const SizedBox(height: 32),
                
                _buildAddedCandidatesList(),
                const SizedBox(height: 32),
                
                _buildConfirmationSection(),
                const SizedBox(height: 32),
                
                _buildDigitalSignature(),
                const SizedBox(height: 32),
                
                _buildTermsAndConditions(),
                const SizedBox(height: 32),
                
                _buildActionButtons(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCandidatePreview() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: Theme.of(context).brightness == Brightness.dark
              ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
              : [Colors.white, const Color(0xFFF8F9FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF64FFDA).withOpacity(0.3)
              : const Color(0xFF1976D2).withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withOpacity(0.4)
                : Colors.grey.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: Theme.of(context).brightness == Brightness.dark
                        ? [const Color(0xFF64FFDA), const Color(0xFF1DE9B6)]
                        : [const Color(0xFF1976D2), const Color(0xFF42A5F5)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.preview, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Text(
                'Candidate Preview',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF64FFDA)
                      : const Color(0xFF1976D2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Candidate Card Preview
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF0F0F23)
                  : Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF0F3460)
                    : const Color(0xFFE1E8ED),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF64FFDA)
                          : const Color(0xFF1976D2),
                      child: Text(
                        candidateData['name']![0],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            candidateData['name']!,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            candidateData['party']!,
                            style: TextStyle(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? const Color(0xFF64FFDA)
                                  : const Color(0xFF1976D2),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            candidateData['position']!,
                            style: TextStyle(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white70
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                _buildPreviewItem(Icons.email, 'Email', candidateData['email']!),
                const SizedBox(height: 8),
                _buildPreviewItem(Icons.phone, 'Phone', candidateData['phone']!),
                const SizedBox(height: 16),
                Text(
                  'Vision Statement:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  candidateData['vision']!,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white70
                        : Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Edit Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _editCandidate,
              icon: const Icon(Icons.edit),
              label: const Text('Edit Details'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF64FFDA)
                      : const Color(0xFF1976D2),
                ),
                foregroundColor: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF64FFDA)
                    : const Color(0xFF1976D2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF64FFDA)
              : const Color(0xFF1976D2),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white70
                  : Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddedCandidatesList() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: Theme.of(context).brightness == Brightness.dark
              ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
              : [Colors.white, const Color(0xFFF8F9FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF0F3460)
              : const Color(0xFFE1E8ED),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: Theme.of(context).brightness == Brightness.dark
                        ? [const Color(0xFF64FFDA), const Color(0xFF1DE9B6)]
                        : [const Color(0xFF1976D2), const Color(0xFF42A5F5)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.people, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Text(
                'Added Candidates (${addedCandidates.length})',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF64FFDA)
                      : const Color(0xFF1976D2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          if (addedCandidates.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF0F0F23)
                    : Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF0F3460)
                      : const Color(0xFFE1E8ED),
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.person_add,
                    size: 48,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white54
                        : Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No candidates added yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white54
                          : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first candidate to continue',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white38
                          : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          else
            ...addedCandidates.map((candidate) => _buildCandidateListItem(candidate)),
        ],
      ),
    );
  }

  Widget _buildCandidateListItem(Map<String, dynamic> candidate) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF0F0F23)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF0F3460)
              : const Color(0xFFE1E8ED),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF64FFDA)
                : const Color(0xFF1976D2),
            child: Text(
              candidate['name']![0],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  candidate['name']!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  candidate['party']!,
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white70
                        : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _editAddedCandidate(candidate),
            icon: const Icon(Icons.edit, size: 20),
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF64FFDA)
                : const Color(0xFF1976D2),
          ),
          IconButton(
            onPressed: () => _removeCandidate(candidate),
            icon: const Icon(Icons.delete, size: 20),
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: Theme.of(context).brightness == Brightness.dark
              ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
              : [Colors.white, const Color(0xFFF8F9FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF0F3460)
              : const Color(0xFFE1E8ED),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: Theme.of(context).brightness == Brightness.dark
                        ? [const Color(0xFF64FFDA), const Color(0xFF1DE9B6)]
                        : [const Color(0xFF1976D2), const Color(0xFF42A5F5)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.verified, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Text(
                'Confirmation',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF64FFDA)
                      : const Color(0xFF1976D2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          CheckboxListTile(
            value: _confirmAuthenticity,
            onChanged: (value) {
              setState(() {
                _confirmAuthenticity = value ?? false;
              });
            },
            title: const Text('I confirm that all provided information is authentic and accurate'),
            subtitle: const Text('Any false information may result in disqualification'),
            activeColor: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF64FFDA)
                : const Color(0xFF1976D2),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildDigitalSignature() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: Theme.of(context).brightness == Brightness.dark
              ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
              : [Colors.white, const Color(0xFFF8F9FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF0F3460)
              : const Color(0xFFE1E8ED),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: Theme.of(context).brightness == Brightness.dark
                        ? [const Color(0xFF64FFDA), const Color(0xFF1DE9B6)]
                        : [const Color(0xFF1976D2), const Color(0xFF42A5F5)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.draw, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Text(
                'Digital Signature',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF64FFDA)
                      : const Color(0xFF1976D2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF0F0F23)
                  : Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF0F3460)
                    : const Color(0xFFE1E8ED),
                style: BorderStyle.solid,
              ),
            ),
            child: _digitalSignature != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 40,
                          color: Colors.green,
                        ),
                        const SizedBox(height: 8),
                        const Text('Digital signature captured'),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _retakeSignature,
                          child: const Text('Retake Signature'),
                        ),
                      ],
                    ),
                  )
                : InkWell(
                    onTap: _captureSignature,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.draw,
                            size: 40,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white54
                                : Colors.grey[600],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Tap to capture signature',
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white70
                                  : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Draw your signature on the signature pad',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white54
                                  : Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          
          // Alternative upload option
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _uploadSignature,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Upload Signature'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF64FFDA)
                          : const Color(0xFF1976D2),
                    ),
                    foregroundColor: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF64FFDA)
                        : const Color(0xFF1976D2),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTermsAndConditions() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: Theme.of(context).brightness == Brightness.dark
              ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
              : [Colors.white, const Color(0xFFF8F9FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF0F3460)
              : const Color(0xFFE1E8ED),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: Theme.of(context).brightness == Brightness.dark
                        ? [const Color(0xFF64FFDA), const Color(0xFF1DE9B6)]
                        : [const Color(0xFF1976D2), const Color(0xFF42A5F5)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.gavel, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Text(
                'Terms & Conditions',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF64FFDA)
                      : const Color(0xFF1976D2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          CheckboxListTile(
            value: _acceptTerms,
            onChanged: (value) {
              setState(() {
                _acceptTerms = value ?? false;
              });
            },
            title: Row(
              children: [
                const Expanded(
                  child: Text('I accept the Terms & Conditions'),
                ),
                TextButton(
                  onPressed: _showTermsModal,
                  child: const Text('Read'),
                ),
              ],
            ),
            subtitle: const Text('Please read and accept the terms and conditions'),
            activeColor: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF64FFDA)
                : const Color(0xFF1976D2),
            contentPadding: EdgeInsets.zero,
          ),
          
          CheckboxListTile(
            value: _acceptElectoralRules,
            onChanged: (value) {
              setState(() {
                _acceptElectoralRules = value ?? false;
              });
            },
            title: Row(
              children: [
                const Expanded(
                  child: Text('I accept the Electoral Rules & Guidelines'),
                ),
                TextButton(
                  onPressed: _showElectoralRulesModal,
                  child: const Text('Read'),
                ),
              ],
            ),
            subtitle: const Text('Agreement to abide by electoral commission guidelines'),
            activeColor: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF64FFDA)
                : const Color(0xFF1976D2),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    bool canSubmit = _confirmAuthenticity &&
        _acceptTerms &&
        _acceptElectoralRules &&
        _digitalSignature != null;

    return Column(
      children: [
        // Add Another Candidate Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _addAnotherCandidate,
            icon: const Icon(Icons.person_add),
            label: const Text('Add Another Candidate'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF64FFDA)
                    : const Color(0xFF1976D2),
              ),
              foregroundColor: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF64FFDA)
                  : const Color(0xFF1976D2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Submit All Candidates Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: canSubmit ? _submitAllCandidates : null,
            icon: const Icon(Icons.send),
            label: const Text('Submit All Candidates'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: canSubmit
                  ? (Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF64FFDA)
                      : const Color(0xFF1976D2))
                  : Colors.grey,
              foregroundColor: canSubmit ? Colors.white : Colors.white70,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: canSubmit ? 4 : 0,
            ),
          ),
        ),
        const SizedBox(height: 12),
        
        // Requirements check
        if (!canSubmit)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Requirements not met:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (!_confirmAuthenticity)
                  const Text('• Confirm information authenticity'),
                if (!_acceptTerms)
                  const Text('• Accept Terms & Conditions'),
                if (!_acceptElectoralRules)
                  const Text('• Accept Electoral Rules & Guidelines'),
                if (_digitalSignature == null)
                  const Text('• Provide digital signature'),
              ],
            ),
          ),
      ],
    );
  }

  // Method implementations
  void _editCandidate() {
    // Navigate back to candidate form for editing
    Navigator.pop(context);
  }

  void _editAddedCandidate(Map<String, dynamic> candidate) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Candidate'),
          content: Text('Edit ${candidate['name']}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Navigate to edit form with candidate data
                _navigateToEditForm(candidate);
              },
              child: const Text('Edit'),
            ),
          ],
        );
      },
    );
  }

  void _removeCandidate(Map<String, dynamic> candidate) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Candidate'),
          content: Text('Are you sure you want to remove ${candidate['name']}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  addedCandidates.remove(candidate);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${candidate['name']} removed successfully'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }

  void _captureSignature() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1A1A2E)
                  : Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Digital Signature Pad',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: const Center(
                    child: Text(
                      'Signature Canvas\n(Draw your signature here)',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _digitalSignature = 'signature_captured_${DateTime.now().millisecondsSinceEpoch}';
                          });
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Digital signature captured successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        child: const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _retakeSignature() {
    setState(() {
      _digitalSignature = null;
    });
    _captureSignature();
  }

  void _uploadSignature() {
    // Simulate file picker
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Upload Signature'),
          content: const Text('Select signature image file (PNG, JPG)'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _digitalSignature = 'signature_uploaded_${DateTime.now().millisecondsSinceEpoch}';
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Signature uploaded successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Upload'),
            ),
          ],
        );
      },
    );
  }

  void _showTermsModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(24),
            height: MediaQuery.of(context).size.height * 0.8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Terms & Conditions',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          '1. ACCEPTANCE OF TERMS',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'By submitting this candidate registration form, you agree to be bound by these terms and conditions.',
                        ),
                        SizedBox(height: 16),
                        Text(
                          '2. ELIGIBILITY REQUIREMENTS',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'All candidates must meet the constitutional and legal requirements for the office they seek.',
                        ),
                        SizedBox(height: 16),
                        Text(
                          '3. INFORMATION ACCURACY',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'All information provided must be true, accurate, and complete. False information may result in disqualification.',
                        ),
                        SizedBox(height: 16),
                        Text(
                          '4. COMPLIANCE WITH LAWS',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Candidates must comply with all applicable election laws and regulations.',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showElectoralRulesModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(24),
            height: MediaQuery.of(context).size.height * 0.8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Electoral Rules & Guidelines',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'CAMPAIGN CONDUCT',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '• Maintain fair and ethical campaign practices\n'
                          '• Respect opponent candidates and voters\n'
                          '• Follow campaign finance regulations\n'
                          '• Comply with media and advertising guidelines',
                        ),
                        SizedBox(height: 16),
                        Text(
                          'ELECTORAL COMMISSION AUTHORITY',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'The Electoral Commission has the authority to:\n'
                          '• Verify candidate eligibility\n'
                          '• Investigate complaints\n'
                          '• Impose sanctions for violations\n'
                          '• Disqualify candidates if necessary',
                        ),
                        SizedBox(height: 16),
                        Text(
                          'DISPUTE RESOLUTION',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'All electoral disputes will be resolved through the established legal framework and tribunal system.',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _addAnotherCandidate() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Another Candidate'),
          content: const Text('Do you want to save the current candidate and add another one?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Add current candidate to the list
                setState(() {
                  addedCandidates.add(Map<String, dynamic>.from(candidateData));
                });
                Navigator.pop(context);
                // Navigate back to step 1 with empty form
                _navigateToStep1();
              },
              child: const Text('Add & Continue'),
            ),
          ],
        );
      },
    );
  }

  void _submitAllCandidates() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Submit All Candidates'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('You are about to submit the following candidates:'),
              const SizedBox(height: 16),
              // Show current candidate
              Text('• ${candidateData['name']} (${candidateData['party']})'),
              // Show added candidates
              ...addedCandidates.map((candidate) => 
                Text('• ${candidate['name']} (${candidate['party']})')),
              const SizedBox(height: 16),
              const Text(
                'This action cannot be undone. Are you sure you want to proceed?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _performSubmission();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF64FFDA)
                    : const Color(0xFF1976D2),
              ),
              child: const Text('Submit All'),
            ),
          ],
        );
      },
    );
  }

  void _performSubmission() {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                const Text('Submitting candidates...'),
              ],
            ),
          ),
        );
      },
    );

    // Simulate API call
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pop(context); // Close loading dialog
      
      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Submission Successful!',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Your candidate registration has been submitted successfully. '
                    'You will receive a confirmation email shortly.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close success dialog
                        Navigator.popUntil(context, (route) => route.isFirst); // Go to home
                      },
                      child: const Text('Done'),
                    ),
                  ),
                ],
              ),
            ),
          );
     

    });
    });
  }

  void _navigateToEditForm(Map<String, dynamic> candidate) {
    // Navigate to candidate form with pre-filled data
    // This would typically pass the candidate data to the form
    Navigator.pushNamed(context, '/candidate-form', arguments: candidate);
  }

  void _navigateToStep1() {
    // Navigate back to step 1 (candidate basic info)
    Navigator.pushReplacementNamed(context, '/candidate-basic-info');
  }
}

  

  