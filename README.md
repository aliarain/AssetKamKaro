<div align="center">

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="assets/logo_dark.svg">
  <source media="(prefers-color-scheme: light)" srcset="assets/logo.svg">
  <img alt="AssetKamKaro Logo" src="assets/logo.png" width="200" height="200">
</picture>

# AssetKamKaro

A powerful Flutter package for optimizing and managing assets in your Flutter project. AssetKamKaro helps reduce app size, improve loading times, and maintain clean asset management.

## Features

- 🚀 **Advanced Asset Optimization**
  - Smart image compression with quality control
  - Support for multiple formats (JPEG, PNG, WebP)
  - Customizable compression settings
  - Memory-efficient processing

- 🔍 **Asset Analysis**
  - Detailed asset usage analysis
  - Unused asset detection
  - Size reduction reporting
  - Performance metrics

- ⚡ **Performance**
  - Parallel processing for faster optimization
  - Memory-efficient algorithms
  - Asset caching system
  - Progress reporting

- 🛠️ **Developer Tools**
  - Command-line interface (CLI)
  - Configuration file support
  - Backup functionality
  - Comprehensive error handling

## Installation

Add AssetKamKaro to your `pubspec.yaml`:

```yaml
dependencies:
  assetkamkaro: ^0.1.0
```

Then run:
```bash
flutter pub get
```

## Usage

### Basic Usage

```dart
import 'package:assetkamkaro/assetkamkaro.dart';

void main() async {
  final optimizer = AssetKamKaro();
  final result = await optimizer.optimize(
    projectPath: 'path/to/your/flutter/project',
    compressionLevel: CompressionLevel.medium,
  );
  
  print('Optimization complete!');
  print('Total size reduction: ${result.totalSizeReduction}');
  print('Unused assets found: ${result.unusedAssets.length}');
}
```

### Command Line Interface

```bash
# Basic optimization
dart run assetkamkaro optimize

# With specific compression level
dart run assetkamkaro optimize --compression high

# Dry run to analyze without making changes
dart run assetkamkaro optimize --dry-run

# Delete unused assets
dart run assetkamkaro optimize --delete-unused

# Exclude specific directories
dart run assetkamkaro optimize --exclude assets/icons,assets/backgrounds
```

### Configuration

Create a `config.yaml` file in your project root:

```yaml
compression:
  level: high
  jpeg:
    quality: 80
    subsampling: yuv420
  png:
    level: 9
    filter: 0

exclude:
  - assets/icons
  - assets/backgrounds

backup: true
delete_unused: false
```

## API Reference

### AssetKamKaro

The main class for asset optimization.

```dart
class AssetKamKaro {
  /// Creates a new AssetKamKaro instance
  AssetKamKaro({
    String? configPath,
    bool enableCache = true,
  });

  /// Optimizes assets in the specified project
  Future<OptimizationResult> optimize({
    required String projectPath,
    CompressionLevel compressionLevel = CompressionLevel.medium,
    bool dryRun = false,
    bool createBackup = true,
    List<String> excludePatterns = const [],
    bool deleteUnused = false,
  });
}
```

### CompressionLevel

Enum defining compression levels:

```dart
enum CompressionLevel {
  low,    // Minimal compression, highest quality
  medium, // Balanced compression and quality
  high,   // Maximum compression, lower quality
}
```

### OptimizationResult

Result of the optimization process:

```dart
class OptimizationResult {
  final int totalSizeReduction;
  final int totalAssetsProcessed;
  final List<String> unusedAssets;
  final Map<String, CompressionResult> compressionResults;
}
```

## Best Practices

1. **Backup Your Assets**
   - Always enable backup when running optimization
   - Keep a copy of original assets in version control

2. **Compression Settings**
   - Use medium compression for most cases
   - Test high compression on a subset of images first
   - Consider using different settings for different asset types

3. **Asset Organization**
   - Keep assets in well-organized directories
   - Use meaningful file names
   - Document asset usage in code

4. **Performance**
   - Run optimization during CI/CD pipeline
   - Cache optimization results
   - Monitor app size changes

## Contributing

Contributions are welcome! Please read our [contributing guidelines](CONTRIBUTING.md) before submitting pull requests.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

If you find a bug or have a feature request, please [open an issue](https://github.com/yourusername/assetkamkaro/issues).

## Acknowledgments

- [image](https://pub.dev/packages/image) package for image processing
- [path](https://pub.dev/packages/path) package for path handling
- [yaml](https://pub.dev/packages/yaml) package for configuration
- [args](https://pub.dev/packages/args) package for CLI support
