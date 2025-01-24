import 'package:flutter/material.dart';
import 'package:crud_api/models/inventory_model.dart';
import 'package:crud_api/services/inventory_service.dart';
import 'package:crud_api/utils/number_format_currency.dart';
import 'package:flutter/services.dart';

class AddInventoryPage extends StatefulWidget {
  const AddInventoryPage({super.key});

  @override
  State<AddInventoryPage> createState() => _AddInventoryPageState();
}

class _AddInventoryPageState extends State<AddInventoryPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final InventoryService _inventoryService = InventoryService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
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

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      final newInventory = InventoryModel(
        title: _titleController.text,
        price: double.parse(
            _priceController.text.replaceAll(RegExp(r'[^0-9]'), '')),
        quantity: int.parse(_quantityController.text),
      );

      try {
        await _inventoryService.createInventory(newInventory);
        _inventoryService.getInventories();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Inventory added successfully')),
          );
          Navigator.pop(context);
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
        title: const Text('Add Inventory'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Stack(
            children: [
              ListView(
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
                    onPressed: _isLoading ? null : _submitForm,
                    child: const Text('Add Inventory'),
                  ),
                ],
              ),
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
