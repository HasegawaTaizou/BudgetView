import 'package:flutter/material.dart';

import '../theme/theme.dart';

class ChipsWidget extends StatefulWidget {
  final Function(String) onSelect;

  const ChipsWidget({super.key, required this.onSelect});

  @override
  _ChipsWidgetState createState() => _ChipsWidgetState();
}

class _ChipsWidgetState extends State<ChipsWidget> {
  int selectedIndex = 0;

  final Map<int, String> predefinedValues = {0: "SPEND", 1: "EARN"};

  final Map<int, String> displayTexts = {0: "Gasto", 1: "Ganho"};

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(2, (index) {
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                selectedIndex = index;
              });

              widget.onSelect(predefinedValues[index]!);
            },
            child: Container(
              decoration: BoxDecoration(
                color:
                    selectedIndex == index
                        ? AppColors.primaryColor
                        : Colors.white,
                border: Border.all(color: AppColors.primaryColor, width: 1),
                borderRadius: BorderRadius.circular(100),
              ),
              height: 28,
              margin: EdgeInsets.only(
                left: index == 1 ? 4 : 0,
                right: index == 0 ? 4 : 0,
              ),
              alignment: Alignment.center,
              child: Text(
                displayTexts[index]!,
                style: TextStyle(
                  fontSize: 10,
                  fontFamily: 'Poppins',
                  color: selectedIndex == index ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
