import 'package:budgetview/theme/theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DonutChartWidget extends StatelessWidget {
  final bool isPositiveValue;
  final List<Map<String, dynamic>> data;

  const DonutChartWidget({super.key, required this.data, required this.isPositiveValue});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16),
            child: Text(
              isPositiveValue ?
              'Estatísticas de ganho' : 'Estatísticas de gasto',
              style: const TextStyle(
                fontFamily: 'Poppins',
                color: Colors.black,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ),
          SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections:
                    data.map((item) {
                      return PieChartSectionData(
                        color: Color(int.parse(item["color"])),
                        value: double.parse(item["value"].replaceAll('%', '')),
                        title: '',
                      );
                    }).toList(),
                sectionsSpace: 4,
                centerSpaceRadius: 45,
                borderData: FlBorderData(
                  border: Border.all(
                    color: Colors.black,
                    width: 1.0,
                    style: BorderStyle.solid,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  data.map((item) {
                    return _buildLegend(
                      Color(int.parse(item["color"])),
                      "${item["name"]} - ${item["value"]}",
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(Color color, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Colors.black,
              fontWeight: FontWeight.w900,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
