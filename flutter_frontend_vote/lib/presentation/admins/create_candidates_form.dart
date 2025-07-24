import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/presentation/admins/forms/candidate_addition_confirmation.dart';
import 'package:flutter_frontend_vote/presentation/admins/forms/candidate_party_identity.dart';
import 'package:flutter_frontend_vote/presentation/admins/forms/educational_career.dart';
import 'package:flutter_frontend_vote/presentation/admins/forms/personal_information.dart';
import 'package:flutter_frontend_vote/presentation/admins/forms/vision_manifesto.dart';

class CreateCandidatesForm extends StatefulWidget {
  const CreateCandidatesForm({super.key});

  @override
  State<CreateCandidatesForm> createState() => _CreateCandidatesFormState();
}

class _CreateCandidatesFormState extends State<CreateCandidatesForm>
    with TickerProviderStateMixin {
  int currentStep = 0;
  PageController pageController = PageController();
  late AnimationController progressAnimationController;
  late Animation<double> progressAnimation;

  final List<GlobalKey<FormState>> formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  final List<String> stepTitles = [
    'Identity',
    'Personal Info',
    'Education & Career',
    'Vision & Manifesto',
    'Confirmation',
  ];

  @override
  void initState() {
    super.initState();
    progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: progressAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    progressAnimationController.dispose();
    super.dispose();
  }

  void nextStep() {
    if (currentStep < 4) {
      if (validateCurrentStep()) {
        setState(() {
          currentStep++;
        });
        pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        updateProgressAnimation();
      }
    }
  }

  void previousStep() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
      });
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      updateProgressAnimation();
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step <= 4) {
      setState(() {
        currentStep = step;
      });
      pageController.animateToPage(
        step,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      updateProgressAnimation();
    }
  }

  bool validateCurrentStep() {
    return formKeys[currentStep].currentState?.validate() ?? true;
  }

  void updateProgressAnimation() {
    progressAnimationController.animateTo((currentStep + 1) / 5);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Create Candidate',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Progress Bar Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Step indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(5, (index) {
                    return GestureDetector(
                      onTap: () => goToStep(index),
                      child: Column(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: index <= currentStep
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey[300],
                              border: Border.all(
                                color: index <= currentStep
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey[400]!,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: index < currentStep
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 20,
                                    )
                                  : Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        color: index <= currentStep
                                            ? Colors.white
                                            : Colors.grey[600],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            stepTitles[index],
                            style: TextStyle(
                              fontSize: 12,
                              color: index <= currentStep
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey[600],
                              fontWeight: index == currentStep
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                // Progress bar
                AnimatedBuilder(
                  animation: progressAnimation,
                  builder: (context, child) {
                    return LinearProgressIndicator(
                      value: progressAnimation.value,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                      minHeight: 4,
                    );
                  },
                ),
              ],
            ),
          ),
          // Form Content
          Expanded(
            child: PageView(
              controller: pageController,
              onPageChanged: (index) {
                setState(() {
                  currentStep = index;
                });
                updateProgressAnimation();
              },
              children: [
                // Step 1: Candidate/Party Identity
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: formKeys[0],
                    child: const CandidatePartyIdentity(formData: {},),
                  ),
                ),
                // Step 2: Personal Information
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: formKeys[1],
                    child: const PersonalInformation(formData: {},),
                  ),
                ),
                // Step 3: Education & Career
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: formKeys[2],
                    child: const EducationAndCareer(),
                  ),
                ),
                // Step 4: Vision & Manifesto
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(key: formKeys[3], child: const VisionManifesto()),
                ),
                // Step 5: Confirmation
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: formKeys[4],
                    child: const CandidateAdditionConfirmation(),
                  ),
                ),
              ],
            ),
          ),
          // Navigation Buttons
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                if (currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: previousStep,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Theme.of(context).primaryColor),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.arrow_back,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Previous',
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (currentStep > 0) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: currentStep == 4 ? null : nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 2,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          currentStep == 4 ? 'Complete' : 'Next',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (currentStep < 4) const SizedBox(width: 8),
                        if (currentStep < 4)
                          const Icon(Icons.arrow_forward, color: Colors.white),
                      ],
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
}
