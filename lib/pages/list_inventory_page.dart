import 'package:crud_api/models/inventory_model.dart';
import 'package:crud_api/pages/add_inventory_page.dart';
import 'package:crud_api/pages/detail_inventory_page.dart';
import 'package:crud_api/services/inventory_service.dart';
import 'package:crud_api/utils/number_format_currency.dart';
import 'package:crud_api/widgets/shared_shimmer_list.dart';
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
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) {
            return const AddInventoryPage();
          }));
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      appBar: AppBar(
        title: const Text('List Inventory'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              onChanged: _updateSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: const TextStyle(color: Colors.white),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.white,
                ),
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
              return SharedShimmerList();
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
                return ListView.builder(
                  itemCount: filteredInventory.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.grey,
                              blurRadius: 2.0,
                              spreadRadius: 0.0,
                              offset: Offset(2.0, 2.0),
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              filteredInventory[index].imageUrl ?? '',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.error,
                                  color: Colors.grey,
                                  size: 48,
                                );
                              },
                            ),
                          ),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                filteredInventory[index].title!,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text("ID: ${filteredInventory[index].id!}"),
                              const SizedBox(height: 10),
                            ],
                          ),
                          subtitle: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Stock: ${filteredInventory[index].quantity}',
                                style: const TextStyle(fontSize: 16),
                              ),
                              Text(
                                NumberFormatCurrency.formatCurrencyIdr(
                                    filteredInventory[index].price!),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (_) {
                              return DetailInventoryPage(
                                inventoryId: filteredInventory[index].id!,
                              );
                            }));
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
