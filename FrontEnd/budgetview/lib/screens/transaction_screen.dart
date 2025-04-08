import 'package:flutter/material.dart';
import '../widgets/button_widget.dart';
import '../widgets/no_items_widget.dart';
import '../widgets/screen_title_widget.dart';
import '../widgets/input_widget.dart';
import '../widgets/chips_widget.dart';
import '../widgets/spinner_widget.dart';
import '../widgets/transaction_widget.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'create_or_edit_transaction_screen.dart';
import 'screen_wrapper_screen.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final TextEditingController nameController = TextEditingController();
  String selectedValue = "SPEND";
  List transactions = [];
  List filteredTransactions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
    nameController.addListener(filterTransactions);
  }

  Future<void> fetchData() async {
    final url = Uri.parse('${dotenv.env['API_URL']}/transactions');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (!mounted) return;
        setState(() {
          transactions = data["transactions"];
          filteredTransactions = data["transactions"];
          isLoading = false;
        });
        filterTransactions();
      } else {
        if (!mounted) return;
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterTransactions() {
    String searchQuery = nameController.text.toLowerCase().trim();

    setState(() {
      if (searchQuery.isEmpty) {
        filteredTransactions =
            transactions.where((transaction) {
              return transaction['category_type']?.toString() == selectedValue;
            }).toList();
      } else {
        filteredTransactions =
            transactions.where((transaction) {
              bool matchesName =
                  transaction['name']?.toString().toLowerCase().contains(
                    searchQuery,
                  ) ??
                  false;

              bool matchesType =
                  transaction['category_type']?.toString() == selectedValue;

              return matchesName && matchesType;
            }).toList();
      }
    });
  }

  void handleSelection(String value) {
    setState(() {
      selectedValue = value;
    });
    filterTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  const ScreenTitleWidget(
                    title: 'Transações',
                    subtitle: 'Visualize suas transações criadas',
                  ),
                  const SizedBox(height: 18),
                  InputWidget(
                    controller: nameController,
                    labelText: 'Nome da transação',
                    hintText: 'Digite o nome da transação',
                  ),
                  const SizedBox(height: 14),
                  ChipsWidget(onSelect: handleSelection),
                  if (isLoading) ...[
                    Container(
                      height: MediaQuery.of(context).size.height - 400,
                      alignment: Alignment.center,
                      child: const AnimatedSpinner(),
                    ),
                  ] else if (filteredTransactions.isEmpty) ...[
                    const SizedBox(height: 16),
                    const NoItems(
                      title: 'Não há nenhuma transação',
                      imagePath:
                          'assets/images/no-data-transactions-screen-image.svg',
                      text:
                          'Adicione pelo menos uma transação para visualizar seus dados',
                    ),
                    const SizedBox(height: 16),
                  ] else ...[
                    Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.59,
                          child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: filteredTransactions.length,
                            itemBuilder: (context, index) {
                              final transaction = filteredTransactions[index];

                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => ScreenWrapperScreen(
                                            screen:
                                                CreateOrEditTransactionScreen(
                                                  transaction: transaction,
                                                ),
                                          ),
                                    ),
                                  );
                                },
                                child: Column(
                                  children: [
                                    TransactionWidget(
                                      title: transaction['name'],
                                      subTitle: transaction['category_name'],
                                      transactionType:
                                          transaction['category_type'],
                                      amount: transaction['value'],
                                      date: transaction['date'],
                                      base64Image: transaction['category_icon'],
                                    ),
                                    const SizedBox(height: 4),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: ButtonWidget(
        text: "Adicionar transação",
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
      ),
    );
  }
}
