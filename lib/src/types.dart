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

/// Represents the overall result of an optimization run.
class OptimizationResult {
  /// Creates a new [OptimizationResult].
  const OptimizationResult({
    required this.processedFiles,
    required this.totalSaved,
    required this.duration,
    required this.unusedAssets,
  });

  /// Number of files processed.
  final int processedFiles;

  /// Total bytes saved across all files.
  final int totalSaved;

  /// Time taken for optimization.
  final Duration duration;

  /// List of unused assets found during optimization.
  final List<String> unusedAssets;

  /// Returns a human-readable string representation.
  @override
  String toString() {
    final savedMB = (totalSaved / (1024 * 1024)).toStringAsFixed(2);
    return '''
Optimization complete:
- Files processed: $processedFiles
- Total size saved: $savedMB MB
- Time taken: ${duration.inSeconds} seconds
- Unused assets found: ${unusedAssets.length}
''';
  }
}

/// Asset analysis result.
class AssetAnalysis {
  /// Creates a new [AssetAnalysis].
  const AssetAnalysis({required this.assets, required this.unusedAssets});

  /// Map of asset paths to their metadata.
  final Map<String, AssetMetadata> assets;

  /// List of unused asset paths.
  final List<String> unusedAssets;
}

/// Metadata about an asset.
class AssetMetadata {
  /// Creates new [AssetMetadata].
  const AssetMetadata({
    required this.path,
    required this.size,
    required this.type,
  });

  /// Path to the asset relative to project root.
  final String path;

  /// Size of the asset in bytes.
  final int size;

  /// Type of asset (e.g., 'image', 'font').
  final String type;
}
