import 'dart:convert';
import 'package:flutter/material.dart';
import '../theme/theme.dart';

class CategoryWidget extends StatelessWidget {
  final String title;
  final String categoryType;
  final String base64Image;

  const CategoryWidget({
    super.key,
    required this.title,
    required this.categoryType,
    required this.base64Image,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppColors.cardBackgroundColor,
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 18.0),
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.2),
                          blurRadius: 4,
                          offset: Offset(2, 2),
                        ),
                      ],
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Image.memory(
                          base64Decode(base64Image),
                          width: 22,
                          height: 22,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Spacer(),
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 18.0, top: 8),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: (categoryType == "EARN"
                                ? AppColors.positiveColor
                                : AppColors.negativeColor)
                            .withAlpha(30),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      width: 48,
                      height: 18,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          categoryType == "EARN" ? "Ganho" : "Gasto",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color:
                                categoryType == "EARN"
                                    ? AppColors.positiveColor
                                    : AppColors.negativeColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 8,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
