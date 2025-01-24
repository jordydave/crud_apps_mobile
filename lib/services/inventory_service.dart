import 'dart:convert';
import 'package:crud_api/models/inventory_model.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

class InventoryService {
  final String apiUrl = 'https://inventories-ifxqr3l-jordy-dave.globeapp.dev';
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
    String getInventories = '$apiUrl/getInventories';
    _logger.info('Fetching inventories from API $getInventories');
    _logger.info('curl -X GET "$apiUrl" -H "accept: application/json"');
    try {
      final response = await _getClient().get(Uri.parse(getInventories));

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        _logger.info('Fetched ${jsonResponse.length} inventories from API');
        return jsonResponse
            .map(
                (data) => InventoryModel.fromJson(data as Map<String, dynamic>))
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

  Future<InventoryModel> getInventoryById(String recordId) async {
    String getInventory = '$apiUrl/getInventoryById?recordId=$recordId';
    _logger.info('Fetching inventory $recordId from API $getInventory');
    _logger
        .info('curl -X GET "$apiUrl/$recordId" -H "accept: application/json"');
    final response =
        await _getClient().get(Uri.parse(getInventory));

    if (response.statusCode == 200) {
      _logger.info('Fetched inventory $recordId from API');
      return InventoryModel.fromJson(json.decode(response.body));
    } else {
      _logger.severe('Failed to load inventory $recordId from API');
      throw Exception('Failed to load inventory from API');
    }
  }

  Future<InventoryModel> createInventory(InventoryModel inventory) async {
    String createInventory = '$apiUrl/createInventory';
    _logger.info('Creating inventory from API $createInventory');
    _logger.info(
        'curl -X POST "$createInventory" -H "accept: application/json" -H "Content-Type: application/json" -d \'${jsonEncode(inventory.toJson())}\'');
    final response = await _getClient().post(
      Uri.parse(createInventory),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(inventory.toJson()),
    );

    if (response.statusCode == 200) {
      _logger.info('Created inventory from API');
      return InventoryModel.fromJson(json.decode(response.body));
    } else {
      _logger.severe('Failed to create inventory from API');
      throw Exception('Failed to create inventory from API');
    }
  }

  Future<InventoryModel> updateInventory(
      String recordId, InventoryModel inventory) async {
    String updateInventory = '$apiUrl/updateInventory';
    _logger.info('Updating inventory $recordId from API $updateInventory');
    _logger.info(
        'curl -X PUT "$apiUrl/$recordId" -H "accept: application/json" -H "Content-Type: application/json" -d \'${jsonEncode(inventory.toJson())}\'');
    final response = await _getClient().put(
      Uri.parse('$updateInventory/$recordId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(inventory.toJson()),
    );

    if (response.statusCode == 200) {
      _logger.info('Updated inventory $recordId from API');
      return InventoryModel.fromJson(json.decode(response.body));
    } else {
      _logger.severe('Failed to update inventory $recordId from API');
      throw Exception('Failed to update inventory from API');
    }
  }

  Future<void> deleteInventory(String recordId) async {
    String deleteInventory = '$apiUrl/deleteInventory';
    _logger.info('Deleting inventory $recordId from API $deleteInventory');
    final response = await _getClient().delete(
      Uri.parse('$deleteInventory?recordId=$recordId'),
    );

    _logger.info('Response status: ${response.statusCode}');
    _logger.info('Response body: ${response.body}');

    if (response.statusCode == 200) {
      _logger.info('Deleted inventory $recordId from API');
    } else {
      _logger.severe('Failed to delete inventory $recordId from API');
      throw Exception('Failed to delete inventory from API');
    }
  }

  http.Client _getClient() {
    return http.Client();
  }
}
