class CompanySettings {
  final String id;
  final String companyName;
  final String companyAddress;
  final String companyPhone;
  final String? logoPath;
  final DateTime createdAt;
  final DateTime updatedAt;

  CompanySettings({
    required this.id,
    required this.companyName,
    required this.companyAddress,
    required this.companyPhone,
    this.logoPath,
    required this.createdAt,
    required this.updatedAt,
  });

  // Default settings
  factory CompanySettings.defaultSettings() {
    return CompanySettings(
      id: 'default',
      companyName: 'Car Rental Company',
      companyAddress: '123 Main Street, City, Country',
      companyPhone: '+213 123 456 789',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // Copy with method
  CompanySettings copyWith({
    String? id,
    String? companyName,
    String? companyAddress,
    String? companyPhone,
    String? logoPath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CompanySettings(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      companyAddress: companyAddress ?? this.companyAddress,
      companyPhone: companyPhone ?? this.companyPhone,
      logoPath: logoPath ?? this.logoPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyName': companyName,
      'companyAddress': companyAddress,
      'companyPhone': companyPhone,
      'logoPath': logoPath,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory CompanySettings.fromJson(Map<String, dynamic> json) {
    return CompanySettings(
      id: json['id'] ?? '',
      companyName: json['companyName'] ?? '',
      companyAddress: json['companyAddress'] ?? '',
      companyPhone: json['companyPhone'] ?? '',
      logoPath: json['logoPath'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  @override
  String toString() {
    return 'CompanySettings(id: $id, companyName: $companyName, companyAddress: $companyAddress, companyPhone: $companyPhone, logoPath: $logoPath, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CompanySettings &&
        other.id == id &&
        other.companyName == companyName &&
        other.companyAddress == companyAddress &&
        other.companyPhone == companyPhone &&
        other.logoPath == logoPath &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        companyName.hashCode ^
        companyAddress.hashCode ^
        companyPhone.hashCode ^
        logoPath.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
} 