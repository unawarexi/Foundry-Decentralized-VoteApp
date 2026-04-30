import 'package:flutter/material.dart';
import 'stat_chip.dart';

class ProfileStatsRow extends StatelessWidget {
  final Animation<double> statsFade;
  final Animation<Offset> statsSlide;

  const ProfileStatsRow({
    super.key,
    required this.statsFade,
    required this.statsSlide,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: statsFade,
      child: SlideTransition(
        position: statsSlide,
        child: Row(
          children: const [
            Expanded(
              child: ProfileStatChip(
                value: '2',
                label: 'Votes\nCast',
                icon: Icons.how_to_vote_outlined,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: ProfileStatChip(
                value: '12',
                label: 'Candidates\nFollowed',
                icon: Icons.person_search_outlined,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: ProfileStatChip(
                value: '6',
                label: 'Questions\nAsked',
                icon: Icons.forum_outlined,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: ProfileStatChip(
                value: '98%',
                label: 'Civic\nScore',
                icon: Icons.verified_outlined,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
