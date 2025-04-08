import 'package:budgetview/theme/theme.dart';
import 'package:budgetview/widgets/category_widget.dart';
import 'package:budgetview/widgets/spinner_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../widgets/notification_widget.dart';
import '../widgets/screen_title_widget.dart';
import '../widgets/input_widget.dart';
import '../widgets/button_widget.dart';
import '../widgets/or_widget.dart';
import '../widgets/chips_widget.dart';
import '../widgets/transaction_widget.dart';
import '../widgets/bottom_drawer_widget.dart';

import '../utils/date_input_formatter.dart';
import '../utils/currency_input_formatter.dart';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

import 'screen_wrapper_screen.dart';

class CreateOrEditTransactionScreen extends StatefulWidget {
  final Map<String, dynamic>? transaction;

  const CreateOrEditTransactionScreen({super.key, this.transaction});

  @override
  _CreateOrEditTransactionScreenState createState() =>
      _CreateOrEditTransactionScreenState();
}

class _CreateOrEditTransactionScreenState
    extends State<CreateOrEditTransactionScreen> {
  final TextEditingController transactionName = TextEditingController();
  final TextEditingController valueController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController categoryFilterNameController =
      TextEditingController();

  bool trainModel = false;
  String selectedValue = "SPEND";
  List categories = [];
  List filteredCategories = [];
  bool isLoading = true;
  bool isCategorizeLoading = false;
  int? selectedIndex;
  int? categoryId;
  String? categoryName = "";
  String? selectedBase64Image = "";
  String? categoryFilterName = "";

  @override
  void initState() {
    super.initState();
    fetchData();

    if (widget.transaction != null) {
      final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
      final formattedValue = formatter.format(
        widget.transaction!['value'] ?? 0,
      );

      transactionName.text = widget.transaction!['name'] ?? '';
      dateController.text = widget.transaction!['date'] ?? '';
      valueController.text = formattedValue;
      selectedValue = widget.transaction!['category_type'] ?? 'SPEND';
      categoryId = widget.transaction!['id_category'];
      categoryName = widget.transaction!['category_name'];
      selectedBase64Image = widget.transaction!['category_icon'];
    }

    transactionName.addListener(_updateState);
    valueController.addListener(_updateState);
    dateController.addListener(_updateState);
    categoryFilterNameController.addListener(_updateState);
  }

  @override
  void dispose() {
    transactionName.dispose();
    valueController.dispose();
    dateController.dispose();
    super.dispose();
  }

  void _updateState() {
    setState(() {});
  }

  bool isFormFilled() {
    return transactionName.text.isNotEmpty &&
        valueController.text.isNotEmpty &&
        categoryName!.isNotEmpty &&
        selectedBase64Image!.isNotEmpty &&
        dateController.text.isNotEmpty;
  }

  Future<void> fetchData() async {
    final url = Uri.parse('${dotenv.env['API_URL']}/categories');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (!mounted) return;
        setState(() {
          categories = data["categories"];
          filteredCategories = data["categories"];
          isLoading = false;
        });
        filterCategories();
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

  Future<void> _handleTransaction() async {
    if (trainModel) {
      Map<String, dynamic> trainData = {
        "name": transactionName.text,
        "category": categoryName,
      };

      String jsonData = jsonEncode(trainData);

      final url = Uri.parse('${dotenv.env['API_URL']}/ai/train');

      await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonData,
      );
    }

    Map<String, dynamic> transactionData = {
      "name": transactionName.text,
      "value":
          double.tryParse(
            valueController.text
                .replaceAll(RegExp(r'[^\d,]'), '')
                .replaceAll(",", "."),
          ) ??
          0.0,
      "date": dateController.text,
      "id_category": categoryId,
    };

    String jsonData = jsonEncode(transactionData);

    final url =
        widget.transaction == null
            ? Uri.parse('${dotenv.env['API_URL']}/transactions')
            : Uri.parse(
              '${dotenv.env['API_URL']}/transactions/${widget.transaction!['id']}',
            );

    try {
      String message =
          widget.transaction == null
              ? "Transação criada com sucesso!"
              : "Transação atualizada com sucesso!";

      final response =
          widget.transaction == null
              ? await http.post(
                url,
                headers: {"Content-Type": "application/json"},
                body: jsonData,
              )
              : await http.put(
                url,
                headers: {"Content-Type": "application/json"},
                body: jsonData,
              );

      if (response.statusCode == 201 || response.statusCode == 204) {
        NotificationWidget.show(context, message: message);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScreenWrapperScreen(selectedIndex: 1),
          ),
        );
      } else {
        String message =
            widget.transaction == null
                ? "Erro criar ao transação!"
                : "Erro salvar ao transação!";
        NotificationWidget.show(context, message: message, isSuccess: false);
      }
    } catch (e) {
      String message =
          widget.transaction == null
              ? "Erro criar ao transação!"
              : "Erro salvar ao transação!";
      NotificationWidget.show(context, message: message, isSuccess: false);
    }
  }

  Future<void> _handleCategorize() async {
    Map<String, dynamic> transactionData = {"name": transactionName.text};

    String jsonData = jsonEncode(transactionData);

    final url = Uri.parse('${dotenv.env['API_URL']}/ai/categorize');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonData,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          selectedIndex = null;
          categoryId = data['id'];
          categoryName = data['name'];
          selectedBase64Image = data['category_icon'];
          selectedValue = data['category_type'];
        });
      } else {
        String message = "Erro ao categorizar transação!";
        NotificationWidget.show(context, message: message, isSuccess: false);
      }
    } catch (e) {
      String message = "Erro ao categorizar transação!";
      NotificationWidget.show(context, message: message, isSuccess: false);
    }
  }

  Future<void> _deleteTransaction() async {
    try {
      final url = Uri.parse(
        '${dotenv.env['API_URL']}/transactions/${widget.transaction!['id']}',
      );

      final response = await http.delete(
        url,
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 204) {
        String message = "Transação removida com sucesso!";

        NotificationWidget.show(context, message: message);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScreenWrapperScreen(selectedIndex: 1),
          ),
        );
      } else {
        String message = "Erro ao remover transação!";
        NotificationWidget.show(context, message: message, isSuccess: false);
      }
    } catch (e) {
      String message = "Erro ao remover transação!";
      NotificationWidget.show(context, message: message, isSuccess: false);
    }
  }

  void filterCategories() {
    String searchQuery = categoryFilterNameController.text.toLowerCase().trim();

    setState(() {
      if (searchQuery.isEmpty) {
        filteredCategories =
            categories.where((category) {
              return category['category_type']?.toString() == selectedValue;
            }).toList();
      } else {
        filteredCategories =
            categories.where((category) {
              bool matchesName =
                  category['name']?.toString().toLowerCase().contains(
                    searchQuery,
                  ) ??
                  false;

              bool matchesType =
                  category['category_type']?.toString() == selectedValue;

              return matchesName && matchesType;
            }).toList();
      }
    });
  }

  void handleSelection(String value) {
    setState(() {
      selectedValue = value;
      selectedIndex = null;
      categoryId = null;
      categoryName = "";
      selectedBase64Image = "";
    });
    filterCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            ScreenTitleWidget(
              title:
                  widget.transaction == null
                      ? 'Adicionar transação'
                      : 'Detalhes da transação',
              subtitle:
                  widget.transaction == null
                      ? 'Crie uma transação para ter uma visão da sua vida financeira'
                      : 'Edite a sua transação',
            ),
            const SizedBox(height: 18),
            InputWidget(
              controller: transactionName,
              labelText: 'Nome da transação',
              hintText: 'Digite o nome da transação',
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: Row(
                children: [
                  Expanded(
                    child: InputWidget(
                      controller: valueController,
                      labelText: 'Valor',
                      hintText: 'Digite o valor da transação',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        CurrencyInputFormatter(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: InputWidget(
                      controller: dateController,
                      labelText: 'Data',
                      hintText: 'Digite a data da transação',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        DateInputFormatter(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            ButtonWidget(
              text: "Categorização automática",
              onPressed: () async {
                setState(() {
                  isCategorizeLoading = true;
                });
                await _handleCategorize();
                setState(() {
                  isCategorizeLoading = false;
                });
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  builder: (context) {
                    if (!isCategorizeLoading) {
                      return BottomDrawerWidget(
                        title: 'Confirmar categorização automática',
                        primaryOptionText: 'Confirmar',
                        secondaryOptionText: 'Cancelar',
                        primaryOnPressed: () async {
                          setState(() {
                            trainModel = false;
                          });
                          Navigator.of(context).pop();
                        },
                        secondaryOnPressed: () async {
                          setState(() {
                            selectedIndex = null;
                            categoryId = null;
                            categoryName = null;
                            selectedBase64Image = null;
                            trainModel = true;
                          });
                          Navigator.of(context).pop();
                        },
                        child: CategoryWidget(
                          title: categoryName!,
                          categoryType: selectedValue,
                          base64Image: selectedBase64Image!,
                        ),
                      );
                    } else {
                      return Container(
                        padding: const EdgeInsets.only(
                          bottom: 26,
                          right: 25,
                          left: 25,
                          top: 20,
                        ),
                        height: 346,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                          border: Border.all(
                            color: AppColors.primaryColor,
                            width: 1,
                          ),
                        ),
                        child: Center(child: AnimatedSpinner()),
                      );
                    }
                  },
                );
              },
            ),

            const SizedBox(height: 12),
            OrWidget(),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: Text(
                "Selecione o tipo da categoria",
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Poppins',
                  color: Colors.black,
                ),
                textAlign: TextAlign.start,
              ),
            ),
            const SizedBox(height: 8),
            ChipsWidget(onSelect: handleSelection),
            const SizedBox(height: 20),
            Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: AppColors.cardBackgroundColor,
                  ),
                  padding: EdgeInsets.all(10),
                  height: MediaQuery.of(context).size.height - 750,
                  child:
                      isLoading
                          ? Center(child: AnimatedSpinner())
                          : ListView.builder(
                            padding: EdgeInsets.all(0),
                            itemCount: filteredCategories.length,
                            itemBuilder: (context, index) {
                              final category = filteredCategories[index];
                              final isSelected = selectedIndex == index;

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedIndex = index;
                                    categoryId = category['id'];
                                    categoryName = category['name'];
                                    selectedBase64Image =
                                        category['category_icon'];
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Container(
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color:
                                          isSelected
                                              ? AppColors.primaryColor
                                              : Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 18,
                                          ),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Color.fromRGBO(
                                                    0,
                                                    0,
                                                    0,
                                                    0.2,
                                                  ),
                                                  blurRadius: 4,
                                                  offset: Offset(2, 2),
                                                ),
                                              ],
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  3.0,
                                                ),
                                                child: Image.memory(
                                                  base64Decode(
                                                    category['category_icon'],
                                                  ),
                                                  width: 14,
                                                  height: 14,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          category['name'],
                                          style: TextStyle(
                                            fontSize: 8,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w900,
                                            color:
                                                isSelected
                                                    ? Colors.white
                                                    : Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (isFormFilled())
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        "Resultado",
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'Poppins',
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TransactionWidget(
                    title: transactionName.text,
                    subTitle: categoryName!,
                    transactionType: selectedValue,
                    amount:
                        double.tryParse(
                          valueController.text
                              .replaceAll(RegExp(r'[^\d,]'), '')
                              .replaceAll(",", "."),
                        ) ??
                        0.0,
                    date: dateController.text,
                    base64Image: selectedBase64Image!,
                  ),
                ],
              ),
          ],
        ),
      ),
      bottomNavigationBar:
          widget.transaction == null
              ? ButtonWidget(
                text: "Adicionar transação",
                onPressed: () async {
                  await _handleTransaction();
                },
              )
              : Column(
                mainAxisSize: MainAxisSize.min,

                children: [
                  ButtonWidget(
                    text: "Salvar",
                    onPressed: () async {
                      await _handleTransaction();
                    },
                  ),
                  SizedBox(height: 10),
                  ButtonWidget(
                    text: "Excluir",
                    onPressed: () async {
                      await _deleteTransaction();
                    },
                    isSecondaryOption: true,
                  ),
                ],
              ),
    );
  }
}
