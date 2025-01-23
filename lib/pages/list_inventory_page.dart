import 'package:crud_api/models/inventory_model.dart';
import 'package:crud_api/services/inventory_service.dart';
import 'package:crud_api/utils/number_format_currency.dart';
import 'package:flutter/material.dart';

class ListInventoryPage extends StatefulWidget {
  const ListInventoryPage({super.key});

  @override
  State<ListInventoryPage> createState() => _ListInventoryPageState();
}

class _ListInventoryPageState extends State<ListInventoryPage> {
  final InventoryService _inventoryService = InventoryService();
  late Future<List<InventoryModel>> _futureInventory;

  @override
  void initState() {
    _futureInventory = _inventoryService.getInventories();
    super.initState();
  }

  Future<void> _refreshInventory() async {
    setState(() {
      _futureInventory = _inventoryService.getInventories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List Inventory'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshInventory,
        child: FutureBuilder<List<InventoryModel>>(
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
                      onPressed: _refreshInventory,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            } else {
              if (snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.inbox, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'No data found',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _refreshInventory,
                        child: const Text('Refresh'),
                      ),
                    ],
                  ),
                );
              } else {
                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final inventory = snapshot.data![index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16.0),
                        title: Text(
                          inventory.title ?? '',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Price: ${NumberFormatCurrency.formatCurrencyIdr(inventory.price!)}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              'Stock: ${inventory.quantity}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await _inventoryService
                                .deleteInventory(inventory.id!);
                            setState(() {
                              _futureInventory =
                                  _inventoryService.getInventories();
                            });
                          },
                        ),
                      ),
                    );
                  },
                );
              }
            }
          },
        ),
      ),
    );
  }
}
