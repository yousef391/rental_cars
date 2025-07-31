import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class StorageService {
  static const String _dataFolderName = 'rentcardata';
  static const String _vehiclesFolder = 'vehicles';
  static const String _customersFolder = 'customers';
  static const String _rentalsFolder = 'rentals';
  static const String _expensesFolder = 'expenses';

  late Directory _dataDirectory;
  late Directory _vehiclesDirectory;
  late Directory _customersDirectory;
  late Directory _rentalsDirectory;
  late Directory _expensesDirectory;

  Future<void> initialize() async {
    final appDataDir = await getApplicationSupportDirectory();
    _dataDirectory = Directory('${appDataDir.path}/$_dataFolderName');
    _vehiclesDirectory = Directory('${_dataDirectory.path}/$_vehiclesFolder');
    _customersDirectory = Directory('${_dataDirectory.path}/$_customersFolder');
    _rentalsDirectory = Directory('${_dataDirectory.path}/$_rentalsFolder');
    _expensesDirectory = Directory('${_dataDirectory.path}/$_expensesFolder');

    // Create directories if they don't exist
    await _dataDirectory.create(recursive: true);
    await _vehiclesDirectory.create(recursive: true);
    await _customersDirectory.create(recursive: true);
    await _rentalsDirectory.create(recursive: true);
    await _expensesDirectory.create(recursive: true);
  }

  // Vehicle storage methods
  Future<void> saveVehicle(String id, Map<String, dynamic> data) async {
    final file = File('${_vehiclesDirectory.path}/$id.json');
    await file.writeAsString(jsonEncode(data));
  }

  Future<Map<String, dynamic>?> loadVehicle(String id) async {
    final file = File('${_vehiclesDirectory.path}/$id.json');
    if (await file.exists()) {
      final content = await file.readAsString();
      return jsonDecode(content) as Map<String, dynamic>;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> loadAllVehicles() async {
    final List<Map<String, dynamic>> vehicles = [];
    final files = _vehiclesDirectory.listSync();

    for (final file in files) {
      if (file is File && file.path.endsWith('.json')) {
        final content = await file.readAsString();
        vehicles.add(jsonDecode(content) as Map<String, dynamic>);
      }
    }

    return vehicles;
  }

  Future<void> deleteVehicle(String id) async {
    final file = File('${_vehiclesDirectory.path}/$id.json');
    if (await file.exists()) {
      await file.delete();
    }
  }

  // Customer storage methods
  Future<void> saveCustomer(String id, Map<String, dynamic> data) async {
    final file = File('${_customersDirectory.path}/$id.json');
    await file.writeAsString(jsonEncode(data));
  }

  Future<Map<String, dynamic>?> loadCustomer(String id) async {
    final file = File('${_customersDirectory.path}/$id.json');
    if (await file.exists()) {
      final content = await file.readAsString();
      return jsonDecode(content) as Map<String, dynamic>;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> loadAllCustomers() async {
    final List<Map<String, dynamic>> customers = [];

    try {
      if (!await _customersDirectory.exists()) {
        print('Storage: Customers directory does not exist, creating...');
        await _customersDirectory.create(recursive: true);
        print('Storage: Created customers directory');
        return customers;
      }

      final files = _customersDirectory.listSync();
      print('Storage: Found ${files.length} files in customers directory');

      for (final file in files) {
        if (file is File && file.path.endsWith('.json')) {
          try {
            final content = await file.readAsString();
            final decoded = jsonDecode(content) as Map<String, dynamic>;
            customers.add(decoded);
            print('Storage: Successfully loaded customer file: ${file.path}');
          } catch (e) {
            print('Error reading customer file ${file.path}: $e');
            // Continue with other files
          }
        }
      }
      print('Storage: Successfully loaded ${customers.length} customer files');
    } catch (e) {
      print('Error loading customers: $e');
    }

    return customers;
  }

  Future<void> deleteCustomer(String id) async {
    final file = File('${_customersDirectory.path}/$id.json');
    if (await file.exists()) {
      await file.delete();
    }
  }

  // Rental storage methods
  Future<void> saveRental(String id, Map<String, dynamic> data) async {
    final file = File('${_rentalsDirectory.path}/$id.json');
    await file.writeAsString(jsonEncode(data));
  }

  Future<Map<String, dynamic>?> loadRental(String id) async {
    final file = File('${_rentalsDirectory.path}/$id.json');
    if (await file.exists()) {
      final content = await file.readAsString();
      return jsonDecode(content) as Map<String, dynamic>;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> loadAllRentals() async {
    final List<Map<String, dynamic>> rentals = [];
    final files = _rentalsDirectory.listSync();

    for (final file in files) {
      if (file is File && file.path.endsWith('.json')) {
        final content = await file.readAsString();
        rentals.add(jsonDecode(content) as Map<String, dynamic>);
      }
    }

    return rentals;
  }

  Future<void> deleteRental(String id) async {
    final file = File('${_rentalsDirectory.path}/$id.json');
    if (await file.exists()) {
      await file.delete();
    }
  }

  // Expense storage methods
  Future<void> saveExpense(String id, Map<String, dynamic> data) async {
    final file = File('${_expensesDirectory.path}/$id.json');
    await file.writeAsString(jsonEncode(data));
  }

  Future<Map<String, dynamic>?> loadExpense(String id) async {
    final file = File('${_expensesDirectory.path}/$id.json');
    if (await file.exists()) {
      final content = await file.readAsString();
      return jsonDecode(content) as Map<String, dynamic>;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> loadAllExpenses() async {
    final List<Map<String, dynamic>> expenses = [];
    final files = _expensesDirectory.listSync();

    for (final file in files) {
      if (file is File && file.path.endsWith('.json')) {
        final content = await file.readAsString();
        expenses.add(jsonDecode(content) as Map<String, dynamic>);
      }
    }

    return expenses;
  }

  Future<void> deleteExpense(String id) async {
    final file = File('${_expensesDirectory.path}/$id.json');
    if (await file.exists()) {
      await file.delete();
    }
  }

  // Generic file methods
  Future<String?> readFile(String fileName) async {
    final file = File('${_dataDirectory.path}/$fileName');
    print('🔍 StorageService - Reading file: ${file.path}');
    if (await file.exists()) {
      final content = await file.readAsString();
      print('🔍 StorageService - File content: $content');
      return content;
    }
    print('🔍 StorageService - File does not exist: ${file.path}');
    return null;
  }

  Future<void> writeFile(String fileName, String content) async {
    final file = File('${_dataDirectory.path}/$fileName');
    print('🔍 StorageService - Writing file: ${file.path}');
    print('🔍 StorageService - Content to write: $content');
    await file.writeAsString(content);
    print('✅ StorageService - File written successfully');
  }

  Future<void> deleteFile(String fileName) async {
    final file = File('${_dataDirectory.path}/$fileName');
    if (await file.exists()) {
      await file.delete();
    }
  }

  // Utility methods
  String getDataPath() {
    return _dataDirectory.path;
  }

  Future<void> clearAllData() async {
    if (await _dataDirectory.exists()) {
      await _dataDirectory.delete(recursive: true);
    }
    await initialize();
  }
}
