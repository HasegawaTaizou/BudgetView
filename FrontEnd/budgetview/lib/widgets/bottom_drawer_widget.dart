import 'package:flutter/material.dart';
import '../theme/theme.dart';
import './button_widget.dart';

class BottomDrawerWidget extends StatelessWidget {
  final String title;
  final String primaryOptionText;
  final String secondaryOptionText;
  final Future<void> Function() primaryOnPressed;
  final Future<void> Function() secondaryOnPressed;
  final Widget? child;

  const BottomDrawerWidget({
    super.key,
    required this.title,
    required this.primaryOptionText,
    required this.secondaryOptionText,
    required this.primaryOnPressed,
    required this.secondaryOnPressed,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 26, right: 25, left: 25, top: 20),
      height: 346,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(color: AppColors.primaryColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              color: Colors.black,
              fontSize: 14,
            ),
            textAlign: TextAlign.start,
          ),
          const SizedBox(height: 20),
          
          if (child != null) child!,
          
          const Spacer(),
          Column(
            children: [
              ButtonWidget(
                text: primaryOptionText,
                onPressed: primaryOnPressed,
              ),
              const SizedBox(height: 6),
              ButtonWidget(
                text: secondaryOptionText,
                isSecondaryOption: true,
                onPressed: secondaryOnPressed,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
