import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;
import 'dart:typed_data';
import 'types.dart';

/// Handles compression of image assets with advanced optimization techniques.
class AssetCompressor {
  /// Advanced compression settings
  static const int _pngCompressionLevel = 9; // Maximum ZIP compression for PNG
  static const img.JpegChroma _jpegSubsample =
      img.JpegChroma.yuv420; // 4:2:0 chroma subsampling

  /// Compresses an image file using advanced techniques.
  ///
  /// Parameters:
  /// - [inputFile]: Path to the input image file
  /// - [outputFile]: Path where the compressed image should be saved
  /// - [level]: Compression level ('low', 'medium', 'high')
  ///
  /// Returns a [CompressionResult] containing compression statistics.
  Future<CompressionResult> compressImage({
    required String inputFile,
    required String outputFile,
    required String level,
  }) async {
    final input = File(inputFile);
    final output = File(outputFile);

    if (!input.existsSync()) {
      throw FileSystemException('Input file not found: $inputFile');
    }

    final originalBytes = await input.readAsBytes();
    final originalSize = originalBytes.length;

    // Decode the image with high-quality settings
    final image = img.decodeImage(originalBytes);
    if (image == null) {
      throw FormatException('Failed to decode image: $inputFile');
    }

    final extension = path.extension(inputFile).toLowerCase();
    late Uint8List compressedBytes;

    // Apply format-specific optimizations
    if (extension == '.png') {
      compressedBytes = await _optimizePng(image, level);
    } else if (extension == '.jpg' || extension == '.jpeg') {
      compressedBytes = await _optimizeJpeg(image, level);
    } else {
      throw UnsupportedError('Unsupported image format: $extension');
    }

    final compressedSize = compressedBytes.length;
    final reduction = ((originalSize - compressedSize) / originalSize) * 100;

    // Save the optimized image
    await output.writeAsBytes(compressedBytes);

    return CompressionResult(
      originalSize: originalSize,
      compressedSize: compressedSize,
      reduction: reduction,
      format: extension.substring(1),
    );
  }

  /// Advanced PNG optimization
  Future<Uint8List> _optimizePng(img.Image image, String level) async {
    // Apply intelligent color quantization if needed
    img.Image optimizedImage = image;

    if (level == 'high') {
      // Reduce colors intelligently while maintaining quality
      final palette = img.quantize(image, numberOfColors: 256);
      optimizedImage = img.copyResize(
        palette,
        width: image.width,
        height: image.height,
        interpolation: img.Interpolation.cubic,
      );
    }

    // Apply advanced PNG compression
    return Uint8List.fromList(
      img.encodePng(
        optimizedImage,
        level: _pngCompressionLevel,
        filter: img.PngFilter.paeth, // Advanced filtering
      ),
    );
  }

  /// Advanced JPEG optimization
  Future<Uint8List> _optimizeJpeg(img.Image image, String level) async {
    final quality = getQualityForLevel(level);

    // Apply advanced chroma subsampling
    return Uint8List.fromList(
      img.encodeJpg(image, quality: quality, chroma: _jpegSubsample),
    );
  }

  /// Gets optimized quality levels based on compression strategy
  int getQualityForLevel(String level) {
    switch (level.toLowerCase()) {
      case 'low':
        return 92; // Very high quality, minimal compression
      case 'medium':
        return 85; // Balanced quality and compression
      case 'high':
        return 78; // Higher compression while maintaining good quality
      default:
        throw ArgumentError('Invalid compression level: $level');
    }
  }

  /// Determines if a file is an image that can be compressed
  bool isCompressibleImage(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    return extension == '.jpg' || extension == '.jpeg' || extension == '.png';
  }
}

/// Represents the result of a compression operation
class CompressionResult {
  /// Creates a new [CompressionResult].
  const CompressionResult({
    required this.originalSize,
    required this.compressedSize,
    required this.reduction,
    required this.format,
  });

  /// Original size of the file in bytes.
  final int originalSize;

  /// Size after compression in bytes.
  final int compressedSize;

  /// Percentage reduction in size.
  final double reduction;

  /// File format (e.g., 'png', 'jpg').
  final String format;

  @override
  String toString() {
    return '''
    Format: $format
    Original Size: ${(originalSize / 1024).toStringAsFixed(2)} KB
    Compressed Size: ${(compressedSize / 1024).toStringAsFixed(2)} KB
    Reduction: ${reduction.toStringAsFixed(2)}%
    ''';
  }
}
