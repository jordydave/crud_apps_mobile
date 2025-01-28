import 'dart:io';
import 'package:crud_api/models/inventory_model.dart';
import 'package:crud_api/pages/list_inventory_page.dart';
import 'package:crud_api/services/inventory_service.dart';
import 'package:crud_api/utils/app_utils.dart';
import 'package:crud_api/utils/number_format_currency.dart';
import 'package:crud_api/widgets/shared_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:ui';

class EditInventoryPage extends StatefulWidget {
  final String inventoryId;

  const EditInventoryPage({super.key, required this.inventoryId});

  @override
  State<EditInventoryPage> createState() => _EditInventoryPageState();
}

class _EditInventoryPageState extends State<EditInventoryPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final InventoryService _inventoryService = InventoryService();
  bool _isLoading = false;
  File? _image;
  InventoryModel? _inventory;

  @override
  void initState() {
    super.initState();
    _fetchInventoryDetails();
    _priceController.addListener(_formatPrice);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _formatPrice() {
    final currentText = _priceController.text;
    final cursorPosition = _priceController.selection.base.offset;

    String numericText = currentText.replaceAll(RegExp(r'[^0-9]'), '');

    if (numericText.isEmpty) {
      _priceController.value = TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
      return;
    }

    final double parsedValue = double.parse(numericText);
    final formattedText = NumberFormatCurrency.formatCurrencyIdr(parsedValue);

    int newCursorPosition =
        cursorPosition + (formattedText.length - currentText.length);

    if (formattedText != currentText) {
      _priceController.value = TextEditingValue(
        text: formattedText,
        selection: TextSelection.collapsed(
          offset: newCursorPosition.clamp(0, formattedText.length),
        ),
      );
    }
  }

  Future<void> _fetchInventoryDetails() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final inventory =
          await _inventoryService.getInventoryById(widget.inventoryId);
      setState(() {
        _inventory = inventory;
        _titleController.text = inventory.title ?? '';
        _priceController.text =
            NumberFormatCurrency.formatCurrencyIdr(inventory.price ?? 0);
        _quantityController.text = inventory.quantity.toString();
      });
    } catch (e) {
      if (mounted) {
        AppUtils.showSnackBar(context, 'Error: $e');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
      setState(() {
        _isLoading = true;
      });

      String? imageUrl = _inventory?.imageUrl;
      if (_image != null) {
        imageUrl = await _inventoryService.uploadImageToGitHub(_image!);
      }

      final updatedInventory = InventoryModel(
        id: _inventory?.id,
        title: _titleController.text,
        price: double.parse(
            _priceController.text.replaceAll(RegExp(r'[^0-9]'), '')),
        quantity: int.parse(_quantityController.text),
        imageUrl: imageUrl,
      );

      try {
        await _inventoryService.updateInventory(
            widget.inventoryId, updatedInventory);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Inventory updated successfully')),
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const ListInventoryPage()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Inventory'),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(labelText: 'Price'),
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
                  TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(labelText: 'Quantity'),
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
                      child: Image.file(_image!),
                    )
                  else if (_inventory?.imageUrl != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Image.network(_inventory!.imageUrl!),
                    ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    child: const Text('Update Inventory'),
                  ),
                ],
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
