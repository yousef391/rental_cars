import 'package:flutter_test/flutter_test.dart';
import 'package:offline_rent_car/data/services/pdf_service.dart';
import 'package:offline_rent_car/domain/models/rental.dart';
import 'package:offline_rent_car/domain/models/vehicle.dart';
import 'package:offline_rent_car/domain/models/customer.dart';
import 'package:offline_rent_car/domain/models/company_settings.dart';

void main() {
  group('PdfService Tests', () {
    late PdfService pdfService;
    late Rental testRental;
    late Vehicle testVehicle;
    late Customer testCustomer;
    late CompanySettings testCompanySettings;

    setUp(() {
      pdfService = PdfService();

      testRental = Rental.create(
        vehicleId: 'test_vehicle_id',
        customerId: 'test_customer_id',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 7)),
        totalCost: 700.0,
        securityDeposit: 200.0,
      );

      testVehicle = Vehicle.create(
        make: 'Toyota',
        model: 'Camry',
        year: 2020,
        licensePlate: 'ABC123',
        color: 'White',
        dailyRentalRate: 100.0,
      );

      testCustomer = Customer.create(
        fullName: 'John Doe',
        phoneNumber: '+1234567890',
        emailAddress: 'john@example.com',
        driverLicenseNumber: 'DL123456',
        address: '123 Main St, City, Country',
      );

      testCompanySettings = CompanySettings(
        id: 'test_company',
        companyName: 'Test Rental Company',
        companyAddress: '456 Business Ave, Test City, Country',
        companyPhone: '+9876543210',
        logoPath: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    });

    test('should generate PDF document', () async {
      final doc = await pdfService.generateRentalContractPdf(
        rental: testRental,
        vehicle: testVehicle,
        customer: testCustomer,
        companySettings: testCompanySettings,
      );

      expect(doc, isNotNull);
      expect(doc.document.pdfPageList.pages.length, equals(1));
    });

    test('should save PDF to file', () async {
      final doc = await pdfService.generateRentalContractPdf(
        rental: testRental,
        vehicle: testVehicle,
        customer: testCustomer,
        companySettings: testCompanySettings,
      );

      final filePath = await pdfService.savePdfToFile(doc, 'test_contract');

      expect(filePath, isNotEmpty);
      expect(filePath.endsWith('.pdf'), isTrue);
    });

    test('should generate PDF with company logo', () async {
      // Create company settings with logo path
      final companySettingsWithLogo = CompanySettings(
        id: 'test_company_with_logo',
        companyName: 'Test Rental Company with Logo',
        companyAddress: '456 Business Ave, Test City, Country',
        companyPhone: '+9876543210',
        logoPath:
            'test/path/to/logo.png', // This will be handled gracefully if file doesn't exist
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final doc = await pdfService.generateRentalContractPdf(
        rental: testRental,
        vehicle: testVehicle,
        customer: testCustomer,
        companySettings: companySettingsWithLogo,
      );

      expect(doc, isNotNull);
      expect(doc.document.pdfPageList.pages.length, equals(1));
    });

    test('should handle missing company settings gracefully', () async {
      // Test with default company settings
      final defaultCompanySettings = CompanySettings.defaultSettings();

      final doc = await pdfService.generateRentalContractPdf(
        rental: testRental,
        vehicle: testVehicle,
        customer: testCustomer,
        companySettings: defaultCompanySettings,
      );

      expect(doc, isNotNull);
      expect(doc.document.pdfPageList.pages.length, equals(1));
    });
  });
}
