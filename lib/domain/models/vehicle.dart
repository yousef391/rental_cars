import 'package:equatable/equatable.dart';

enum VehicleStatus { available, rented, underMaintenance }

class MaintenanceRecord extends Equatable {
  final String id;
  final String type;
  final DateTime dateOfService;
  final DateTime? nextDueDate;
  final String notes;

  const MaintenanceRecord({
    required this.id,
    required this.type,
    required this.dateOfService,
    this.nextDueDate,
    required this.notes,
  });

  factory MaintenanceRecord.create({
    required String type,
    required DateTime dateOfService,
    DateTime? nextDueDate,
    required String notes,
  }) {
    return MaintenanceRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      dateOfService: dateOfService,
      nextDueDate: nextDueDate,
      notes: notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'dateOfService': dateOfService.toIso8601String(),
      'nextDueDate': nextDueDate?.toIso8601String(),
      'notes': notes,
    };
  }

  factory MaintenanceRecord.fromJson(Map<String, dynamic> json) {
    return MaintenanceRecord(
      id: json['id'],
      type: json['type'],
      dateOfService: DateTime.parse(json['dateOfService']),
      nextDueDate: json['nextDueDate'] != null
          ? DateTime.parse(json['nextDueDate'])
          : null,
      notes: json['notes'],
    );
  }

  @override
  List<Object?> get props => [id, type, dateOfService, nextDueDate, notes];
}

class Vehicle extends Equatable {
  final String id;
  final String make;
  final String model;
  final int year;
  final String licensePlate;
  final String color;
  final double dailyRentalRate;
  final int currentMileage;
  final VehicleStatus status;
  final List<MaintenanceRecord> maintenanceRecords;
  final String? carImagePath;

  const Vehicle({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    required this.licensePlate,
    required this.color,
    required this.dailyRentalRate,
    this.currentMileage = 0,
    this.status = VehicleStatus.available,
    this.maintenanceRecords = const [],
    this.carImagePath,
  });

  factory Vehicle.create({
    required String make,
    required String model,
    required int year,
    required String licensePlate,
    required String color,
    required double dailyRentalRate,
    String? carImagePath,
  }) {
    return Vehicle(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      make: make,
      model: model,
      year: year,
      licensePlate: licensePlate,
      color: color,
      dailyRentalRate: dailyRentalRate,
      carImagePath: carImagePath,
    );
  }

  Vehicle copyWith({
    String? id,
    String? make,
    String? model,
    int? year,
    String? licensePlate,
    String? color,
    double? dailyRentalRate,
    int? currentMileage,
    VehicleStatus? status,
    List<MaintenanceRecord>? maintenanceRecords,
    String? carImagePath,
  }) {
    return Vehicle(
      id: id ?? this.id,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      licensePlate: licensePlate ?? this.licensePlate,
      color: color ?? this.color,
      dailyRentalRate: dailyRentalRate ?? this.dailyRentalRate,
      currentMileage: currentMileage ?? this.currentMileage,
      status: status ?? this.status,
      maintenanceRecords: maintenanceRecords ?? this.maintenanceRecords,
      carImagePath: carImagePath ?? this.carImagePath,
    );
  }

  Vehicle addMaintenanceRecord(MaintenanceRecord record) {
    return copyWith(maintenanceRecords: [...maintenanceRecords, record]);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'make': make,
      'model': model,
      'year': year,
      'licensePlate': licensePlate,
      'color': color,
      'dailyRentalRate': dailyRentalRate,
      'currentMileage': currentMileage,
      'status': status.name,
      'maintenanceRecords': maintenanceRecords.map((r) => r.toJson()).toList(),
      'carImagePath': carImagePath,
    };
  }

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'],
      make: json['make'],
      model: json['model'],
      year: json['year'],
      licensePlate: json['licensePlate'],
      color: json['color'],
      dailyRentalRate: json['dailyRentalRate'].toDouble(),
      currentMileage: json['currentMileage']?.toInt() ?? 0,
      status: VehicleStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => VehicleStatus.available,
      ),
      maintenanceRecords: (json['maintenanceRecords'] as List<dynamic>?)
              ?.map((r) => MaintenanceRecord.fromJson(r))
              .toList() ??
          [],
      carImagePath: json['carImagePath'],
    );
  }

  @override
  List<Object?> get props => [
        id,
        make,
        model,
        year,
        licensePlate,
        color,
        dailyRentalRate,
        currentMileage,
        status,
        maintenanceRecords,
        carImagePath,
      ];
}
