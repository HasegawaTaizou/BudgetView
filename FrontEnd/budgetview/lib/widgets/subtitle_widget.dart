import 'package:flutter/material.dart';
import '../theme/theme.dart';

class SubtitleWidget extends StatelessWidget {
  final String text;

  const SubtitleWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Poppins',
        color: AppColors.subtitleColor,
        fontSize: 12,
      ),
      textAlign: TextAlign.left,
    );
  }
}
