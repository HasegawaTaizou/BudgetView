import 'package:flutter/material.dart';

class OrWidget extends StatelessWidget {
  const OrWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(color: Color(0xFFD0D0D0)),
          ),
        ),
        SizedBox(width: 12),
        Text(
          'Ou',
          style: const TextStyle(
            fontFamily: 'Poppins',
            color: Color(0xFFD0D0D0),
            fontSize: 12,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(color: Color(0xFFD0D0D0)),
          ),
        ),
      ],
    );
  }
}
