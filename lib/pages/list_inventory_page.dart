import 'package:crud_api/models/inventory_model.dart';
import 'package:crud_api/pages/add_inventory_page.dart';
import 'package:crud_api/pages/detail_inventory_page.dart';
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
  String _searchQuery = '';

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

  void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  List<InventoryModel> _filterInventory(List<InventoryModel> inventory) {
    if (_searchQuery.isEmpty) {
      return inventory;
    }
    return inventory
        .where((item) =>
            item.title!.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) {
            return const AddInventoryPage();
          }));
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text('List Inventory'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _updateSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
        ),
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
              final filteredInventory = _filterInventory(snapshot.data!);
              if (filteredInventory.isEmpty) {
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
                return GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 3 / 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  itemCount: filteredInventory.length,
                  itemBuilder: (context, index) {
                    final inventory = filteredInventory[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) {
                          return DetailInventoryPage(
                            inventoryId: inventory.id!,
                          );
                        }));
                      },
                      child: Card(
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
