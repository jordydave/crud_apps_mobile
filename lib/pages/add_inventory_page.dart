import 'dart:io';
import 'package:crud_api/pages/list_inventory_page.dart';
import 'package:crud_api/utils/app_utils.dart';
import 'package:crud_api/utils/formatter_price.dart';
import 'package:crud_api/widgets/shared_loading.dart';
import 'package:crud_api/widgets/shared_textformfield.dart';
import 'package:flutter/material.dart';
import 'package:crud_api/models/inventory_model.dart';
import 'package:crud_api/services/inventory_service.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:ui';

import 'package:skeletonizer/skeletonizer.dart';

class AddInventoryPage extends StatefulWidget {
  const AddInventoryPage({super.key});

  @override
  State<AddInventoryPage> createState() => _AddInventoryPageState();
}

class _AddInventoryPageState extends State<AddInventoryPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final InventoryService _inventoryService = InventoryService();
  bool _isLoading = false;
  File? _image;

  @override
  void initState() {
    super.initState();
    _priceController.addListener(() => formatterPrice(_priceController));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_image == null) {
        _showSnackBar('Please pick an image');
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final imageUrl = await _uploadImage();
        final newInventory = _createInventoryModel(imageUrl);
        await _inventoryService.createInventory(newInventory);
        _showSnackBar('Inventory added successfully');
        _navigateToListInventoryPage();
      } catch (e) {
        _showSnackBar('Error: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<String?> _uploadImage() async {
    if (_image != null) {
      return await _inventoryService.uploadImageToGitHub(_image!);
    }
    return null;
  }

  InventoryModel _createInventoryModel(String? imageUrl) {
    return InventoryModel(
      title: _titleController.text,
      description: _descriptionController.text,
      price:
          double.parse(_priceController.text.replaceAll(RegExp(r'[^0-9]'), '')),
      quantity: int.parse(_quantityController.text),
      imageUrl: imageUrl,
    );
  }

  void _showSnackBar(String message) {
    AppUtils.showSnackBar(context, message);
  }

  void _navigateToListInventoryPage() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const ListInventoryPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Inventory'),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Skeletonizer(
                enabled: _isLoading,
                child: ListView(
                  children: [
                    SharedTextFormField(
                      controller: _titleController,
                      labelText: 'Title',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    SharedTextFormField(
                      controller: _descriptionController,
                      labelText: 'Description',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    SharedTextFormField(
                      controller: _priceController,
                      labelText: 'Price',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a price';
                        }
                        if (double.tryParse(
                                value.replaceAll(RegExp(r'[^0-9]'), '')) ==
                            null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    SharedTextFormField(
                      controller: _quantityController,
                      labelText: 'Quantity',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a quantity';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: const Text('Pick Image'),
                    ),
                    if (_image != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.file(_image!),
                        ),
                      ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      child: const Text('Add Inventory'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: SharedLoading(
                indincatorColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}
