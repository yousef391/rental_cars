# Downloads Folder

This folder contains the downloadable files for the CarRental Pro system.

## Required Files

Place the following files in this folder:

### 1. CarRentalPro-Windows.zip
- Windows executable version of the application
- Should contain the compiled Flutter Windows app
- Size: Approximately 45-50 MB

### 2. CarRentalPro-Source.zip
- Complete source code of the Flutter project
- Should include all source files, assets, and documentation
- Size: Approximately 10-15 MB

### 3. CarRentalPro-Docs.pdf
- Complete user manual and documentation
- Should include installation guide, user guide, and API documentation
- Size: Approximately 2-5 MB

## File Structure

```
downloads/
├── CarRentalPro-Windows.zip    # Windows executable
├── CarRentalPro-Source.zip     # Source code
├── CarRentalPro-Docs.pdf       # Documentation
└── README.txt                  # This file
```

## Creating the Files

### Windows Executable
1. Build the Flutter project for Windows:
   ```bash
   flutter build windows
   ```
2. Zip the build output from `build/windows/runner/Release/`
3. Name it `CarRentalPro-Windows.zip`

### Source Code
1. Create a zip file of the entire project folder
2. Exclude build folders and temporary files
3. Name it `CarRentalPro-Source.zip`

### Documentation
1. Create a comprehensive PDF manual
2. Include screenshots and step-by-step instructions
3. Name it `CarRentalPro-Docs.pdf`

## Notes

- Ensure all files are properly compressed
- Test download links after uploading files
- Update file sizes in the website HTML if they change
- Consider adding version numbers to filenames for updates 