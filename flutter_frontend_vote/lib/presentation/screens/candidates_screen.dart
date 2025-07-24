import 'package:flutter/material.dart';
import 'package:flutter_frontend_vote/presentation/admins/create_candidates_form.dart';

class CandidatesScreen extends StatefulWidget {
  const CandidatesScreen({super.key});

  @override
  State<CandidatesScreen> createState() => _CandidatesScreenState();
}

class _CandidatesScreenState extends State<CandidatesScreen> {
  @override
  Widget build(BuildContext context) {
    return const CreateCandidatesForm();
  }
}
