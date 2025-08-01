import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rentra/domain/models/rental.dart';
import 'package:rentra/domain/models/vehicle.dart';
import 'package:rentra/data/repositories/rental_repository.dart';
import 'package:rentra/data/repositories/vehicle_repository.dart';
import 'package:rentra/data/services/notification_service.dart';

// Events
abstract class RentalEvent extends Equatable {
  const RentalEvent();

  @override
  List<Object?> get props => [];
}

class LoadRentals extends RentalEvent {}

class AddRental extends RentalEvent {
  final String vehicleId;
  final String customerId;
  final DateTime startDate;
  final DateTime endDate;
  final double totalCost;
  final double securityDeposit;
  final int? startMileage;
  final PaymentStatus paymentStatus;
  final double initialPayment;

  const AddRental({
    required this.vehicleId,
    required this.customerId,
    required this.startDate,
    required this.endDate,
    required this.totalCost,
    required this.securityDeposit,
    this.startMileage,
    this.paymentStatus = PaymentStatus.pending,
    this.initialPayment = 0.0,
  });

  @override
  List<Object?> get props => [
        vehicleId,
        customerId,
        startDate,
        endDate,
        totalCost,
        securityDeposit,
        startMileage,
        paymentStatus,
        initialPayment,
      ];
}

class UpdateRental extends RentalEvent {
  final Rental rental;

  const UpdateRental(this.rental);

  @override
  List<Object?> get props => [rental];
}

class DeleteRental extends RentalEvent {
  final String id;

  const DeleteRental(this.id);

  @override
  List<Object?> get props => [id];
}

class CompleteRental extends RentalEvent {
  final String id;

  const CompleteRental(this.id);

  @override
  List<Object?> get props => [id];
}

class FilterRentalsByStatus extends RentalEvent {
  final RentalStatus? status;

  const FilterRentalsByStatus(this.status);

  @override
  List<Object?> get props => [status];
}

class UpdateRentalPayment extends RentalEvent {
  final String rentalId;
  final double paymentAmount;

  const UpdateRentalPayment({
    required this.rentalId,
    required this.paymentAmount,
  });

  @override
  List<Object?> get props => [rentalId, paymentAmount];
}

class UpdateRentalMileage extends RentalEvent {
  final String rentalId;
  final int? startMileage;
  final int? endMileage;

  const UpdateRentalMileage({
    required this.rentalId,
    this.startMileage,
    this.endMileage,
  });

  @override
  List<Object?> get props => [rentalId, startMileage, endMileage];
}

class CompleteRentalWithMileage extends RentalEvent {
  final String rentalId;
  final int endMileage;
  final double? finalCost;

  const CompleteRentalWithMileage({
    required this.rentalId,
    required this.endMileage,
    this.finalCost,
  });

  @override
  List<Object?> get props => [rentalId, endMileage, finalCost];
}

// States
abstract class RentalState extends Equatable {
  const RentalState();

  @override
  List<Object?> get props => [];
}

class RentalInitial extends RentalState {}

class RentalLoading extends RentalState {}

class RentalLoaded extends RentalState {
  final List<Rental> rentals;
  final List<Rental> filteredRentals;
  final RentalStatus? statusFilter;

  const RentalLoaded({
    required this.rentals,
    required this.filteredRentals,
    this.statusFilter,
  });

  @override
  List<Object?> get props => [rentals, filteredRentals, statusFilter];

  RentalLoaded copyWith({
    List<Rental>? rentals,
    List<Rental>? filteredRentals,
    RentalStatus? statusFilter,
  }) {
    return RentalLoaded(
      rentals: rentals ?? this.rentals,
      filteredRentals: filteredRentals ?? this.filteredRentals,
      statusFilter: statusFilter ?? this.statusFilter,
    );
  }
}

class RentalError extends RentalState {
  final String message;

