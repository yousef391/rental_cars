import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import '../../domain/models/rental.dart';
import '../../domain/models/vehicle.dart';
import '../../domain/models/customer.dart';
import '../../domain/models/company_settings.dart';

class PdfService {
  static final PdfService _instance = PdfService._internal();
  factory PdfService() => _instance;
  PdfService._internal();

  Future<pw.Document> generateRentalContractPdf({
    required Rental rental,
    required Vehicle vehicle,
    required Customer customer,
    required CompanySettings companySettings,
  }) async {
    // Debug: Print company settings
    print('🔍 PDF Service - Company Settings:');
    print('   Company Name: ${companySettings.companyName}');
    print('   Company Address: ${companySettings.companyAddress}');
    print('   Company Phone: ${companySettings.companyPhone}');
    print('   Logo Path: ${companySettings.logoPath}');
    print('');

    final doc = pw.Document();

    // Load fonts with better Unicode support
    pw.Font arabicFont;
    pw.Font englishFont;
    pw.Font boldFont;

    try {
      // Try to load Arabic font
      final arabicFontData =
          await rootBundle.load('assets/fonts/Amiri-Regular.ttf');
      arabicFont = pw.Font.ttf(arabicFontData);
    } catch (e) {
      // Fallback to default font
      arabicFont = pw.Font.helvetica();
    }

    // Use default fonts
    englishFont = pw.Font.helvetica();
    boldFont = pw.Font.helveticaBold();

    // Format dates
    final startDate = rental.startDate.toString().split(' ')[0];
    final endDate = rental.endDate.toString().split(' ')[0];
    final rentalCreationDate = rental.createdAt.toString().split(' ')[0];
    final durationInDays = rental.endDate.difference(rental.startDate).inDays;

    // Load company logo if available
    pw.MemoryImage? logoImage;
    if (companySettings.logoPath != null) {
      try {
        final logoFile = File(companySettings.logoPath!);
        if (await logoFile.exists()) {
          final logoBytes = await logoFile.readAsBytes();
          logoImage = pw.MemoryImage(logoBytes);
        }
      } catch (e) {
        print('Error loading logo: $e');
      }
    }

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            // Compact Header with Company Info
            pw.Center(
              child: pw.Column(
                children: [
                  // Company Logo (if available)
                  if (logoImage != null)
                    pw.Container(
                      width: 40,
                      height: 40,
                      child: pw.Image(logoImage),
                    ),
                  if (logoImage != null) pw.SizedBox(height: 4),

                  // Company Name
                  pw.Directionality(
                    textDirection: pw.TextDirection.rtl,
                    child: pw.Text(
                      companySettings.companyName,
                      style: pw.TextStyle(
                        font: arabicFont,
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 4),

                  // Contract Title
                  pw.Directionality(
                    textDirection: pw.TextDirection.rtl,
                    child: pw.Text(
                      'عقد كراء سيارة',
                      style: pw.TextStyle(font: arabicFont, fontSize: 12),
                    ),
                  ),

                  // Company Address and Phone
                  pw.Text(
                    companySettings.companyAddress,
                    style: pw.TextStyle(font: englishFont, fontSize: 8),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.Text(
                    'Phone: ${companySettings.companyPhone}',
                    style: pw.TextStyle(font: englishFont, fontSize: 8),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 15),

            // Compact Vehicle Info
            _buildCompactSection(
              'Vehicle Info',
              'معلومات السيارة',
              boldFont,
              arabicFont,
            ),
            pw.SizedBox(height: 4),
            _buildCompactRow(
              'Make:',
              'النوع:',
              vehicle.make,
              englishFont,
              arabicFont,
            ),
            _buildCompactRow(
              'Model:',
              'الطراز:',
              vehicle.model,
              englishFont,
              arabicFont,
            ),
            _buildCompactRow(
              'Plate:',
              'التسجيل:',
              vehicle.licensePlate,
              englishFont,
              arabicFont,
            ),
            _buildCompactRow(
              'Year:',
              'السنة:',
              vehicle.year.toString(),
              englishFont,
              arabicFont,
            ),
            _buildCompactRow(
              'Color:',
              'اللون:',
              vehicle.color,
              englishFont,
              arabicFont,
            ),

            pw.SizedBox(height: 10),

            // Compact Customer Info
            _buildCompactSection(
              'Customer Info',
              'معلومات المستأجر',
              boldFont,
              arabicFont,
            ),
            pw.SizedBox(height: 4),
            _buildCompactRow(
              'Name:',
              'الاسم:',
              customer.fullName,
              englishFont,
              arabicFont,
            ),
            _buildCompactRow(
              'Phone:',
              'الهاتف:',
              customer.phoneNumber,
              englishFont,
              arabicFont,
            ),
            _buildCompactRow(
              'License:',
              'الرخصة:',
              customer.driverLicenseNumber,
              englishFont,
              arabicFont,
            ),
            _buildCompactRow(
              'Address:',
              'العنوان:',
              customer.address,
              englishFont,
              arabicFont,
            ),

            pw.SizedBox(height: 10),

            // Compact Rental Details
            _buildCompactSection(
              'Rental Details',
              'تفاصيل الإيجار',
              boldFont,
              arabicFont,
            ),
            pw.SizedBox(height: 4),
            _buildCompactRow(
              'Start:',
              'البداية:',
              startDate,
              englishFont,
              arabicFont,
            ),
            _buildCompactRow(
              'End:',
              'النهاية:',
              endDate,
              englishFont,
              arabicFont,
            ),
            _buildCompactRow(
              'Duration:',
              'المدة:',
              '$durationInDays days',
              englishFont,
              arabicFont,
            ),
            _buildCompactRow(
              'Daily Rate:',
              'السعر اليومي:',
              '${vehicle.dailyRentalRate} DZD',
              englishFont,
              arabicFont,
            ),
            _buildCompactRow(
              'Total:',
              'المجموع:',
              '${rental.totalCost} DZD',
              englishFont,
              arabicFont,
            ),
            _buildCompactRow(
              'Security Deposit:',
              'الوديعة:',
              '${rental.securityDeposit} DZD',
              englishFont,
              arabicFont,
            ),

            pw.SizedBox(height: 10),

            // Compact Inspection Checklist
            _buildCompactSection(
              'Vehicle Inspection',
              'فحص السيارة',
              boldFont,
              arabicFont,
            ),
            pw.SizedBox(height: 4),

            // Two-column compact inspection - Arabic only
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _buildArabicCheckItem('عجلة الأمان', arabicFont),
                      _buildArabicCheckItem('الرافعة', arabicFont),
                      _buildArabicCheckItem('الأدوات', arabicFont),
                      _buildArabicCheckItem('مثلث التحذير', arabicFont),
                    ],
                  ),
                ),
                pw.SizedBox(width: 15),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _buildArabicCheckItem('حقيبة الإسعافات', arabicFont),
                      _buildArabicCheckItem('ماسحة الزجاج', arabicFont),
                      _buildArabicCheckItem('شعالة السجائر', arabicFont),
                      _buildArabicCheckItem('المنبه الصوتي', arabicFont),
                    ],
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 10),

            // Compact Agreement
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Directionality(
                textDirection: pw.TextDirection.rtl,
                child: pw.Text(
                  'من التوقيع على هذا العقد بالكراء يشهد على أن السيارة المؤجرة تحت تصرف المستاجر نفسه، معترفا بأنه تسلمها في حالة جيدة بجميع وثائقها الرسمية وتجهيزاتها المطابقة للطلب.\n'
                  'نرجو منكم قراءة متانية للشروط العامة الموجودة على ظهر الصفحة.',
                  style: pw.TextStyle(font: arabicFont, fontSize: 9),
                ),
              ),
            ),

            pw.SizedBox(height: 15),

            // Compact Signatures
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Customer:',
                      style: pw.TextStyle(font: boldFont, fontSize: 8),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Container(
                      width: 120,
                      height: 1,
                      color: PdfColors.black,
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Date: $rentalCreationDate',
                      style: pw.TextStyle(font: englishFont, fontSize: 8),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Directionality(
                      textDirection: pw.TextDirection.rtl,
                      child: pw.Text(
                        'توقيع المستاجر المذكور أعلاه مع البصمة',
                        style: pw.TextStyle(font: arabicFont, fontSize: 7),
                      ),
                    ),
                    pw.Directionality(
                      textDirection: pw.TextDirection.rtl,
                      child: pw.Text(
                        'مع ذكر عبارة " قرأت ووافقت"',
                        style: pw.TextStyle(font: arabicFont, fontSize: 7),
                      ),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Company:',
                      style: pw.TextStyle(font: boldFont, fontSize: 8),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Container(
                      width: 120,
                      height: 1,
                      color: PdfColors.black,
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Date: $rentalCreationDate',
                      style: pw.TextStyle(font: englishFont, fontSize: 8),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Directionality(
                      textDirection: pw.TextDirection.rtl,
                      child: pw.Text(
                        'حرر ب: ${companySettings.companyAddress} في $rentalCreationDate',
                        style: pw.TextStyle(font: arabicFont, fontSize: 7),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 15),

            // Compact Terms
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.blue, width: 0.5),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Directionality(
                    textDirection: pw.TextDirection.rtl,
                    child: pw.Text(
                      'الشروط والأحكام:',
                      style: pw.TextStyle(
                        font: arabicFont,
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Directionality(
                    textDirection: pw.TextDirection.rtl,
                    child: pw.Text(
                      '1. إعادة السيارة في الوقت المحدد\n'
                      '2. تحمل المخالفات والأضرار\n'
                      '3. عدم التأجير للغير\n'
                      '4. إبلاغ الشركة عند الحوادث\n'
                      '5. الحفاظ على النظافة\n'
                      '6. حق الشركة في إنهاء العقد',
                      style: pw.TextStyle(font: arabicFont, fontSize: 8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    return doc;
  }

  pw.Widget _buildCompactSection(
    String englishTitle,
    String arabicTitle,
    pw.Font boldFont,
    pw.Font arabicFont,
  ) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.center,
      children: [
        pw.Text(
          englishTitle,
          style: pw.TextStyle(font: boldFont, fontSize: 10),
        ),
        pw.SizedBox(width: 8),
        pw.Directionality(
          textDirection: pw.TextDirection.rtl,
          child: pw.Text(
            arabicTitle,
            style: pw.TextStyle(font: arabicFont, fontSize: 10),
          ),
        ),
      ],
    );
  }

  pw.Widget _buildCompactRow(
    String englishLabel,
    String arabicLabel,
    String value,
    pw.Font englishFont,
    pw.Font arabicFont,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text(
            '$englishLabel ',
            style: pw.TextStyle(font: englishFont, fontSize: 8),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
                font: englishFont, fontSize: 8, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(width: 8),
          pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Text(
              '$arabicLabel $value',
              style: pw.TextStyle(font: arabicFont, fontSize: 8),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildArabicCheckItem(String text, pw.Font arabicFont) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Container(
            width: 8,
            height: 8,
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black, width: 0.5),
            ),
          ),
          pw.SizedBox(width: 4),
          pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Text(
              text,
              style: pw.TextStyle(font: arabicFont, fontSize: 8),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> printPdf(pw.Document doc) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }

  Future<String> savePdfToFile(pw.Document doc, String fileName) async {
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/$fileName.pdf');
    await file.writeAsBytes(await doc.save());
    return file.path;
  }
}
