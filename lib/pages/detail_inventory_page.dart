import 'package:crud_api/utils/number_format_currency.dart';
import 'package:flutter/material.dart';
import 'package:crud_api/models/inventory_model.dart';
import 'package:crud_api/services/inventory_service.dart';

class DetailInventoryPage extends StatefulWidget {
  final String inventoryId;

  const DetailInventoryPage({super.key, required this.inventoryId});

  @override
  State<DetailInventoryPage> createState() => _DetailInventoryPageState();
}

class _DetailInventoryPageState extends State<DetailInventoryPage> {
  late Future<InventoryModel> _futureInventory;
  final InventoryService _inventoryService = InventoryService();

  @override
  void initState() {
    super.initState();
    _futureInventory = _inventoryService.getInventoryById(widget.inventoryId);
  }

  void backPage() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Details'),
        actions: [
          IconButton(
            onPressed: () {
              _inventoryService.deleteInventory(widget.inventoryId).then((_) {
                backPage();
              });
            },
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: FutureBuilder<InventoryModel>(
        future: _futureInventory,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(fontSize: 18, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _futureInventory = _inventoryService
                            .getInventoryById(widget.inventoryId);
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text('No data found'),
            );
          } else {
            final inventory = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    inventory.title ?? 'No Title',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Description: ${inventory.description ?? 'No Description'}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Price: ${NumberFormatCurrency.formatCurrencyIdr(inventory.price ?? 0)}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Quantity: ${inventory.quantity}',
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
