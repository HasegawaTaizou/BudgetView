import 'package:flutter/material.dart';

import 'title_widget.dart';
import 'subtitle_widget.dart';

class ScreenTitleWidget extends StatelessWidget {
  final String title;
  final String subtitle;

  const ScreenTitleWidget({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          TitleWidget(text: title),
          SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            child: SubtitleWidget(text: subtitle)),
        ],
      ),
    );
  }
}
