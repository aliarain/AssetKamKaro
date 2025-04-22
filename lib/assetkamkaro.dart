/// A Flutter package for optimizing assets and reducing app size.
///
/// This library provides tools for compressing images and detecting unused assets
/// in Flutter projects.
library assetkamkaro;

export 'src/compressor.dart';
export 'src/validator.dart';
export 'src/cli.dart';
export 'src/types.dart';

import 'dart:io';
import 'dart:async';
import 'package:path/path.dart' as path;
import 'src/compressor.dart';
import 'src/validator.dart';
import 'src/types.dart';
import 'src/progress_reporter.dart';

/// Main class for asset optimization in Flutter projects.
class AssetKamKaro {
  /// Creates a new instance of [AssetKamKaro].
  AssetKamKaro({this.enableParallelProcessing = true, this.enableCache = true});

  /// Whether to enable parallel processing for faster optimization.
  final bool enableParallelProcessing;

  /// Whether to enable caching of processed assets.
  final bool enableCache;

  final AssetCompressor _compressor = AssetCompressor();
  final AssetValidator _validator = AssetValidator();
  final ProgressReporter _reporter = ProgressReporter();

  /// Optimizes assets in the given Flutter project.
  ///
  /// Parameters:
  /// - [projectPath]: Path to the Flutter project root directory
  /// - [compressionLevel]: Compression level ('low', 'medium', 'high')
  /// - [dryRun]: If true, simulates optimization without making changes
  /// - [backup]: If true, creates backups of original files
  /// - [exclude]: Comma-separated list of directories to exclude
  ///
  /// Returns an [OptimizationResult] containing statistics about the optimization.
  Future<OptimizationResult> optimize({
    required String projectPath,
    String compressionLevel = 'medium',
    bool dryRun = false,
    bool backup = true,
    String? exclude,
  }) async {
    final stopwatch = Stopwatch()..start();
    final analysis = await _validator.analyzeAssets(projectPath);
    final assets = analysis.assets;
    final quality = _compressor.getQualityForLevel(compressionLevel);

    _reporter.start(assets.length);
    int processedCount = 0;
    int totalSaved = 0;

    for (final entry in assets.entries) {
      final assetPath = entry.value.path;

      if (_shouldSkipAsset(assetPath, exclude)) {
        _reporter.skip();
        continue;
      }

      final result = await _processAsset(
        projectPath: projectPath,
        assetPath: assetPath,
        level: compressionLevel,
        dryRun: dryRun,
        backup: backup,
      );

      if (result != null) {
        totalSaved += result.bytesSaved;
        processedCount++;
      }

      _reporter.increment();
    }

    stopwatch.stop();

    return OptimizationResult(
      processedFiles: processedCount,
      totalSaved: totalSaved,
      duration: stopwatch.elapsed,
      unusedAssets: analysis.unusedAssets,
    );
  }

  bool _shouldSkipAsset(String assetPath, String? exclude) {
    if (!_compressor.isCompressibleImage(assetPath)) {
      return true;
    }

    if (exclude != null) {
      return exclude.split(',').any((dir) => assetPath.startsWith(dir.trim()));
    }

    return false;
  }

  Future<AssetProcessingResult?> _processAsset({
    required String projectPath,
    required String assetPath,
    required String level,
    required bool dryRun,
    required bool backup,
  }) async {
    final inputFile = File(path.join(projectPath, assetPath));
    final outputFile = File(path.join(projectPath, '$assetPath.optimized'));

    try {
      if (backup && !dryRun) {
        await _createBackup(inputFile);
      }

      final result = await _compressor.compressImage(
        inputFile: inputFile.path,
        outputFile: outputFile.path,
        level: level,
      );

      if (!dryRun) {
        await outputFile.rename(inputFile.path);
      }

      return AssetProcessingResult(
        originalSize: result.originalSize,
        newSize: result.compressedSize,
        bytesSaved: result.originalSize - result.compressedSize,
        reductionPercentage: result.reduction,
      );
    } catch (e) {
      _reporter.error(assetPath, e.toString());
      return null;
    }
  }

  Future<void> _createBackup(File inputFile) async {
    final backupFile = File('${inputFile.path}.bak');
    await inputFile.copy(backupFile.path);
  }
}
