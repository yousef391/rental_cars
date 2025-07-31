import 'package:equatable/equatable.dart';

enum RentalStatus { active, completed }

enum PaymentStatus { pending, paid }

class Rental extends Equatable {
  final String id;
  final String vehicleId;
  final String customerId;
  final DateTime startDate;
  final DateTime endDate;
  final double totalCost;
  final double securityDeposit;
  final double amountPaid;
  final PaymentStatus paymentStatus;
  final RentalStatus status;
  final int? startMileage;
  final int? endMileage;
  final DateTime createdAt;

  const Rental({
    required this.id,
    required this.vehicleId,
    required this.customerId,
    required this.startDate,
    required this.endDate,
    required this.totalCost,
    required this.securityDeposit,
    this.amountPaid = 0.0,
    this.paymentStatus = PaymentStatus.pending,
    this.status = RentalStatus.active,
    this.startMileage,
    this.endMileage,
    required this.createdAt,
  });

  factory Rental.create({
    required String vehicleId,
    required String customerId,
    required DateTime startDate,
    required DateTime endDate,
    required double totalCost,
    required double securityDeposit,
    int? startMileage,
  }) {
    return Rental(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      vehicleId: vehicleId,
      customerId: customerId,
      startDate: startDate,
      endDate: endDate,
      totalCost: totalCost,
      securityDeposit: securityDeposit,
      startMileage: startMileage,
      createdAt: DateTime.now(),
    );
  }

  Rental copyWith({
    String? id,
    String? vehicleId,
    String? customerId,
    DateTime? startDate,
    DateTime? endDate,
    double? totalCost,
    double? securityDeposit,
    double? amountPaid,
    PaymentStatus? paymentStatus,
    RentalStatus? status,
    int? startMileage,
    int? endMileage,
    DateTime? createdAt,
  }) {
    return Rental(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      customerId: customerId ?? this.customerId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalCost: totalCost ?? this.totalCost,
      securityDeposit: securityDeposit ?? this.securityDeposit,
      amountPaid: amountPaid ?? this.amountPaid,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      status: status ?? this.status,
      startMileage: startMileage ?? this.startMileage,
      endMileage: endMileage ?? this.endMileage,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Rental markAsCompleted() {
    return copyWith(status: RentalStatus.completed);
  }

  Rental updateMileage(int? startMileage, int? endMileage) {
    return copyWith(startMileage: startMileage, endMileage: endMileage);
  }

  int? get distanceTraveled {
    if (startMileage != null && endMileage != null) {
      return endMileage! - startMileage!;
    }
    return null;
  }

  Rental updatePayment(double amount) {
    final newAmountPaid = amountPaid + amount;
    PaymentStatus newPaymentStatus;

    if (newAmountPaid >= totalCost) {
      newPaymentStatus = PaymentStatus.paid;
    } else {
      newPaymentStatus = PaymentStatus.pending;
    }

    return copyWith(
      amountPaid: newAmountPaid,
      paymentStatus: newPaymentStatus,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'customerId': customerId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalCost': totalCost,
      'securityDeposit': securityDeposit,
      'amountPaid': amountPaid,
      'paymentStatus': paymentStatus.name,
      'status': status.name,
      'startMileage': startMileage,
      'endMileage': endMileage,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Rental.fromJson(Map<String, dynamic> json) {
    return Rental(
      id: json['id'],
      vehicleId: json['vehicleId'],
      customerId: json['customerId'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      totalCost: json['totalCost'].toDouble(),
      securityDeposit: json['securityDeposit']?.toDouble() ?? 0.0,
      amountPaid: json['amountPaid']?.toDouble() ?? 0.0,
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.name == (json['paymentStatus'] ?? 'pending'),
        orElse: () => PaymentStatus.pending,
      ),
      status: RentalStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => RentalStatus.active,
      ),
      startMileage: json['startMileage']?.toInt(),
      endMileage: json['endMileage']?.toInt(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  @override
  List<Object?> get props => [
        id,
        vehicleId,
        customerId,
        startDate,
        endDate,
        totalCost,
        securityDeposit,
        amountPaid,
        paymentStatus,
        status,
        startMileage,
        endMileage,
        createdAt,
      ];
}
