import 'package:crud_api/pages/edit_inventory_page.dart';
import 'package:crud_api/pages/list_inventory_page.dart';
import 'package:crud_api/utils/app_utils.dart';
import 'package:crud_api/utils/number_format_currency.dart';
import 'package:crud_api/widgets/shared_loading.dart';
import 'package:flutter/material.dart';
import 'package:crud_api/models/inventory_model.dart';
import 'package:crud_api/services/inventory_service.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'dart:ui';

class DetailInventoryPage extends StatefulWidget {
  final String inventoryId;

  const DetailInventoryPage({super.key, required this.inventoryId});

  @override
  State<DetailInventoryPage> createState() => _DetailInventoryPageState();
}

class _DetailInventoryPageState extends State<DetailInventoryPage> {
  late Future<InventoryModel> _futureInventory;
  final InventoryService _inventoryService = InventoryService();
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _futureInventory = _inventoryService.getInventoryById(widget.inventoryId);
  }

  void backToHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const ListInventoryPage()),
      (route) => false,
    );
  }

  Future<void> _deleteInventory() async {
    setState(() {
      _isDeleting = true;
    });
    try {
      await _inventoryService.deleteInventory(widget.inventoryId);
      backToHome();
    } catch (e) {
      _showSnackBar('Failed to delete inventory: $e');
    } finally {
      setState(() {
        _isDeleting = false;
      });
    }
  }

  void _showSnackBar(String message) {
    AppUtils.showSnackBar(context, message);
  }

  Widget _buildLoading() {
    return SharedLoading(
      color: Colors.white,
      indincatorColor: Colors.black,
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, color: Colors.red, size: 64),
          const SizedBox(height: 16),
          Text(
            'Error: $error',
            style: const TextStyle(fontSize: 18, color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _futureInventory =
                    _inventoryService.getInventoryById(widget.inventoryId);
              });
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryDetails(InventoryModel inventory) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Skeletonizer(
        enabled: _isDeleting,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              inventory.title ?? 'No Title',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
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
            const SizedBox(height: 16),
            Center(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Image.network(
                  inventory.imageUrl ?? '',
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Text('Image not found'),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory Details'),
        actions: [
          IconButton(
            onPressed: _isDeleting ? null : _deleteInventory,
            icon: const Icon(Icons.delete),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) {
                return EditInventoryPage(inventoryId: widget.inventoryId);
              }));
            },
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: Stack(
        children: [
          FutureBuilder<InventoryModel>(
            future: _futureInventory,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildLoading();
              } else if (snapshot.hasError) {
                return _buildError(snapshot.error.toString());
              } else if (!snapshot.hasData || snapshot.data == null) {
                return const Center(
                  child: Text('No data found'),
                );
              } else {
                return _buildInventoryDetails(snapshot.data!);
              }
            },
          ),
          if (_isDeleting)
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
