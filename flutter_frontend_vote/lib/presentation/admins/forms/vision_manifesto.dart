import 'package:flutter/material.dart';

class VisionManifesto extends StatefulWidget {
  const VisionManifesto({super.key});

  @override
  State<VisionManifesto> createState() => _VisionManifestoState();
}

class _VisionManifestoState extends State<VisionManifesto>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Form Controllers
  final _visionController = TextEditingController();
  final _keyPointsController = TextEditingController();
  final _commitmentsController = TextEditingController();
  final _achievementsController = TextEditingController();
  final _policiesController = TextEditingController();
  final _videoLinkController = TextEditingController();

  String? _manifestoFile;
  String? _videoFile;
  String? _audioFile;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.elasticOut,
          ),
        );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _visionController.dispose();
    _keyPointsController.dispose();
    _commitmentsController.dispose();
    _achievementsController.dispose();
    _policiesController.dispose();
    _videoLinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF0F0F23)
          : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Vision & Manifesto'),
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
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Campaign Vision', Icons.visibility),
                  const SizedBox(height: 16),
                  _buildVisionStatement(),
                  const SizedBox(height: 32),

                  _buildSectionHeader(
                    'Manifesto Document',
                    Icons.document_scanner,
                  ),
                  const SizedBox(height: 16),
                  _buildManifestoUpload(),
                  const SizedBox(height: 32),

                  _buildSectionHeader(
                    'Campaign Video',
                    Icons.video_camera_back,
                  ),
                  const SizedBox(height: 16),
                  _buildVideoSection(),
                  const SizedBox(height: 32),

                  _buildSectionHeader('Key Highlights', Icons.star),
                  const SizedBox(height: 16),
                  _buildKeyPoints(),
                  const SizedBox(height: 32),

                  _buildSectionHeader('Public Commitments', Icons.handshake),
                  const SizedBox(height: 16),
                  _buildCommitments(),
                  const SizedBox(height: 32),

                  _buildSectionHeader(
                    'Notable Achievements',
                    Icons.emoji_events,
                  ),
                  const SizedBox(height: 16),
                  _buildAchievements(),
                  const SizedBox(height: 32),

                  _buildSectionHeader('Proposed Policies', Icons.policy),
                  const SizedBox(height: 16),
                  _buildPolicies(),
                  const SizedBox(height: 32),

                  _buildSectionHeader('Party Jingle/Audio', Icons.music_note),
                  const SizedBox(height: 16),
                  _buildAudioUpload(),
                  const SizedBox(height: 32),

                  _buildNavigationButtons(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: Theme.of(context).brightness == Brightness.dark
                  ? [const Color(0xFF64FFDA), const Color(0xFF1DE9B6)]
                  : [const Color(0xFF1976D2), const Color(0xFF42A5F5)],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : const Color(0xFF2C3E50),
          ),
        ),
      ],
    );
  }

  Widget _buildVisionStatement() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: Theme.of(context).brightness == Brightness.dark
              ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
              : [Colors.white, const Color(0xFFF8F9FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
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
          Text(
            'Campaign Vision Statement *',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF64FFDA)
                  : const Color(0xFF1976D2),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _visionController,
            maxLines: 6,
            maxLength: 500,
            decoration: InputDecoration(
              hintText:
                  'Describe your vision for the future in a compelling and concise manner...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF64FFDA)
                      : const Color(0xFF1976D2),
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF0F0F23)
                  : Colors.grey[50],
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vision statement is required';
              }
              if (value.trim().length < 50) {
                return 'Vision statement should be at least 50 characters';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildManifestoUpload() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: Theme.of(context).brightness == Brightness.dark
              ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
              : [Colors.white, const Color(0xFFF8F9FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
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
        children: [
          Icon(
            _manifestoFile != null ? Icons.check_circle : Icons.upload_file,
            size: 60,
            color: _manifestoFile != null
                ? Colors.green
                : (Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF64FFDA)
                      : const Color(0xFF1976D2)),
          ),
          const SizedBox(height: 16),
          Text(
            _manifestoFile != null
                ? 'Manifesto uploaded successfully'
                : 'Upload Full Manifesto *',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: _manifestoFile != null ? Colors.green : null,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'PDF or DOC format • Max 10MB',
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white70
                  : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _uploadManifesto,
            icon: const Icon(Icons.file_upload),
            label: Text(_manifestoFile != null ? 'Change File' : 'Choose File'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF64FFDA)
                  : const Color(0xFF1976D2),
              foregroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black
                  : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: Theme.of(context).brightness == Brightness.dark
              ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
              : [Colors.white, const Color(0xFFF8F9FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
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
          TextFormField(
            controller: _videoLinkController,
            decoration: InputDecoration(
              labelText: 'YouTube/IPFS Video Link',
              hintText: 'https://youtube.com/watch?v=...',
              prefixIcon: Icon(
                Icons.link,
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF64FFDA)
                    : const Color(0xFF1976D2),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF64FFDA)
                      : const Color(0xFF1976D2),
                  width: 2,
                ),
              ),
            ),
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                if (!Uri.tryParse(value)!.hasAbsolutePath == true) {
                  return 'Please enter a valid URL';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                Icon(
                  _videoFile != null ? Icons.check_circle : Icons.video_call,
                  size: 40,
                  color: _videoFile != null
                      ? Colors.green
                      : (Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF64FFDA)
                            : const Color(0xFF1976D2)),
                ),
                const SizedBox(height: 8),
                Text(
                  _videoFile != null
                      ? 'Video uploaded'
                      : 'Or upload video file',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white70
                        : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Max 5 minutes • MP4 format • Max 100MB',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white54
                        : Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _uploadVideo,
                  icon: const Icon(Icons.video_file),
                  label: Text(
                    _videoFile != null ? 'Change Video' : 'Upload Video',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF64FFDA).withOpacity(0.8)
                        : const Color(0xFF1976D2).withOpacity(0.8),
                    foregroundColor:
                        Theme.of(context).brightness == Brightness.dark
                        ? Colors.black
                        : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyPoints() {
    return _buildTextArea(
      controller: _keyPointsController,
      title: 'Key Points/Highlights *',
      hintText:
          '• Point 1: Economic development\n• Point 2: Education reform\n• Point 3: Healthcare improvement',
      maxLines: 8,
      isRequired: true,
    );
  }

  Widget _buildCommitments() {
    return _buildTextArea(
      controller: _commitmentsController,
      title: 'Public Commitments/Promises *',
      hintText: 'List your specific commitments to the voters...',
      maxLines: 8,
      isRequired: true,
    );
  }

  Widget _buildAchievements() {
    return _buildTextArea(
      controller: _achievementsController,
      title: 'Notable Achievements',
      hintText: 'List your past achievements in politics or other fields...',
      maxLines: 6,
      isRequired: false,
    );
  }

  Widget _buildPolicies() {
    return _buildTextArea(
      controller: _policiesController,
      title: 'Proposed Policies (Optional)',
      hintText: 'Detail your policy proposals...',
      maxLines: 8,
      isRequired: false,
    );
  }

  Widget _buildTextArea({
    required TextEditingController controller,
    required String title,
    required String hintText,
    required int maxLines,
    required bool isRequired,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: Theme.of(context).brightness == Brightness.dark
              ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
              : [Colors.white, const Color(0xFFF8F9FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
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
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF64FFDA)
                  : const Color(0xFF1976D2),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hintText,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF64FFDA)
                      : const Color(0xFF1976D2),
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF0F0F23)
                  : Colors.grey[50],
            ),
            validator: isRequired
                ? (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '${title.replaceAll(' *', '')} is required';
                    }
                    return null;
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildAudioUpload() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: Theme.of(context).brightness == Brightness.dark
              ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
              : [Colors.white, const Color(0xFFF8F9FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
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
        children: [
          Icon(
            _audioFile != null ? Icons.check_circle : Icons.music_note,
            size: 50,
            color: _audioFile != null
                ? Colors.green
                : (Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF64FFDA)
                      : const Color(0xFF1976D2)),
          ),
          const SizedBox(height: 16),
          Text(
            _audioFile != null
                ? 'Party jingle uploaded'
                : 'Upload Party Jingle/Audio (Optional)',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: _audioFile != null ? Colors.green : null,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'MP3, WAV format • Max 5MB • Max 2 minutes',
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white70
                  : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _uploadAudio,
                  icon: const Icon(Icons.audiotrack),
                  label: Text(
                    _audioFile != null ? 'Change Audio' : 'Choose Audio',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF64FFDA).withOpacity(0.8)
                        : const Color(0xFF1976D2).withOpacity(0.8),
                    foregroundColor:
                        Theme.of(context).brightness == Brightness.dark
                        ? Colors.black
                        : Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isRecording ? _stopRecording : _startRecording,
                  icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                  label: Text(_isRecording ? 'Stop Recording' : 'Record Audio'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isRecording
                        ? Colors.red
                        : (Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF64FFDA).withOpacity(0.8)
                              : const Color(0xFF1976D2).withOpacity(0.8)),
                    foregroundColor:
                        Theme.of(context).brightness == Brightness.dark
                        ? Colors.black
                        : Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_isRecording) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.fiber_manual_record, color: Colors.red, size: 12),
                  SizedBox(width: 8),
                  Text(
                    'Recording in progress...',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Previous'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1A1A2E)
                  : Colors.grey[300],
              foregroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white70
                  : Colors.black87,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF0F3460)
                      : Colors.grey[400]!,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _validateAndNext,
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Next'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF64FFDA)
                  : const Color(0xFF1976D2),
              foregroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black
                  : Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
          ),
        ),
      ],
    );
  }

  void _uploadManifesto() {
    // File upload implementation
    setState(() {
      _manifestoFile = 'manifesto.pdf';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Manifesto uploaded successfully'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _uploadVideo() {
    // Video upload implementation
    setState(() {
      _videoFile = 'campaign_video.mp4';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Video uploaded successfully'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _uploadAudio() {
    // Audio upload implementation
    setState(() {
      _audioFile = 'party_jingle.mp3';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Audio uploaded successfully'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _startRecording() {
    // Audio recording implementation
    setState(() {
      _isRecording = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Recording started'),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _stopRecording() {
    // Stop recording implementation
    setState(() {
      _isRecording = false;
      _audioFile = 'recorded_audio.wav';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Recording stopped and saved'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _validateAndNext() {
    if (_formKey.currentState!.validate()) {
      if (_manifestoFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please upload your manifesto document'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        return;
      }

      // Navigate to next step (Step 5: Candidate Addition & Confirmation)
      Navigator.pushNamed(context, '/candidate-confirmation');
    }
  }
}
