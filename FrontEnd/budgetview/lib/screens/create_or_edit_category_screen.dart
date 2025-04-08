import 'dart:convert';

import 'package:budgetview/theme/theme.dart';
import 'package:budgetview/widgets/category_widget.dart';
import 'package:flutter/material.dart';

import '../widgets/notification_widget.dart';
import '../widgets/screen_title_widget.dart';
import '../widgets/input_widget.dart';
import '../widgets/button_widget.dart';
import '../widgets/or_widget.dart';
import '../widgets/chips_widget.dart';
import '../widgets/image_picker_widget.dart';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../widgets/spinner_widget.dart';
import 'screen_wrapper_screen.dart';

class CreateOrEditCategoryScreen extends StatefulWidget {
  final Map<String, dynamic>? category;

  const CreateOrEditCategoryScreen({super.key, this.category});

  @override
  _CreateOrEditCategoryScreenState createState() =>
      _CreateOrEditCategoryScreenState();
}

class _CreateOrEditCategoryScreenState
    extends State<CreateOrEditCategoryScreen> {
  final TextEditingController categoryNameController = TextEditingController();

  String selectedValue = "SPEND";
  List icons = [];
  List filteredIcons = [];
  bool isLoading = true;
  int? selectedIndex;
  int? iconId;
  String? selectedBase64Image = "";
  bool isCustomImage = false;

  @override
  void initState() {
    super.initState();
    fetchData();

    if (widget.category != null) {
      categoryNameController.text = widget.category!['name'] ?? '';
      selectedValue = widget.category!['category_type'] ?? 'SPEND';
      iconId = widget.category!['id_icon'];
      selectedBase64Image = widget.category!['category_icon'];
    }
  }

  @override
  void dispose() {
    categoryNameController.dispose();
    super.dispose();
  }

  void _handleImage(String base64Image) async {
    setState(() {
      selectedIndex = null;
      isCustomImage = true;
      selectedBase64Image =base64Image;
      iconId = null;
    });
  }

  bool isFormFilled() {
    return categoryNameController.text.isNotEmpty &&
        selectedBase64Image!.isNotEmpty;
  }

  Future<void> fetchData() async {
    final url = Uri.parse('${dotenv.env['API_URL']}/icons');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (!mounted) return;
        setState(() {
          icons = data["icons"];
          filteredIcons = data["icons"];
          isLoading = false;
        });
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

  Future<void> _handleCategory() async {
    final isCreating = widget.category == null;
    final apiUrl = dotenv.env['API_URL'];

    Map<String, dynamic> categoryData = {
      "name": categoryNameController.text,
      "id_icon": iconId,
      "type": selectedValue,
    };

    if (categoryData['id_icon'] == null && selectedBase64Image != null) {
      try {
        final iconData = jsonEncode({"icon": selectedBase64Image});
        final iconUrl = Uri.parse('$apiUrl/icons');

        final iconResponse = await http.post(
          iconUrl,
          headers: {"Content-Type": "application/json"},
          body: iconData,
        );

        if (iconResponse.statusCode == 201) {
          final responseData = jsonDecode(iconResponse.body);
          categoryData['id_icon'] = responseData['id'];
        } else {
          _showErrorNotification("Erro ao criar categoria!");
          return;
        }
      } catch (e) {
        _showErrorNotification("Erro ao criar categoria!");
        return;
      }
    }

    final categoryUrl =
        isCreating
            ? Uri.parse('$apiUrl/categories')
            : Uri.parse('$apiUrl/categories/${widget.category!['id']}');

    try {
      final jsonData = jsonEncode(categoryData);

      final response =
          isCreating
              ? await http.post(
                categoryUrl,
                headers: {"Content-Type": "application/json"},
                body: jsonData,
              )
              : await http.put(
                categoryUrl,
                headers: {"Content-Type": "application/json"},
                body: jsonData,
              );

      if (response.statusCode == 201 || response.statusCode == 204) {
        final successMessage =
            isCreating
                ? "Categoria criada com sucesso!"
                : "Categoria atualizada com sucesso!";
        NotificationWidget.show(context, message: successMessage);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScreenWrapperScreen(selectedIndex: 2),
          ),
        );
      } else {
        _showErrorNotification("Erro ao salvar categoria!");
      }
    } catch (e) {
      _showErrorNotification("Erro ao salvar categoria!");
    }
  }

  void _showErrorNotification(String message) {
    NotificationWidget.show(context, message: message, isSuccess: false);
  }

  Future<void> _deleteCategory() async {
    try {
      final url = Uri.parse(
        '${dotenv.env['API_URL']}/categories/${widget.category!['id']}',
      );

      final response = await http.delete(
        url,
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 204) {
        String message = "Categoria removida com sucesso!";

        NotificationWidget.show(context, message: message);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScreenWrapperScreen(selectedIndex: 2),
          ),
        );
      } else {
        String message = "Erro ao remover categoria!";
        NotificationWidget.show(context, message: message, isSuccess: false);
      }
    } catch (e) {
      String message = "Erro ao remover categoria!";
      NotificationWidget.show(context, message: message, isSuccess: false);
    }
  }

  void handleSelection(String value) {
    setState(() {
      selectedValue = value;
      selectedIndex = null;
      iconId = null;
      selectedBase64Image = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            ScreenTitleWidget(
              title:
                  widget.category == null
                      ? 'Adicionar categoria'
                      : 'Detalhes da categoria',
              subtitle:
                  widget.category == null
                      ? 'Crie uma categoria para ter uma melhor categorização'
                      : 'Edite a sua categoria',
            ),
            const SizedBox(height: 18),
            InputWidget(
              controller: categoryNameController,
              labelText: 'Nome da categoria',
              hintText: 'Digite o nome da categoria',
            ),
            const SizedBox(height: 20),
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
            SizedBox(
              width: double.infinity,
              child: Text(
                "Selecione o ícone",
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'Poppins',
                  color: Colors.black,
                ),
                textAlign: TextAlign.start,
              ),
            ),
            const SizedBox(height: 12),
            Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: AppColors.cardBackgroundColor,
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  height: MediaQuery.of(context).size.height - 750,
                  child:
                      isLoading
                          ? Center(child: AnimatedSpinner())
                          : GridView.builder(
                            padding: EdgeInsets.all(0),
                            itemCount: filteredIcons.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 6,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 4,
                                  childAspectRatio: 1,
                                ),
                            itemBuilder: (context, index) {
                              final icon = filteredIcons[index];
                              final isSelected = selectedIndex == index;

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedIndex = index;
                                    iconId = icon['id'];
                                    selectedBase64Image = icon['icon'];
                                    isCustomImage = false;
                                  });
                                },
                                child: Center(
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
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            100,
                                          ),
                                          border: Border.all(
                                            color:
                                                isSelected
                                                    ? AppColors.primaryColor
                                                    : Colors.transparent,
                                            width: 3,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(3.0),
                                          child: Image.memory(
                                            base64Decode(icon['icon']),
                                            width: 30,
                                            height: 30,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            OrWidget(),
            const SizedBox(height: 14),
            ImagePickerWidget(onImagePicked: _handleImage),
            const SizedBox(height: 18),
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
                  CategoryWidget(
                    title: categoryNameController.text,
                    categoryType: selectedValue,
                    base64Image: selectedBase64Image!,
                  ),
                ],
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
      bottomNavigationBar:
          widget.category == null
              ? ButtonWidget(
                text: "Adicionar categoria",
                onPressed: () async {
                  await _handleCategory();
                },
              )
              : Column(
                mainAxisSize: MainAxisSize.min,

                children: [
                  ButtonWidget(
                    text: "Salvar",
                    onPressed: () async {
                      await _handleCategory();
                    },
                  ),
                  SizedBox(height: 10),
                  ButtonWidget(
                    text: "Excluir",
                    onPressed: () async {
                      await _deleteCategory();
                    },
                    isSecondaryOption: true,
                  ),
                ],
              ),
    );
  }
}
