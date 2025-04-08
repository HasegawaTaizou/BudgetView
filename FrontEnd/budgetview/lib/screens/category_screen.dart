import 'package:budgetview/screens/create_or_edit_category_screen.dart';
import 'package:flutter/material.dart';
import '../widgets/button_widget.dart';
import '../widgets/no_items_widget.dart';
import '../widgets/screen_title_widget.dart';
import '../widgets/input_widget.dart';
import '../widgets/chips_widget.dart';
import '../widgets/spinner_widget.dart';
import '../widgets/category_widget.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'screen_wrapper_screen.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final TextEditingController nameController = TextEditingController();
  String selectedValue = "SPEND";
  List categories = [];
  List filteredCategories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
    nameController.addListener(filterCategories);
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

  void filterCategories() {
    String searchQuery = nameController.text.toLowerCase().trim();

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
    });
    filterCategories();
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
                    title: 'Categorias',
                    subtitle: 'Visualize todas as suas categorias',
                  ),
                  const SizedBox(height: 18),
                  InputWidget(
                    controller: nameController,
                    labelText: 'Nome da categoria',
                    hintText: 'Digite o nome da categoria',
                  ),
                  const SizedBox(height: 14),
                  ChipsWidget(onSelect: handleSelection),
                  if (isLoading) ...[
                    Container(
                      height: MediaQuery.of(context).size.height - 400,
                      alignment: Alignment.center,
                      child: const AnimatedSpinner(),
                    ),
                  ] else if (filteredCategories.isEmpty) ...[
                    const SizedBox(height: 16),
                    const NoItems(
                      title: 'Não há nenhuma categoria',
                      imagePath:
                          'assets/images/no-data-categories-screen-image.svg',
                      text: 'Altere os filtros ou adicione uma categoria',
                    ),
                    const SizedBox(height: 16),
                  ] else ...[
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.59,
                      child: ListView.builder(
                        itemCount: filteredCategories.length,
                        itemBuilder: (context, index) {
                          final category = filteredCategories[index];

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ScreenWrapperScreen(
                                        screen: CreateOrEditCategoryScreen(
                                          category: category,
                                        ),
                                      ),
                                ),
                              );
                            },
                            child: Column(
                              children: [
                                CategoryWidget(
                                  title: category['name'],
                                  categoryType: category['category_type'],
                                  base64Image: category['category_icon'],
                                ),
                                const SizedBox(height: 4),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: ButtonWidget(
        text: "Adicionar categoria",
        onPressed: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      ScreenWrapperScreen(screen: CreateOrEditCategoryScreen()),
            ),
          );
        },
      ),
    );
  }
}
