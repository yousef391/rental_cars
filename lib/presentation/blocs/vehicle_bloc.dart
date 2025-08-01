import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rentra/domain/models/vehicle.dart';
import 'package:rentra/data/repositories/vehicle_repository.dart';

// Events
abstract class VehicleEvent extends Equatable {
  const VehicleEvent();

  @override
  List<Object?> get props => [];
}

class LoadVehicles extends VehicleEvent {}

class AddVehicle extends VehicleEvent {
  final String make;
  final String model;
  final int year;
  final String licensePlate;
  final String color;
  final double dailyRentalRate;
  final int currentMileage;
  final String? carImagePath;

  const AddVehicle({
    required this.make,
    required this.model,
    required this.year,
    required this.licensePlate,
    required this.color,
    required this.dailyRentalRate,
    this.currentMileage = 0,
    this.carImagePath,
  });

  @override
  List<Object?> get props => [
        make,
        model,
        year,
        licensePlate,
        color,
        dailyRentalRate,
        currentMileage,
        carImagePath,
      ];
}

class UpdateVehicle extends VehicleEvent {
  final Vehicle vehicle;

  const UpdateVehicle(this.vehicle);

  @override
  List<Object?> get props => [vehicle];
}

class DeleteVehicle extends VehicleEvent {
  final String id;

  const DeleteVehicle(this.id);

  @override
  List<Object?> get props => [id];
}

class SearchVehicles extends VehicleEvent {
  final String query;

