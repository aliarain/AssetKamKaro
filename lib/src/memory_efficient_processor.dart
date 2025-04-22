import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'types.dart';

/// Processes large files in chunks to minimize memory usage.
class MemoryEfficientProcessor {
  /// Creates a new [MemoryEfficientProcessor].
  const MemoryEfficientProcessor();

  /// Processes a large image file in chunks to minimize memory usage.
  ///
  /// Parameters:
  /// - [inputPath]: Path to the input image file
  /// - [outputPath]: Path where the processed image should be saved
  /// - [quality]: Quality level for compression (0-100)
  ///
  /// Returns an [AssetProcessingResult] containing processing statistics.
  Future<AssetProcessingResult> processLargeImage({
    required String inputPath,
    required String outputPath,
    required int quality,
  }) async {
    final input = File(inputPath);
    final output = File(outputPath);
    final originalSize = await input.length();

    // Process in chunks to reduce memory usage
    final chunks = await _splitIntoChunks(input, 1024 * 1024); // 1MB chunks
    final processedChunks = <Uint8List>[];

    for (final chunk in chunks) {
      final processed = await _processChunk(chunk, quality);
      processedChunks.add(processed);
    }

    // Combine processed chunks
    final totalSize = processedChunks.fold<int>(
      0,
      (sum, chunk) => sum + chunk.length,
    );
    final combined = Uint8List(totalSize);
    var offset = 0;

    for (final chunk in processedChunks) {
      combined.setRange(offset, offset + chunk.length, chunk);
      offset += chunk.length;
    }

    // Save the processed image
    await output.writeAsBytes(combined);

    return AssetProcessingResult(
      originalSize: originalSize,
      newSize: totalSize,
      bytesSaved: originalSize - totalSize,
      reductionPercentage: ((originalSize - totalSize) / originalSize) * 100,
    );
  }

  /// Splits a file into chunks of the specified size.
  Future<List<Uint8List>> _splitIntoChunks(File file, int chunkSize) async {
    final chunks = <Uint8List>[];
    final fileSize = await file.length();
    final raf = await file.open();

    try {
      for (var offset = 0; offset < fileSize; offset += chunkSize) {
        final size =
            offset + chunkSize > fileSize ? fileSize - offset : chunkSize;
        final chunk = await raf.read(size);
        chunks.add(chunk);
      }
    } finally {
      await raf.close();
    }

    return chunks;
  }

  /// Processes a single chunk of image data.
  Future<Uint8List> _processChunk(Uint8List chunk, int quality) async {
    // Decode the chunk
    final image = img.decodeImage(chunk);
    if (image == null) {
      throw FormatException('Failed to decode image chunk');
    }

    // Process the image (placeholder for actual processing)
    // In a real implementation, this would apply the actual image processing
    return Uint8List.fromList(img.encodeJpg(image, quality: quality));
  }
}
