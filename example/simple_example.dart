import 'package:assetkamkaro/assetkamkaro.dart';
import 'dart:io';

/// A simple example demonstrating basic usage of AssetKamKaro.
///
/// This example shows how to:
/// 1. Create an optimizer instance
/// 2. Run optimization with custom settings
/// 3. Handle the results
void main() async {
  print('Starting AssetKamKaro optimization...');

  // Create optimizer with default settings
  final optimizer = AssetKamKaro(
    enableParallelProcessing: true,
    enableCache: true,
  );

  try {
    // Run optimization with custom settings
    final result = await optimizer.optimize(
      projectPath: Directory.current.path,
      compressionLevel: 'high',
      dryRun: false,
      backup: true,
      exclude: 'assets/icons,assets/raw',
    );

    // Print results
    print('\nOptimization complete!');
    print('Processed files: ${result.processedFiles}');
    print('Total bytes saved: ${result.totalSaved}');
    print('Duration: ${result.duration.inSeconds} seconds');

    if (result.unusedAssets.isNotEmpty) {
      print('\nUnused assets found:');
      for (final asset in result.unusedAssets) {
        print('- $asset');
      }
    }
  } catch (e) {
    print('Error during optimization: $e');
  }
}
