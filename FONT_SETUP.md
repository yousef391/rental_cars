# Arabic Font Setup for PDF Generation

## Overview
The rental contract PDF generation feature requires an Arabic font to properly display Arabic text in the contract documents.

## Font Setup Instructions

### Option 1: Download Amiri Font (Recommended)
1. Go to Google Fonts: https://fonts.google.com/specimen/Amiri
2. Download the Amiri font family
3. Extract the `Amiri-Regular.ttf` file
4. Place it in the `assets/fonts/` directory of your project
5. Make sure the file is named exactly `Amiri-Regular.ttf`

### Option 2: Use a Different Arabic Font
1. Download any Arabic TTF font file
2. Rename it to `Amiri-Regular.ttf`
3. Place it in the `assets/fonts/` directory

### Option 3: Fallback (No Arabic Font)
If no Arabic font is found, the system will fallback to the default Helvetica font. Arabic text may not display correctly, but the PDF will still be generated.

## File Structure
```
assets/
  fonts/
    Amiri-Regular.ttf  # Place your Arabic font here
```

## Verification
After placing the font file, run:
```bash
flutter pub get
flutter run
```

The PDF generation should work properly with Arabic text support.

## Troubleshooting
- If you see font loading errors, check that the font file exists in the correct location
- Make sure the font file is a valid TTF format
- Verify that the file name matches exactly: `Amiri-Regular.ttf` 