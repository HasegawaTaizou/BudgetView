import 'package:budgetview/widgets/spinner_widget.dart';
import 'package:flutter/material.dart';
import '../theme/theme.dart';

class ButtonWidget extends StatefulWidget {
  final String text;
  final Future<void> Function() onPressed;
  final bool isSecondaryOption;

  const ButtonWidget({
    super.key,
    required this.text,
    required this.onPressed,
    this.isSecondaryOption = false,
  });

  @override
  State<ButtonWidget> createState() => _ButtonWidgetState();
}

class _ButtonWidgetState extends State<ButtonWidget> {
  bool isLoading = false;

  void _handlePress() async {
    if (isLoading) return;

    setState(() => isLoading = true);
    await widget.onPressed();
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : _handlePress,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            widget.isSecondaryOption ? Colors.white : AppColors.primaryColor,
        fixedSize: Size(MediaQuery.of(context).size.width, 46),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
          side: BorderSide(color: AppColors.primaryColor, width: 1),
        ),
        disabledBackgroundColor:
            widget.isSecondaryOption ? Colors.white : AppColors.primaryColor,
      ),
      child:
          isLoading
              ? Center(
                child: AnimatedSpinner(
                  secondaryColor: !widget.isSecondaryOption,
                ),
              )
              : Text(
                widget.text,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: widget.isSecondaryOption ? Colors.black : Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
    );
  }
}
