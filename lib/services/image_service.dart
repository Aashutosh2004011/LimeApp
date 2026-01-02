import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ImageService {
  static const _uuid = Uuid();
  static const int maxFileSizeKB = 200;

  static Future<String?> pickAndCompressImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
    );

    if (pickedFile == null) return null;

    final file = File(pickedFile.path);
    final compressedPath = await _compressImage(file);

    return compressedPath;
  }

  static Future<String> _compressImage(File file) async {
    // Read image
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);

    if (image == null) return file.path;

    // Start with quality 85
    int quality = 85;
    List<int> compressedBytes = img.encodeJpg(image, quality: quality);

    // Reduce quality until size is acceptable
    while (compressedBytes.length > maxFileSizeKB * 1024 && quality > 20) {
      quality -= 10;
      compressedBytes = img.encodeJpg(image, quality: quality);
    }

    // If still too large, resize
    if (compressedBytes.length > maxFileSizeKB * 1024) {
      final resized = img.copyResize(image, width: 800);
      compressedBytes = img.encodeJpg(resized, quality: 70);
    }

    // Save compressed image
    final directory = await getApplicationDocumentsDirectory();
    final fileName = '${_uuid.v4()}.jpg';
    final compressedFile = File('${directory.path}/$fileName');
    await compressedFile.writeAsBytes(compressedBytes);

    return compressedFile.path;
  }

  static Future<void> deleteImage(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Ignore errors
    }
  }
}