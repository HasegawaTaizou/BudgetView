import 'dart:convert';
import 'package:budgetview/screens/create_or_edit_transaction_screen.dart';
import 'package:budgetview/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../widgets/button_widget.dart';
import '../widgets/no_items_widget.dart';
import '../widgets/screen_title_widget.dart';
import '../widgets/dougnut_chart_widget.dart';
import '../widgets/spinner_widget.dart';
import '../widgets/summary_card_widget.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'screen_wrapper_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double totalSpend = 0;
  double totalEarn = 0;
  List<Map<String, dynamic>> earnData = [];
  List<Map<String, dynamic>> spendData = [];
  bool isLoading = true;
  bool hasTransactions = false;

  final List<String> earnColors = ["0xFF367C00", "0xFF5CCF04", "0xFF6FFF00"];
  final List<String> spendColors = ["0xFFC81013", "0xFFFF5255", "0xFFFF9C9E"];
  final String otherColor = "0xFFD9D9D9";

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(
      Uri.parse('${dotenv.env['API_URL']}/statistics'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (!mounted) return;
      setState(() {
        totalSpend = data['total_spend'];
        totalEarn = data['total_earn'];

        earnData = _processData(data['earn_statistics'], earnColors);
        spendData = _processData(data['spend_statistics'], spendColors);

        hasTransactions = earnData.isNotEmpty || spendData.isNotEmpty;
        isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _processData(
    List<dynamic> data,
    List<String> colors,
  ) {
    if (data.isEmpty) return [];

    data.sort(
      (a, b) => double.parse(
        b['percentage'].replaceAll('%', ''),
      ).compareTo(double.parse(a['percentage'].replaceAll('%', ''))),
    );

    return data.asMap().entries.map<Map<String, dynamic>>((entry) {
      final item = entry.value;
      final index = entry.key;

      String color = otherColor;
      if (!item['category_name'].contains("Outros")) {
        if (index == 0) {
          color = colors[0];
        } else if (index == data.length - 1) {
          color = colors[2];
        } else {
          color = colors[1];
        }
      }

      return {
        "name": item['category_name'],
        "value": item['percentage'],
        "color": color,
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const ScreenTitleWidget(
              title: 'Resumo Financeiro',
              subtitle: 'Visão geral das suas finanças.',
            ),
            const SizedBox(height: 26),
            if (isLoading) ...[
              SizedBox(
                height: MediaQuery.of(context).size.height - 300,
                child: Center(child: const AnimatedSpinner()),
              ),
            ] else if (!hasTransactions) ...[
              const SizedBox(height: 16),
              const NoItems(
                title: 'Não há dados',
                imagePath: 'assets/images/no-data-home-screen-image.svg',
                text:
                    'Adicione pelo menos uma transação para visualizar seus dados',
              ),
              const SizedBox(height: 16),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: SummaryCardWidget(
                      title: "Gasto",
                      value: totalSpend,
                      color: AppColors.negativeColor,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: SummaryCardWidget(
                      title: "Ganho",
                      value: totalEarn,
                      color: AppColors.positiveColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              DonutChartWidget(isPositiveValue: true, data: earnData),
              const SizedBox(height: 18),
              DonutChartWidget(isPositiveValue: false, data: spendData),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
      bottomNavigationBar:
          !hasTransactions
              ? ButtonWidget(
                text: "Adicionar dados",
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ScreenWrapperScreen(
                            screen: CreateOrEditTransactionScreen(),
                          ),
                    ),
                  );
                },
              )
              : null,
    );
  }
}
