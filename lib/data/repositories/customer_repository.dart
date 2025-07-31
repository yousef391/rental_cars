import 'package:offline_rent_car/domain/models/customer.dart';
import 'package:offline_rent_car/data/services/storage_service.dart';

class CustomerRepository {
  final StorageService _storageService = StorageService();

  Future<void> initialize() async {
    await _storageService.initialize();
  }

  Future<List<Customer>> getAllCustomers() async {
    try {
      final customersData = await _storageService.loadAllCustomers();
      print('Repository: Loaded ${customersData.length} customer data files');
      final customers =
          customersData.map((data) => Customer.fromJson(data)).toList();
      print('Repository: Created ${customers.length} customer objects');
      return customers;
    } catch (e) {
      print('Error getting all customers: $e');
      return [];
    }
  }

  Future<Customer?> getCustomerById(String id) async {
    final customerData = await _storageService.loadCustomer(id);
    if (customerData != null) {
      return Customer.fromJson(customerData);
    }
    return null;
  }

  Future<void> saveCustomer(Customer customer) async {
    await _storageService.saveCustomer(customer.id, customer.toJson());
  }

  Future<void> deleteCustomer(String id) async {
    await _storageService.deleteCustomer(id);
  }

  Future<List<Customer>> searchCustomers(String query) async {
    try {
      final allCustomers = await getAllCustomers();
      final lowercaseQuery = query.toLowerCase();

      return allCustomers
          .where(
            (customer) =>
                customer.fullName.toLowerCase().contains(lowercaseQuery) ||
                customer.driverLicenseNumber.toLowerCase().contains(
                      lowercaseQuery,
                    ) ||
                customer.phoneNumber.contains(query) ||
                customer.emailAddress.toLowerCase().contains(lowercaseQuery),
          )
          .toList();
    } catch (e) {
      print('Error searching customers: $e');
      return [];
    }
  }
}
