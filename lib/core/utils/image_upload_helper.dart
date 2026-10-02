import 'package:image_picker/image_picker.dart';

/// Helper terpusat untuk kompresi dan validasi upload berkas gambar bukti bayar.
class ImageUploadHelper {
  /// Batas ukuran berkas maksimum yang diizinkan (2 MB).
  static const int maxFileSizeBytes = 2 * 1024 * 1024;

  /// Dimensi lebar maksimum gambar struk (1440 px).
  static const double maxWidth = 1440.0;

  /// Dimensi tinggi maksimum gambar struk (1440 px).
  static const double maxHeight = 1440.0;

  /// Tingkat kompresi JPEG default (75%).
  static const int defaultImageQuality = 75;

  /// Pesan kesalahan yang ramah pengguna saat ukuran berkas melebihi batas.
  static const String maxFileSizeExceededMessage =
      'Ukuran file gambar bukti transfer terlalu besar (maksimal 2MB). Harap ambil ulang atau pilih foto lain.';

  /// Memvalidasi apakah ukuran file dalam batas wajar.
  static Future<bool> validateFileSize(
    XFile file, {
    int maxBytes = maxFileSizeBytes,
  }) async {
    final int length = await file.length();
    return length <= maxBytes;
  }

  /// Memilih gambar dengan kompresi bawaan image_picker untuk mencegah OOM di perangkat low-end.
  static Future<XFile?> pickImageWithCompression(
    ImagePicker picker, {
    required ImageSource source,
    double maxWidth = maxWidth,
    double maxHeight = maxHeight,
    int imageQuality = defaultImageQuality,
  }) async {
    return await picker.pickImage(
      source: source,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
    );
  }
}
