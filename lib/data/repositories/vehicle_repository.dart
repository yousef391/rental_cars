import 'package:offline_rent_car/domain/models/vehicle.dart';
import 'package:offline_rent_car/data/services/storage_service.dart';

class VehicleRepository {
  final StorageService _storageService = StorageService();

  Future<void> initialize() async {
    await _storageService.initialize();
  }

  Future<List<Vehicle>> getAllVehicles() async {
    final vehiclesData = await _storageService.loadAllVehicles();
    return vehiclesData.map((data) => Vehicle.fromJson(data)).toList();
  }

  Future<Vehicle?> getVehicleById(String id) async {
    final vehicleData = await _storageService.loadVehicle(id);
    if (vehicleData != null) {
      return Vehicle.fromJson(vehicleData);
    }
    return null;
  }

  Future<void> saveVehicle(Vehicle vehicle) async {
    await _storageService.saveVehicle(vehicle.id, vehicle.toJson());
  }

  Future<void> deleteVehicle(String id) async {
    await _storageService.deleteVehicle(id);
  }

  Future<List<Vehicle>> getVehiclesByStatus(VehicleStatus status) async {
    final allVehicles = await getAllVehicles();
    return allVehicles.where((vehicle) => vehicle.status == status).toList();
  }

  Future<List<Vehicle>> searchVehicles(String query) async {
    final allVehicles = await getAllVehicles();
    final lowercaseQuery = query.toLowerCase();

    return allVehicles
        .where(
          (vehicle) =>
              vehicle.make.toLowerCase().contains(lowercaseQuery) ||
              vehicle.model.toLowerCase().contains(lowercaseQuery) ||
              vehicle.licensePlate.toLowerCase().contains(lowercaseQuery),
        )
        .toList();
  }
}
