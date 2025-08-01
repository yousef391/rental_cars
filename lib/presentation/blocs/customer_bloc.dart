import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rentra/domain/models/customer.dart';
import 'package:rentra/data/repositories/customer_repository.dart';

// Events
abstract class CustomerEvent extends Equatable {
  const CustomerEvent();

  @override
  List<Object?> get props => [];
}

class LoadCustomers extends CustomerEvent {}

class AddCustomer extends CustomerEvent {
  final String fullName;
  final String phoneNumber;
  final String emailAddress;
  final String driverLicenseNumber;
  final String address;
  final String? licenseCardImagePath;

  const AddCustomer({
    required this.fullName,
    required this.phoneNumber,
    required this.emailAddress,
    required this.driverLicenseNumber,
    required this.address,
    this.licenseCardImagePath,
  });

  @override
  List<Object?> get props => [
        fullName,
        phoneNumber,
        emailAddress,
        driverLicenseNumber,
        address,
        licenseCardImagePath,
      ];
}

class UpdateCustomer extends CustomerEvent {
  final Customer customer;

  const UpdateCustomer(this.customer);

  @override
  List<Object?> get props => [customer];
}

class DeleteCustomer extends CustomerEvent {
  final String id;

  const DeleteCustomer(this.id);

  @override
  List<Object?> get props => [id];
}

class SearchCustomers extends CustomerEvent {
  final String query;

  const SearchCustomers(this.query);

  @override
  List<Object?> get props => [query];
}

// States
abstract class CustomerState extends Equatable {
  const CustomerState();

  @override
  List<Object?> get props => [];
}

class CustomerInitial extends CustomerState {}

class CustomerLoading extends CustomerState {}

class CustomerLoaded extends CustomerState {
  final List<Customer> customers;
  final List<Customer> filteredCustomers;
  final String? searchQuery;

  const CustomerLoaded({
    required this.customers,
    required this.filteredCustomers,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [customers, filteredCustomers, searchQuery];

  CustomerLoaded copyWith({
    List<Customer>? customers,
    List<Customer>? filteredCustomers,
    String? searchQuery,
  }) {
    return CustomerLoaded(
      customers: customers ?? this.customers,
      filteredCustomers: filteredCustomers ?? this.filteredCustomers,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class CustomerError extends CustomerState {
  final String message;

  const CustomerError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final CustomerRepository customerRepository;

  CustomerBloc({required this.customerRepository}) : super(CustomerInitial()) {
    on<LoadCustomers>(_onLoadCustomers);
    on<AddCustomer>(_onAddCustomer);
    on<UpdateCustomer>(_onUpdateCustomer);
    on<DeleteCustomer>(_onDeleteCustomer);
    on<SearchCustomers>(_onSearchCustomers);
  }

  Future<void> _onLoadCustomers(
    LoadCustomers event,
    Emitter<CustomerState> emit,
  ) async {
    emit(CustomerLoading());
    try {
      await customerRepository.initialize();
      var customers = await customerRepository.getAllCustomers();

      // If no customers exist, create a test customer
      if (customers.isEmpty) {
        print('No customers found, creating test customer...');
        final testCustomer = Customer.create(
          fullName: 'Test Customer',
          phoneNumber: '+1234567890',
          emailAddress: 'test@example.com',
          driverLicenseNumber: 'DL123456789',
          address: '123 Test Street, Test City',
        );
        await customerRepository.saveCustomer(testCustomer);
        customers = await customerRepository.getAllCustomers();
        print('Created test customer, now have ${customers.length} customers');
      }

      print('Loaded ${customers.length} customers');
      emit(CustomerLoaded(customers: customers, filteredCustomers: customers));
    } catch (e) {
      print('Error loading customers: $e');
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> _onAddCustomer(
    AddCustomer event,
    Emitter<CustomerState> emit,
  ) async {
    try {
      final customer = Customer.create(
        fullName: event.fullName,
        phoneNumber: event.phoneNumber,
        emailAddress: event.emailAddress,
        driverLicenseNumber: event.driverLicenseNumber,
        address: event.address,
        licenseCardImagePath: event.licenseCardImagePath, // Added
      );

      await customerRepository.saveCustomer(customer);
      add(LoadCustomers());
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> _onUpdateCustomer(
    UpdateCustomer event,
    Emitter<CustomerState> emit,
  ) async {
    try {
      await customerRepository.saveCustomer(event.customer);
      add(LoadCustomers());
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> _onDeleteCustomer(
    DeleteCustomer event,
    Emitter<CustomerState> emit,
  ) async {
    try {
      await customerRepository.deleteCustomer(event.id);
      add(LoadCustomers());
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> _onSearchCustomers(
    SearchCustomers event,
    Emitter<CustomerState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is CustomerLoaded) {
        List<Customer> filteredCustomers = currentState.customers;

        if (event.query.isNotEmpty) {
          filteredCustomers = await customerRepository.searchCustomers(
            event.query,
          );
        }

        emit(
          currentState.copyWith(
            filteredCustomers: filteredCustomers,
            searchQuery: event.query.isEmpty ? null : event.query,
          ),
        );
      }
    } catch (e) {
      print('Error in search customers: $e');
      emit(CustomerError(e.toString()));
    }
  }
}
