import 'dart:convert';
import 'package:crud_api/models/inventory_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

class InventoryService {
  final String apiUrl = 'https://inventories.globeapp.dev/inventories';
  final Logger _logger = Logger('InventoryService');

  InventoryService() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      if (kDebugMode) {
        print('${record.level.name}: ${record.time}: ${record.message}');
      }
    });
  }

  Future<List<InventoryModel>> getInventories() async {
    _logger.info('Fetching inventories from API $apiUrl');
    _logger.info('curl -X GET "$apiUrl" -H "accept: application/json"');
    try {
      final response = await _getClient().get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        _logger.info('Fetched ${jsonResponse.length} inventories from API');
        return jsonResponse
            .map((data) => InventoryModel.fromJson(data))
            .toList();
      } else {
        _logger.severe(
            'Failed to load inventories from API: ${response.statusCode}');
        throw Exception('Failed to load inventories from API');
      }
    } catch (e) {
      _logger.severe('Error fetching inventories: $e');
      throw Exception('Error fetching inventories: $e');
    }
  }

  Future<InventoryModel> getInventory(String id) async {
    _logger.info('Fetching inventory $id from API $apiUrl');
    _logger.info('curl -X GET "$apiUrl/$id" -H "accept: application/json"');
    final response = await _getClient().get(Uri.parse('$apiUrl/$id'));

    if (response.statusCode == 200) {
      _logger.info('Fetched inventory $id from API');
      return InventoryModel.fromJson(json.decode(response.body));
    } else {
      _logger.severe('Failed to load inventory $id from API');
      throw Exception('Failed to load inventory from API');
    }
  }

  Future<InventoryModel> createInventory(InventoryModel inventory) async {
    _logger.info('Creating inventory from API $apiUrl');
    _logger.info(
        'curl -X POST "$apiUrl" -H "accept: application/json" -H "Content-Type: application/json" -d \'${jsonEncode(inventory.toJson())}\'');
    final response = await _getClient().post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(inventory.toJson()),
    );

    if (response.statusCode == 201) {
      _logger.info('Created inventory from API');
      return InventoryModel.fromJson(json.decode(response.body));
    } else {
      _logger.severe('Failed to create inventory from API');
      throw Exception('Failed to create inventory from API');
    }
  }

  Future<InventoryModel> updateInventory(
      String id, InventoryModel inventory) async {
    _logger.info('Updating inventory $id from API $apiUrl');
    _logger.info(
        'curl -X PUT "$apiUrl/$id" -H "accept: application/json" -H "Content-Type: application/json" -d \'${jsonEncode(inventory.toJson())}\'');
    final response = await _getClient().put(
      Uri.parse('$apiUrl/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(inventory.toJson()),
    );

    if (response.statusCode == 200) {
      _logger.info('Updated inventory $id from API');
      return InventoryModel.fromJson(json.decode(response.body));
    } else {
      _logger.severe('Failed to update inventory $id from API');
      throw Exception('Failed to update inventory from API');
    }
  }

  Future<void> deleteInventory(String id) async {
    _logger.info('Deleting inventory $id from API $apiUrl');
    final response = await _getClient().delete(Uri.parse('$apiUrl/$id'));

    if (response.statusCode != 204) {
      _logger.severe('Failed to delete inventory $id from API');
      throw Exception('Failed to delete inventory from API');
    }
  }

  http.Client _getClient() {
    return http.Client();
  }
}