  const SearchVehicles(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterVehiclesByStatus extends VehicleEvent {
  final VehicleStatus? status;

  const FilterVehiclesByStatus(this.status);

  @override
  List<Object?> get props => [status];
}

class AddMaintenanceRecord extends VehicleEvent {
  final String vehicleId;
  final String type;
  final DateTime dateOfService;
  final DateTime? nextDueDate;
  final String notes;

  const AddMaintenanceRecord({
    required this.vehicleId,
    required this.type,
    required this.dateOfService,
    this.nextDueDate,
    required this.notes,
  });

  @override
  List<Object?> get props => [
        vehicleId,
        type,
        dateOfService,
        nextDueDate,
        notes,
      ];
}

// States
abstract class VehicleState extends Equatable {
  const VehicleState();

  @override
  List<Object?> get props => [];
}

class VehicleInitial extends VehicleState {}

class VehicleLoading extends VehicleState {}

class VehicleLoaded extends VehicleState {
  final List<Vehicle> vehicles;
  final List<Vehicle> filteredVehicles;
  final String? searchQuery;
  final VehicleStatus? statusFilter;

  const VehicleLoaded({
    required this.vehicles,
    required this.filteredVehicles,
    this.searchQuery,
    this.statusFilter,
  });

  @override
  List<Object?> get props => [
        vehicles,
        filteredVehicles,
        searchQuery,
        statusFilter,
      ];

  VehicleLoaded copyWith({
    List<Vehicle>? vehicles,
    List<Vehicle>? filteredVehicles,
    String? searchQuery,
    VehicleStatus? statusFilter,
  }) {
    return VehicleLoaded(
      vehicles: vehicles ?? this.vehicles,
      filteredVehicles: filteredVehicles ?? this.filteredVehicles,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
    );
  }
}

class VehicleError extends VehicleState {
  final String message;

  const VehicleError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class VehicleBloc extends Bloc<VehicleEvent, VehicleState> {
  final VehicleRepository vehicleRepository;

  VehicleBloc({required this.vehicleRepository}) : super(VehicleInitial()) {
    on<LoadVehicles>(_onLoadVehicles);
    on<AddVehicle>(_onAddVehicle);
    on<UpdateVehicle>(_onUpdateVehicle);
    on<DeleteVehicle>(_onDeleteVehicle);
    on<SearchVehicles>(_onSearchVehicles);
    on<FilterVehiclesByStatus>(_onFilterVehiclesByStatus);
    on<AddMaintenanceRecord>(_onAddMaintenanceRecord);
  }

  Future<void> _onLoadVehicles(
    LoadVehicles event,
    Emitter<VehicleState> emit,
  ) async {
    emit(VehicleLoading());
    try {
      await vehicleRepository.initialize();
      final vehicles = await vehicleRepository.getAllVehicles();
      emit(VehicleLoaded(vehicles: vehicles, filteredVehicles: vehicles));
    } catch (e) {
      emit(VehicleError(e.toString()));
    }
  }

  Future<void> _onAddVehicle(
    AddVehicle event,
    Emitter<VehicleState> emit,
  ) async {
    try {
      final vehicle = Vehicle.create(
        make: event.make,
        model: event.model,
        year: event.year,
        licensePlate: event.licensePlate,
        color: event.color,
        dailyRentalRate: event.dailyRentalRate,
        carImagePath: event.carImagePath, // Added
      ).copyWith(currentMileage: event.currentMileage);

      await vehicleRepository.saveVehicle(vehicle);
      add(LoadVehicles());
    } catch (e) {
      emit(VehicleError(e.toString()));
    }
  }

  Future<void> _onUpdateVehicle(
    UpdateVehicle event,
    Emitter<VehicleState> emit,
  ) async {
    try {
      await vehicleRepository.saveVehicle(event.vehicle);
      add(LoadVehicles());
    } catch (e) {
      emit(VehicleError(e.toString()));
    }
  }

  Future<void> _onDeleteVehicle(
    DeleteVehicle event,
    Emitter<VehicleState> emit,
  ) async {
    try {
      await vehicleRepository.deleteVehicle(event.id);
      add(LoadVehicles());
    } catch (e) {
      emit(VehicleError(e.toString()));
    }
  }

  Future<void> _onSearchVehicles(
    SearchVehicles event,
    Emitter<VehicleState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is VehicleLoaded) {
        List<Vehicle> filteredVehicles = currentState.vehicles;

        if (event.query.isNotEmpty) {
          filteredVehicles = await vehicleRepository.searchVehicles(
            event.query,
          );
        }

        if (currentState.statusFilter != null) {
          filteredVehicles = filteredVehicles
              .where((v) => v.status == currentState.statusFilter)
              .toList();
        }

        emit(
          currentState.copyWith(
            filteredVehicles: filteredVehicles,
            searchQuery: event.query.isEmpty ? null : event.query,
          ),
        );
      }
    } catch (e) {
      emit(VehicleError(e.toString()));
    }
  }

  Future<void> _onFilterVehiclesByStatus(
    FilterVehiclesByStatus event,
    Emitter<VehicleState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is VehicleLoaded) {
        List<Vehicle> filteredVehicles = currentState.vehicles;

        if (event.status != null) {
          filteredVehicles = await vehicleRepository.getVehiclesByStatus(
            event.status!,
          );
        }

        if (currentState.searchQuery != null &&
            currentState.searchQuery!.isNotEmpty) {
          filteredVehicles = filteredVehicles
              .where(
                (v) =>
                    v.make.toLowerCase().contains(
                          currentState.searchQuery!.toLowerCase(),
                        ) ||
                    v.model.toLowerCase().contains(
                          currentState.searchQuery!.toLowerCase(),
                        ) ||
                    v.licensePlate.toLowerCase().contains(
                          currentState.searchQuery!.toLowerCase(),
                        ),
              )
              .toList();
        }

        emit(
          currentState.copyWith(
            filteredVehicles: filteredVehicles,
            statusFilter: event.status,
          ),
        );
      }
    } catch (e) {
      emit(VehicleError(e.toString()));
    }
  }

  Future<void> _onAddMaintenanceRecord(
    AddMaintenanceRecord event,
    Emitter<VehicleState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is VehicleLoaded) {
        final vehicle = currentState.vehicles.firstWhere(
          (v) => v.id == event.vehicleId,
        );
        final maintenanceRecord = MaintenanceRecord.create(
          type: event.type,
          dateOfService: event.dateOfService,
          nextDueDate: event.nextDueDate,
          notes: event.notes,
        );

        final updatedVehicle = vehicle.addMaintenanceRecord(maintenanceRecord);
        await vehicleRepository.saveVehicle(updatedVehicle);
        add(LoadVehicles());
      }
    } catch (e) {
      emit(VehicleError(e.toString()));
    }
  }
}
