import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rentra/data/services/image_service.dart';
import 'package:rentra/data/services/localization_service.dart';

class ImagePickerWidget extends StatefulWidget {
  final String? currentImagePath;
  final String title;
  final String subtitle;
  final IconData icon;
  final Function(String?) onImageSelected;
  final double? width;
  final double? height;

  const ImagePickerWidget({
    super.key,
    this.currentImagePath,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onImageSelected,
    this.width,
    this.height,
  });

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  final ImageService _imageService = ImageService();
  final LocalizationService _localizationService = LocalizationService();
  String? _selectedImagePath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedImagePath = widget.currentImagePath;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _localizationService,
      builder: (context, child) {
        return Container(
          width: widget.width ?? 200.w,
          height: widget.height ?? 200.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.r),
                    topRight: Radius.circular(16.r),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.icon,
                      color: Colors.blue.shade600,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          Text(
                            widget.subtitle,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Image Display Area
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(16.w),
                  child: _isLoading
                      ? _buildLoadingState()
                      : _selectedImagePath != null
                          ? _buildImageDisplay()
                          : _buildEmptyState(),
                ),
              ),

              // Action Buttons
              Container(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        _localizationService
                            .translate('image_picker.select_image'),
                        Icons.add_photo_alternate,
                        Colors.blue,
                        _pickImage,
                      ),
                    ),
                    if (_selectedImagePath != null) ...[
                      SizedBox(width: 8.w),
                      Expanded(
                        child: _buildActionButton(
                          _localizationService.translate('forms.remove'),
                          Icons.delete,
                          Colors.red,
                          _removeImage,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 32.w,
            height: 32.w,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            _localizationService.translate('image_picker.processing_image'),
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              widget.icon,
              size: 48.sp,
              color: Colors.grey.shade400,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            _localizationService.translate('image_picker.no_image_selected'),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            _localizationService.translate('image_picker.click_to_add'),
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageDisplay() {
    return FutureBuilder<File?>(
      future: _imageService.loadImage(_selectedImagePath),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (snapshot.hasData && snapshot.data != null) {
          return Stack(
            children: [
              // Image
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.file(
                    snapshot.data!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildErrorState();
                    },
                  ),
                ),
              ),
              // Image info overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(12.r),
                      bottomRight: Radius.circular(12.r),
                    ),
                  ),
                  child: FutureBuilder<double>(
                    future: _imageService.getImageSize(_selectedImagePath),
                    builder: (context, sizeSnapshot) {
                      return Text(
                        sizeSnapshot.hasData
                            ? '${_localizationService.translate('image_picker.size')}: ${sizeSnapshot.data!.toStringAsFixed(2)} MB'
                            : _localizationService
                                .translate('image_picker.image_loaded'),
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        }

        return _buildErrorState();
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48.sp,
            color: Colors.red.shade400,
          ),
          SizedBox(height: 16.h),
          Text(
            _localizationService.translate('image_picker.failed_to_load'),
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.red.shade600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            _localizationService.translate('image_picker.select_new_image'),
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, size: 18.sp, color: color),
              SizedBox(height: 4.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final imagePath = await _imageService.pickImage();

      if (imagePath != null) {
        // Validate the image
        final isValid = await _imageService.isValidImage(imagePath);
        if (!isValid) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_localizationService
                    .translate('image_picker.valid_image_file')),
                backgroundColor: Colors.red.shade600,
              ),
            );
          }
          return;
        }

        // Check file size (max 10MB)
        final fileSize = await _imageService.getImageSize(imagePath);
        if (fileSize > 10.0) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_localizationService
                    .translate('image_picker.image_size_limit')),
                backgroundColor: Colors.red.shade600,
              ),
            );
          }
          return;
        }

        setState(() {
          _selectedImagePath = imagePath;
        });

        widget.onImageSelected(imagePath);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${_localizationService.translate('image_picker.error_selecting')}: $e'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _removeImage() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Delete the old image if it exists
      if (_selectedImagePath != null) {
        await _imageService.deleteImage(_selectedImagePath);
      }

      setState(() {
        _selectedImagePath = null;
      });

      widget.onImageSelected(null);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${_localizationService.translate('image_picker.error_removing')}: $e'),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
