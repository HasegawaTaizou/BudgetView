import 'package:flutter/material.dart';
import 'package:budgetview/theme/theme.dart';

class AnimatedSpinner extends StatelessWidget {
  final bool? secondaryColor;

  const AnimatedSpinner({super.key, this.secondaryColor});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(seconds: 2),
        builder: (context, value, child) {
          return Transform.rotate(
            angle: value * 6.28,
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  secondaryColor == true
                      ? Colors.white
                      : AppColors.primaryColor,
                ),
                strokeWidth: 4,
              ),
            ),
          );
        },
      ),
    );
  }
}
