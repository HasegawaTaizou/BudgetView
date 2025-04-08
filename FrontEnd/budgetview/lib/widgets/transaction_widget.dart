import 'dart:convert';
import 'package:flutter/material.dart';
import '../theme/theme.dart';

class TransactionWidget extends StatelessWidget {
  final String title;
  final String subTitle;
  final String transactionType;
  final double amount;
  final String date;
  final String base64Image;

  const TransactionWidget({
    super.key,
    required this.title,
    required this.subTitle,
    required this.transactionType,
    required this.amount,
    required this.date,
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
                  padding: const EdgeInsets.only(left: 18),
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
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                            fontSize: 10,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: Text(
                          subTitle,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            color: AppColors.subtitleColor,
                            fontSize: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 18),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'R\$ ${amount.toString().replaceAll(".", ",")}',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: transactionType == "EARN"
                              ? AppColors.positiveColor
                              : AppColors.negativeColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.end,
                      ),
                      Text(
                        date,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          color: AppColors.subtitleColor,
                          fontSize: 8,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ],
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
