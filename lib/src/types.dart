/// Represents the result of processing a single asset.
class AssetProcessingResult {
  /// Creates a new [AssetProcessingResult].
  const AssetProcessingResult({
    required this.originalSize,
    required this.newSize,
    required this.bytesSaved,
    required this.reductionPercentage,
  });

  /// Original size of the asset in bytes.
  final int originalSize;

  /// New size of the asset after optimization in bytes.
  final int newSize;

  /// Number of bytes saved.
  final int bytesSaved;

  /// Percentage reduction in size.
  final double reductionPercentage;
}

/// Enum representing different compression levels for image optimization.
enum CompressionLevel {
  /// Low compression, minimal quality loss
  low,

  /// Medium compression, balanced quality and size
  medium,

  /// High compression, maximum size reduction
  high
}

/// Represents metadata for an asset file.
class AssetMetadata {
  /// The path to the asset relative to the project root.
  final String path;

  /// The type of asset (e.g., 'image', 'font', etc.).
  final String type;

  /// The size of the asset in bytes.
  final int size;

  /// Creates a new [AssetMetadata] instance.
  const AssetMetadata({
    required this.path,
    required this.type,
    required this.size,
  });
}

/// Represents the result of analyzing assets in a project.
class AssetAnalysis {
  /// Map of asset paths to their metadata.
  final Map<String, AssetMetadata> assets;

  /// List of unused asset paths.
  final List<String> unusedAssets;

  /// Creates a new [AssetAnalysis] instance.
  const AssetAnalysis({
    required this.assets,
    required this.unusedAssets,
  });
}

/// Result of a compression operation.
class CompressionResult {
  /// Creates a new compression result.
  const CompressionResult({
    required this.originalSize,
    required this.compressedSize,
    required this.reduction,
  });

  /// Original size in bytes.
  final int originalSize;

  /// Compressed size in bytes.
  final int compressedSize;

  /// Percentage reduction in size.
  final double reduction;

  @override
  String toString() {
    return '''
Original Size: ${(originalSize / 1024).toStringAsFixed(2)} KB
Compressed Size: ${(compressedSize / 1024).toStringAsFixed(2)} KB
Reduction: ${reduction.toStringAsFixed(2)}%
''';
  }
}

/// Represents the result of optimizing assets in a project.
class OptimizationResult {
  /// Total size reduction in bytes.
  final int totalSizeReduction;

  /// Total number of assets processed.
  final int totalAssetsProcessed;

  /// List of unused assets found.
  final List<String> unusedAssets;

  /// Map of asset paths to their compression results.
  final Map<String, CompressionResult> compressionResults;

  /// Creates a new [OptimizationResult] instance.
  const OptimizationResult({
    required this.totalSizeReduction,
    required this.totalAssetsProcessed,
    required this.unusedAssets,
    required this.compressionResults,
  });

  @override
  String toString() {
    final kbSaved = totalSizeReduction / 1024;
    return 'Optimization complete!\n'
        'Total assets processed: $totalAssetsProcessed\n'
        'Total size reduction: ${kbSaved.toStringAsFixed(2)} KB\n'
        'Unused assets found: ${unusedAssets.length}';
  }
}
