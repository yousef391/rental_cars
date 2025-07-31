import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageService {
  static final ImageService _instance = ImageService._internal();
  factory ImageService() => _instance;
  ImageService._internal();

  /// Pick an image file from the system
  Future<String?> pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'bmp'],
      );

      if (result != null && result.files.isNotEmpty) {
        return result.files.first.path;
      }
      return null;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  /// Save image to app's documents directory
  Future<String?> saveImage(String sourcePath, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${directory.path}/images');

      // Create images directory if it doesn't exist
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      final file = File(sourcePath);
      final extension = path.extension(sourcePath);
      final newFileName = '$fileName$extension';
      final newPath = '${imagesDir.path}/$newFileName';

      // Copy the file to the new location
      await file.copy(newPath);

      return newPath;
    } catch (e) {
      print('Error saving image: $e');
      return null;
    }
  }

  /// Load image from path
  Future<File?> loadImage(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) return null;

    try {
      final file = File(imagePath);
      if (await file.exists()) {
        return file;
      }
      return null;
    } catch (e) {
      print('Error loading image: $e');
      return null;
    }
  }

  /// Delete image file
  Future<bool> deleteImage(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) return true;

    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return true;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  /// Get image as bytes
  Future<Uint8List?> getImageBytes(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) return null;

    try {
      final file = File(imagePath);
      if (await file.exists()) {
        return await file.readAsBytes();
      }
      return null;
    } catch (e) {
      print('Error reading image bytes: $e');
      return null;
    }
  }

  /// Check if image exists
  Future<bool> imageExists(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) return false;

    try {
      final file = File(imagePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  /// Get file size in MB
  Future<double> getImageSize(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) return 0.0;

    try {
      final file = File(imagePath);
      if (await file.exists()) {
        final bytes = await file.length();
        return bytes / (1024 * 1024); // Convert to MB
      }
      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  /// Validate image file
  Future<bool> isValidImage(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) return false;

    try {
      final file = File(imagePath);
      if (!await file.exists()) return false;

      final extension = path.extension(imagePath).toLowerCase();
      final validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp'];

      return validExtensions.contains(extension);
    } catch (e) {
      return false;
    }
  }
}
