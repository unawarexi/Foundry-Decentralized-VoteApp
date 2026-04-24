import 'package:flutter/material.dart';
import 'dart:io';

class EducationAndCareer extends StatefulWidget {
  const EducationAndCareer({super.key});

  @override
  State<EducationAndCareer> createState() => _EducationAndCareerState();
}

class _EducationAndCareerState extends State<EducationAndCareer> {
  final List<Map<String, dynamic>> _educationHistory = [];
  final List<Map<String, dynamic>> _workExperience = [];
  final List<Map<String, dynamic>> _politicalExperience = [];
  final List<Map<String, dynamic>> _awards = [];

  File? _cvFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Education & Career Background')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEducationSection(),
            const SizedBox(height: 24),
            _buildWorkExperienceSection(),
            const SizedBox(height: 24),
            _buildPoliticalExperienceSection(),
            const SizedBox(height: 24),
            _buildAwardsSection(),
            const SizedBox(height: 24),
            _buildCVUploadSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildEducationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Education History',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: _addEducation,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Education'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_educationHistory.isEmpty)
              const Center(child: Text('No education entries added yet'))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _educationHistory.length,
                itemBuilder: (context, index) => _buildEducationCard(index),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEducationCard(int index) {
    final education = _educationHistory[index];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Education ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => _removeEducation(index),
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: education['institutionName'] ?? '',
              decoration: const InputDecoration(
                labelText: 'School / Institution Name *',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _educationHistory[index]['institutionName'] = value;
                });
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: education['degree'] ?? '',
              decoration: const InputDecoration(
                labelText: 'Degree / Qualification *',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _educationHistory[index]['degree'] = value;
                });
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: education['graduationYear'] ?? '',
              decoration: const InputDecoration(
                labelText: 'Year of Graduation *',
                border: OutlineInputBorder(),
                hintText: 'e.g., 2020',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  _educationHistory[index]['graduationYear'] = value;
                });
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Certificate Upload'),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () => _pickCertificate(index),
                        icon: const Icon(Icons.upload_file),
                        label: Text(
                          education['certificate'] != null
                              ? 'Certificate Selected'
                              : 'Upload Certificate',
                        ),
                      ),
                      if (education['certificate'] != null)
                        Text(
                          'File: ${education['certificate'].path.split('/').last}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkExperienceSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Work Experience',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: _addWorkExperience,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Work'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_workExperience.isEmpty)
              const Center(child: Text('No work experience entries added yet'))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _workExperience.length,
                itemBuilder: (context, index) => _buildWorkCard(index),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkCard(int index) {
    final work = _workExperience[index];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Work Experience ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => _removeWorkExperience(index),
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: work['role'] ?? '',
              decoration: const InputDecoration(
                labelText: 'Role / Title *',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _workExperience[index]['role'] = value;
                });
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: work['organization'] ?? '',
              decoration: const InputDecoration(
                labelText: 'Organization *',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _workExperience[index]['organization'] = value;
                });
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: work['duration'] ?? '',
              decoration: const InputDecoration(
                labelText: 'Duration *',
                border: OutlineInputBorder(),
                hintText: 'e.g., Jan 2020 - Dec 2022',
              ),
              onChanged: (value) {
                setState(() {
                  _workExperience[index]['duration'] = value;
                });
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: work['description'] ?? '',
              decoration: const InputDecoration(
                labelText: 'Description / Duties',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (value) {
                setState(() {
                  _workExperience[index]['description'] = value;
                });
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _pickWorkReference(index),
              icon: const Icon(Icons.upload_file),
              label: Text(
                work['reference'] != null
                    ? 'Reference Selected'
                    : 'Upload Work Reference',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPoliticalExperienceSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Previous Political Experience',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: _addPoliticalExperience,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Political'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_politicalExperience.isEmpty)
              const Center(
                child: Text('No political experience entries added yet'),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _politicalExperience.length,
                itemBuilder: (context, index) => _buildPoliticalCard(index),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPoliticalCard(int index) {
    final political = _politicalExperience[index];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Political Experience ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => _removePoliticalExperience(index),
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: political['position'] ?? '',
              decoration: const InputDecoration(
                labelText: 'Position *',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _politicalExperience[index]['position'] = value;
                });
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: political['organization'] ?? '',
              decoration: const InputDecoration(
                labelText: 'Organization *',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _politicalExperience[index]['organization'] = value;
                });
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: political['tenure'] ?? '',
              decoration: const InputDecoration(
                labelText: 'Tenure *',
                border: OutlineInputBorder(),
                hintText: 'e.g., 2018 - 2022',
              ),
              onChanged: (value) {
                setState(() {
                  _politicalExperience[index]['tenure'] = value;
                });
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: political['achievements'] ?? '',
              decoration: const InputDecoration(
                labelText: 'Achievements / Responsibilities',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (value) {
                setState(() {
                  _politicalExperience[index]['achievements'] = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAwardsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Awards & Recognitions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: _addAward,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Award'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_awards.isEmpty)
              const Center(child: Text('No awards entries added yet'))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _awards.length,
                itemBuilder: (context, index) => _buildAwardCard(index),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAwardCard(int index) {
    final award = _awards[index];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Award ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => _removeAward(index),
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: award['title'] ?? '',
              decoration: const InputDecoration(
                labelText: 'Award Title *',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _awards[index]['title'] = value;
                });
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: award['organization'] ?? '',
              decoration: const InputDecoration(
                labelText: 'Awarding Organization',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _awards[index]['organization'] = value;
                });
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: award['year'] ?? '',
              decoration: const InputDecoration(
                labelText: 'Year Received',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  _awards[index]['year'] = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCVUploadSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CV / Resume Upload',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickCV,
              icon: const Icon(Icons.upload_file),
              label: Text(
                _cvFile != null
                    ? 'CV Selected: ${_cvFile!.path.split('/').last}'
                    : 'Upload CV / Resume',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Accepted formats: PDF, DOC, DOCX (Max 5MB)',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // Add methods
  void _addEducation() {
    setState(() {
      _educationHistory.add({
        'institutionName': '',
        'degree': '',
        'graduationYear': '',
        'certificate': null,
      });
    });
  }

  void _addWorkExperience() {
    setState(() {
      _workExperience.add({
        'role': '',
        'organization': '',
        'duration': '',
        'description': '',
        'reference': null,
      });
    });
  }

  void _addPoliticalExperience() {
    setState(() {
      _politicalExperience.add({
        'position': '',
        'organization': '',
        'tenure': '',
        'achievements': '',
      });
    });
  }

  void _addAward() {
    setState(() {
      _awards.add({'title': '', 'organization': '', 'year': ''});
    });
  }

  // Remove methods
  void _removeEducation(int index) {
    setState(() {
      _educationHistory.removeAt(index);
    });
  }

  void _removeWorkExperience(int index) {
    setState(() {
      _workExperience.removeAt(index);
    });
  }

  void _removePoliticalExperience(int index) {
    setState(() {
      _politicalExperience.removeAt(index);
    });
  }

  void _removeAward(int index) {
    setState(() {
      _awards.removeAt(index);
    });
  }

  // File picker methods (you'll need to implement these with file_picker package)
  void _pickCertificate(int index) {
    // Implement file picker for certificate
    // Use file_picker package to select PDF, PNG, JPG files
    // Update _educationHistory[index]['certificate'] with selected file
  }

  void _pickWorkReference(int index) {
    // Implement file picker for work reference
    // Update _workExperience[index]['reference'] with selected file
  }

  void _pickCV() {
    // Implement file picker for CV
    // Update _cvFile with selected file
  }
}
