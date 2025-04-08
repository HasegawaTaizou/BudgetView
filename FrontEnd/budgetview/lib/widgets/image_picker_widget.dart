import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:budgetview/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dotted_border/dotted_border.dart';

class ImagePickerWidget extends StatefulWidget {
  final Function(String) onImagePicked;

  const ImagePickerWidget({super.key, required this.onImagePicked});

  @override
  _ImagePickerWidgetState createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  final ImagePicker _picker = ImagePicker();
  File? _image;

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      File file = File(pickedFile.path);
      Uint8List imageBytes = await file.readAsBytes();
      String base64 = base64Encode(imageBytes);

      widget.onImagePicked(base64);

      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _image != null
            ? Container(
              padding: EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.cardBackgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              width: double.infinity,
              child: Center(
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    ClipOval(
                      child: Image.file(
                        _image!,
                        width: 110,
                        height: 110,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 5,
                      right: -4,
                      child: Container(
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.2),
                              blurRadius: 4,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          iconSize: 20,
                          icon: const Icon(
                            Icons.edit,
                            color: AppColors.primaryColor,
                          ),
                          onPressed: _pickImage,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            : GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 60,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                ),
                child: DottedBorder(
                  borderType: BorderType.RRect,
                  strokeWidth: 2,
                  dashPattern: [8],
                  radius: Radius.circular(50),
                  color: AppColors.primaryColor,
                  child: Center(
                    child: Text(
                      'Selecione a imagem',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ),
            ),
      ],
    );
  }
}
