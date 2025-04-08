import 'package:flutter/material.dart';
import '../theme/theme.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NoItems extends StatelessWidget {
  final String title;
  final String imagePath;
  final String text;

  const NoItems({super.key, required this.title, required this.text, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              color: Colors.black,
              fontWeight: FontWeight.w900,
              fontSize: 20,
            ),
          ),
        ),
        SizedBox(height: 20),
        SvgPicture.asset(imagePath),
        SizedBox(height: 20),
        Text(
          text,
          style: const TextStyle(
            fontFamily: 'Poppins',
            color: AppColors.subtitleColor,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
