import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_sikesan_flutter/core/utils/image_upload_helper.dart';

void main() {
  group('ImageUploadHelper Tests', () {
    test('constants have expected production optimization values', () {
      expect(ImageUploadHelper.maxWidth, 1440.0);
      expect(ImageUploadHelper.maxHeight, 1440.0);
      expect(ImageUploadHelper.defaultImageQuality, 75);
      expect(ImageUploadHelper.maxFileSizeBytes, 2 * 1024 * 1024);
      expect(
        ImageUploadHelper.maxFileSizeExceededMessage,
        contains('maksimal 2MB'),
      );
    });

    test('validateFileSize accepts files within 2 MB limit', () async {
      // Create a mock XFile with 1 MB of bytes
      final smallData = Uint8List(1024 * 1024); // 1 MB
      final smallFile = XFile.fromData(smallData, name: 'receipt.jpg');

      final isValid = await ImageUploadHelper.validateFileSize(smallFile);
      expect(isValid, isTrue);
    });

    test('validateFileSize rejects files exceeding 2 MB limit', () async {
      // Create a mock XFile with 3 MB of bytes
      final largeData = Uint8List(3 * 1024 * 1024); // 3 MB
      final largeFile = XFile.fromData(largeData, name: 'large_photo.jpg');

      final isValid = await ImageUploadHelper.validateFileSize(largeFile);
      expect(isValid, isFalse);
    });

    test('validateFileSize accepts exactly 2 MB boundary', () async {
      final boundaryData = Uint8List(2 * 1024 * 1024); // exactly 2 MB
      final boundaryFile = XFile.fromData(boundaryData, name: 'boundary.jpg');

      final isValid = await ImageUploadHelper.validateFileSize(boundaryFile);
      expect(isValid, isTrue);
    });
  });
}
