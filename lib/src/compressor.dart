import 'dart:io';
import 'package:image/image.dart' as img;
import 'types.dart';
import 'package:path/path.dart' as path;

/// A class that handles image compression with advanced optimization techniques.
class AssetCompressor {
  /// Maximum PNG compression level (0-9).
  static const int _maxPngCompression = 9;

  /// JPEG chroma subsampling (4:2:0).
  static const img.JpegChroma _jpegSubsample = img.JpegChroma.yuv420;

  /// Compresses an image file with advanced optimization techniques.
  ///
  /// [file] is the image file to compress.
  /// Returns a [CompressionResult] with compression details.
  Future<CompressionResult> compressImage(File file) async {
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) {
      throw Exception('Failed to decode image: ${file.path}');
    }

    final originalSize = bytes.length;
    final compressedBytes = _compressImage(image, file.path);
    final compressedSize = compressedBytes.length;
    final reduction = ((originalSize - compressedSize) / originalSize) * 100;

    await file.writeAsBytes(compressedBytes);

    return CompressionResult(
      originalSize: originalSize,
      compressedSize: compressedSize,
      reduction: reduction,
    );
  }

  List<int> _compressImage(img.Image image, String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    if (extension == '.png') {
      return _compressPng(image);
    } else if (extension == '.jpg' || extension == '.jpeg') {
      return _compressJpeg(image);
    } else {
      throw Exception('Unsupported image format: $extension');
    }
  }

  List<int> _compressPng(img.Image image) {
    return img.encodePng(
      image,
      level: _maxPngCompression,
    );
  }

  List<int> _compressJpeg(img.Image image) {
    return img.encodeJpg(
      image,
      quality: 85,
      chroma: _jpegSubsample,
    );
  }
}