  const RentalError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class RentalBloc extends Bloc<RentalEvent, RentalState> {
  final RentalRepository rentalRepository;
  final VehicleRepository vehicleRepository;
  final NotificationService _notificationService = NotificationService();

  RentalBloc({required this.rentalRepository, required this.vehicleRepository})
      : super(RentalInitial()) {
    on<LoadRentals>(_onLoadRentals);
    on<AddRental>(_onAddRental);
    on<UpdateRental>(_onUpdateRental);
    on<DeleteRental>(_onDeleteRental);
    on<CompleteRental>(_onCompleteRental);
    on<FilterRentalsByStatus>(_onFilterRentalsByStatus);
    on<UpdateRentalPayment>(_onUpdateRentalPayment);
    on<UpdateRentalMileage>(_onUpdateRentalMileage);
    on<CompleteRentalWithMileage>(_onCompleteRentalWithMileage);
  }

  Future<void> _onLoadRentals(
    LoadRentals event,
    Emitter<RentalState> emit,
  ) async {
    emit(RentalLoading());
    try {
      await rentalRepository.initialize();
      final rentals = await rentalRepository.getAllRentals();
      emit(RentalLoaded(rentals: rentals, filteredRentals: rentals));
    } catch (e) {
      emit(RentalError(e.toString()));
    }
  }

  Future<void> _onAddRental(AddRental event, Emitter<RentalState> emit) async {
    try {
      final rental = Rental.create(
        vehicleId: event.vehicleId,
        customerId: event.customerId,
        startDate: event.startDate,
        endDate: event.endDate,
        totalCost: event.totalCost,
        securityDeposit: event.securityDeposit,
        startMileage: event.startMileage,
      ).copyWith(
        paymentStatus: event.paymentStatus,
        amountPaid: event.initialPayment,
      );

      await rentalRepository.saveRental(rental);

      // Schedule rental reminders
      await _notificationService.scheduleRentalReminders(rental);

      // Update vehicle status to rented
      final vehicle = await vehicleRepository.getVehicleById(event.vehicleId);
      if (vehicle != null) {
        final updatedVehicle = vehicle.copyWith(status: VehicleStatus.rented);
        await vehicleRepository.saveVehicle(updatedVehicle);
      }

      add(LoadRentals());
    } catch (e) {
      emit(RentalError(e.toString()));
    }
  }

  Future<void> _onUpdateRental(
    UpdateRental event,
    Emitter<RentalState> emit,
  ) async {
    try {
      await rentalRepository.saveRental(event.rental);
      add(LoadRentals());
    } catch (e) {
      emit(RentalError(e.toString()));
    }
  }

  Future<void> _onDeleteRental(
    DeleteRental event,
    Emitter<RentalState> emit,
  ) async {
    try {
      // Cancel rental reminders before deleting
      await _notificationService.cancelRentalReminders(event.id);

      await rentalRepository.deleteRental(event.id);
      add(LoadRentals());
    } catch (e) {
      emit(RentalError(e.toString()));
    }
  }

  Future<void> _onCompleteRental(
    CompleteRental event,
    Emitter<RentalState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is RentalLoaded) {
        final rental = currentState.rentals.firstWhere((r) => r.id == event.id);
        final completedRental = rental.markAsCompleted();

        await rentalRepository.saveRental(completedRental);

        // Cancel rental reminders
        await _notificationService.cancelRentalReminders(rental.id);

        // Update vehicle status to available
        final vehicle = await vehicleRepository.getVehicleById(
          rental.vehicleId,
        );
        if (vehicle != null) {
          final updatedVehicle = vehicle.copyWith(
            status: VehicleStatus.available,
          );
          await vehicleRepository.saveVehicle(updatedVehicle);
        }

        add(LoadRentals());
      }
    } catch (e) {
      emit(RentalError(e.toString()));
    }
  }

  Future<void> _onFilterRentalsByStatus(
    FilterRentalsByStatus event,
    Emitter<RentalState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is RentalLoaded) {
        List<Rental> filteredRentals = currentState.rentals;

        if (event.status != null) {
          filteredRentals = await rentalRepository.getRentalsByStatus(
            event.status!,
          );
        }

        emit(
          currentState.copyWith(
            filteredRentals: filteredRentals,
            statusFilter: event.status,
          ),
        );
      }
    } catch (e) {
      emit(RentalError(e.toString()));
    }
  }

  Future<void> _onUpdateRentalPayment(
    UpdateRentalPayment event,
    Emitter<RentalState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is RentalLoaded) {
        final rental =
            currentState.rentals.firstWhere((r) => r.id == event.rentalId);
        final updatedRental = rental.updatePayment(event.paymentAmount);

        await rentalRepository.saveRental(updatedRental);
        add(LoadRentals());
      }
    } catch (e) {
      emit(RentalError(e.toString()));
    }
  }

  Future<void> _onUpdateRentalMileage(
    UpdateRentalMileage event,
    Emitter<RentalState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is RentalLoaded) {
        final rental =
            currentState.rentals.firstWhere((r) => r.id == event.rentalId);
        final updatedRental = rental.updateMileage(
          event.startMileage,
          event.endMileage,
        );

        await rentalRepository.saveRental(updatedRental);
        add(LoadRentals());
      }
    } catch (e) {
      emit(RentalError(e.toString()));
    }
  }

  Future<void> _onCompleteRentalWithMileage(
    CompleteRentalWithMileage event,
    Emitter<RentalState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is RentalLoaded) {
        final rental =
            currentState.rentals.firstWhere((r) => r.id == event.rentalId);

        // Update rental with end mileage and mark as completed
        Rental updatedRental = rental.updateMileage(
          rental.startMileage,
          event.endMileage,
        );

        if (event.finalCost != null) {
          updatedRental = updatedRental.copyWith(
            totalCost: event.finalCost!,
            amountPaid: event.finalCost!, // Set amount paid to final cost
            paymentStatus: PaymentStatus.paid, // Mark as paid
          );
        } else {
          // If no final cost provided, mark as paid with current total cost
          updatedRental = updatedRental.copyWith(
            amountPaid: updatedRental.totalCost,
            paymentStatus: PaymentStatus.paid, // Mark as paid
          );
        }

        updatedRental = updatedRental.markAsCompleted();

        await rentalRepository.saveRental(updatedRental);

        // Update vehicle status to available and update current mileage
        final vehicle =
            await vehicleRepository.getVehicleById(rental.vehicleId);
        if (vehicle != null) {
          final updatedVehicle = vehicle.copyWith(
            status: VehicleStatus.available,
            currentMileage: event.endMileage,
          );
          await vehicleRepository.saveVehicle(updatedVehicle);
        }

        add(LoadRentals());
      }
    } catch (e) {
      emit(RentalError(e.toString()));
    }
  }
}
