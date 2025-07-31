import 'package:equatable/equatable.dart';

class Customer extends Equatable {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String emailAddress;
  final String driverLicenseNumber;
  final String address;
  final String? licenseCardImagePath;

  const Customer({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.emailAddress,
    required this.driverLicenseNumber,
    required this.address,
    this.licenseCardImagePath,
  });

  factory Customer.create({
    required String fullName,
    required String phoneNumber,
    required String emailAddress,
    required String driverLicenseNumber,
    required String address,
    String? licenseCardImagePath,
  }) {
    return Customer(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fullName: fullName,
      phoneNumber: phoneNumber,
      emailAddress: emailAddress,
      driverLicenseNumber: driverLicenseNumber,
      address: address,
      licenseCardImagePath: licenseCardImagePath,
    );
  }

  Customer copyWith({
    String? id,
    String? fullName,
    String? phoneNumber,
    String? emailAddress,
    String? driverLicenseNumber,
    String? address,
    String? licenseCardImagePath,
  }) {
    return Customer(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      emailAddress: emailAddress ?? this.emailAddress,
      driverLicenseNumber: driverLicenseNumber ?? this.driverLicenseNumber,
      address: address ?? this.address,
      licenseCardImagePath: licenseCardImagePath ?? this.licenseCardImagePath,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'emailAddress': emailAddress,
      'driverLicenseNumber': driverLicenseNumber,
      'address': address,
      'licenseCardImagePath': licenseCardImagePath,
    };
  }

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      emailAddress: json['emailAddress'] ?? '',
      driverLicenseNumber: json['driverLicenseNumber'] ?? '',
      address: json['address'] ?? '',
      licenseCardImagePath: json['licenseCardImagePath'],
    );
  }

  @override
  List<Object?> get props => [
        id,
        fullName,
        phoneNumber,
        emailAddress,
        driverLicenseNumber,
        address,
        licenseCardImagePath,
      ];
}
