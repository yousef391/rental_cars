import 'package:offline_rent_car/domain/models/rental.dart';
import 'package:offline_rent_car/data/services/storage_service.dart';

class RentalRepository {
  final StorageService _storageService = StorageService();

  Future<void> initialize() async {
    await _storageService.initialize();
  }

  Future<List<Rental>> getAllRentals() async {
    final rentalsData = await _storageService.loadAllRentals();
    return rentalsData.map((data) => Rental.fromJson(data)).toList();
  }

  Future<Rental?> getRentalById(String id) async {
    final rentalData = await _storageService.loadRental(id);
    if (rentalData != null) {
      return Rental.fromJson(rentalData);
    }
    return null;
  }

  Future<void> saveRental(Rental rental) async {
    await _storageService.saveRental(rental.id, rental.toJson());
  }

  Future<void> deleteRental(String id) async {
    await _storageService.deleteRental(id);
  }

  Future<List<Rental>> getRentalsByStatus(RentalStatus status) async {
    final allRentals = await getAllRentals();
    return allRentals.where((rental) => rental.status == status).toList();
  }

  Future<List<Rental>> getActiveRentals() async {
    return getRentalsByStatus(RentalStatus.active);
  }

  Future<List<Rental>> getCompletedRentals() async {
    return getRentalsByStatus(RentalStatus.completed);
  }

  Future<List<Rental>> getRentalsByVehicle(String vehicleId) async {
    final allRentals = await getAllRentals();
    return allRentals.where((rental) => rental.vehicleId == vehicleId).toList();
  }

  Future<List<Rental>> getRentalsByCustomer(String customerId) async {
    final allRentals = await getAllRentals();
    return allRentals
        .where((rental) => rental.customerId == customerId)
        .toList();
  }

  Future<List<Rental>> getUpcomingReturns() async {
    final activeRentals = await getActiveRentals();
    final now = DateTime.now();
    final dayAfterTomorrow = now.add(const Duration(days: 2));

    return activeRentals
        .where(
          (rental) =>
              rental.endDate.isAfter(now) &&
              rental.endDate.isBefore(dayAfterTomorrow),
        )
        .toList();
  }
}
