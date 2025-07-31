# PDF Contract Generation Feature

## Overview
The offline car rental application now includes a comprehensive PDF contract generation feature that creates professional rental contracts in both English and Arabic. This feature is integrated into the rental creation process and can also be used to generate contracts for existing rentals.

## Features

### 1. Automatic Contract Generation
- When creating a new rental, users can choose to automatically generate a PDF contract
- The contract includes all rental details, vehicle information, and customer information
- Bilingual support (English and Arabic) for international use

### 2. Manual Contract Generation
- Generate contracts for existing rentals from the rentals list
- Accessible via the "Contract" button on each rental item

### 3. Contract Features
- **Vehicle Information**: Make, model, year, license plate, color, daily rate
- **Customer Information**: Name, phone, license number, address
- **Rental Details**: Start/end dates, duration, total cost, security deposit
- **Inspection Checklist**: Vehicle equipment verification items
- **Terms and Conditions**: Standard rental agreement terms
- **Signature Areas**: Spaces for customer and company signatures
- **Professional Layout**: Clean, organized design suitable for printing

## How to Use

### Creating a New Rental with Contract
1. Navigate to the Rentals screen
2. Click "New Rental" button
3. Fill in the rental details (vehicle, customer, dates, etc.)
4. Check the "Generate Rental Contract PDF" checkbox
5. Click "Create Rental"
6. The system will generate the contract and show a preview dialog
7. Choose to either print or save the contract

### Generating Contract for Existing Rental
1. Navigate to the Rentals screen
2. Find the rental in the list
3. Click the "Contract" button (red PDF icon)
4. The system will generate the contract and show a preview dialog
5. Choose to either print or save the contract

### Contract Actions
- **Print**: Opens the system print dialog to print the contract
- **Save**: Saves the PDF file to the device's documents directory
- **Close**: Closes the preview dialog

## Technical Implementation

### Dependencies Added
```yaml
dependencies:
  pdf: ^3.10.7
  printing: ^5.11.1
```

### Files Modified/Created
- `lib/data/services/pdf_service.dart` - PDF generation service
- `lib/presentation/widgets/rental_form.dart` - Updated rental form with contract generation
- `lib/presentation/screens/rentals_screen.dart` - Added contract generation button
- `pubspec.yaml` - Added PDF dependencies
- `assets/fonts/` - Directory for Arabic font

### PDF Service Features
- **Bilingual Support**: English and Arabic text
- **Font Fallback**: Graceful handling of missing Arabic fonts
- **Professional Layout**: Clean, organized design
- **Error Handling**: Comprehensive error handling and user feedback
- **File Management**: Save and print functionality

## Font Setup

### Arabic Font Requirements
The contract includes Arabic text for the company name, section headers, and terms. To display Arabic text properly:

1. Download the Amiri font from Google Fonts
2. Place `Amiri-Regular.ttf` in the `assets/fonts/` directory
3. The system will automatically use the Arabic font if available

### Fallback Behavior
If no Arabic font is found, the system will:
- Use the default Helvetica font
- Still generate a valid PDF
- Display English text normally
- Show Arabic text with basic font rendering

## Contract Structure

### Header Section
- Company name in Arabic and English
- Contract title
- Professional branding

### Vehicle Information
- Make and model
- License plate
- Year and color
- Daily rental rate

### Customer Information
- Full name
- Phone number
- Driver's license number
- Address

### Rental Details
- Start and end dates
- Duration in days
- Total cost
- Security deposit

### Inspection Checklist
- Safety equipment verification
- Vehicle accessories check
- Two-column layout for efficiency

### Terms and Conditions
- Standard rental agreement terms
- Legal clauses
- Company policies

### Signature Areas
- Customer signature line
- Company signature line
- Date fields
- Arabic instructions

## Error Handling

### Common Issues and Solutions
1. **Font Loading Error**: Download and install the Arabic font
2. **PDF Generation Error**: Check that all required data is available
3. **Print Error**: Ensure printer is connected and configured
4. **Save Error**: Check device storage permissions

### User Feedback
- Success messages for successful operations
- Error messages with specific details
- Loading indicators during PDF generation
- Clear action buttons and instructions

## Testing

### Test Coverage
- PDF generation functionality
- File saving operations
- Error handling scenarios
- Font loading fallbacks

### Test Files
- `test/pdf_service_test.dart` - Unit tests for PDF service

## Future Enhancements

### Potential Improvements
1. **Custom Templates**: Allow users to customize contract templates
2. **Digital Signatures**: Add digital signature support
3. **Email Integration**: Send contracts via email
4. **Cloud Storage**: Save contracts to cloud storage
5. **Contract History**: Track generated contracts
6. **Multiple Languages**: Support for additional languages

### Configuration Options
- Company branding customization
- Contract terms customization
- Font selection options
- Layout customization

## Support

### Troubleshooting
- Check the `FONT_SETUP.md` file for font installation help
- Verify all dependencies are installed with `flutter pub get`
- Test PDF generation with sample data
- Check device permissions for file saving

### Documentation
- This file provides comprehensive feature documentation
- Code comments explain implementation details
- Test files demonstrate proper usage
- Font setup guide available in `FONT_SETUP.md` 