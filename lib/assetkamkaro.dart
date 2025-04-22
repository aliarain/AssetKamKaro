/// A Flutter package for optimizing assets and reducing app size.
///
/// This library provides tools for compressing images and detecting unused assets
/// in Flutter projects.
library assetkamkaro;

export 'src/validator.dart';
export 'src/cli.dart';
export 'src/types.dart';

import 'dart:io';
import 'package:path/path.dart' as path;
import 'src/compressor.dart';
import 'src/validator.dart';
import 'src/cache_manager.dart';
import 'src/types.dart';
import 'src/progress_reporter.dart';

/// Main class for asset optimization in Flutter projects.
class AssetKamKaro {
  final AssetCompressor _compressor;
  final AssetValidator _validator;
  final CacheManager _cacheManager;

  /// Creates a new [AssetKamKaro] instance.
  AssetKamKaro({
    String? configPath,
    bool enableCache = true,
  })  : _compressor = AssetCompressor(),
        _validator = const AssetValidator(),
        _cacheManager =
            enableCache ? CacheManager() : CacheManager(cacheDir: null);

  /// Optimizes assets in the specified project.
  ///
  /// [projectPath] is the path to the Flutter project root.
  /// [compressionLevel] determines the compression intensity.
  /// [dryRun] if true, analyzes without making changes.
  /// [createBackup] if true, creates backups before optimization.
  /// [excludePatterns] list of patterns to exclude from optimization.
  /// [deleteUnused] if true, deletes unused assets.
  ///
  /// Returns an [OptimizationResult] containing optimization details.
  Future<OptimizationResult> optimize({
    required String projectPath,
    required CompressionLevel compressionLevel,
    bool dryRun = false,
    bool createBackup = true,
    List<String> excludePatterns = const [],
    bool deleteUnused = false,
  }) async {
    final analysis = await _validator.analyzeAssets(projectPath);
    final compressionResults = <String, CompressionResult>{};
    var totalSizeReduction = 0;

    for (final entry in analysis.assets.entries) {
      final asset = entry.value;
      if (asset.type == 'image' && !_isExcluded(asset.path, excludePatterns)) {
        final file = File(path.join(projectPath, asset.path));
        final result = await _compressor.compressImage(file);
        compressionResults[asset.path] = result;
        totalSizeReduction += result.originalSize - result.compressedSize;
      }
    }

    return OptimizationResult(
      totalSizeReduction: totalSizeReduction,
      totalAssetsProcessed: analysis.assets.length,
      unusedAssets: analysis.unusedAssets,
      compressionResults: compressionResults,
    );
  }

  bool _isExcluded(String path, List<String> excludePatterns) {
    return excludePatterns.any((pattern) => path.contains(pattern));
  }
}
