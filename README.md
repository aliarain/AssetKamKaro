<div align="center">

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="assets/logo_dark.svg">
  <source media="(prefers-color-scheme: light)" srcset="assets/logo.svg">
  <img alt="AssetKamKaro Logo" src="assets/logo.png" width="200" height="200">
</picture>

# AssetKamKaro 🚀

[![pub package](https://img.shields.io/pub/v/assetkamkaro.svg)](https://pub.dev/packages/assetkamkaro)
[![likes](https://img.shields.io/pub/likes/assetkamkaro?logo=dart)](https://pub.dev/packages/assetkamkaro/score)
[![popularity](https://img.shields.io/pub/popularity/assetkamkaro?logo=dart)](https://pub.dev/packages/assetkamkaro/score)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue.svg)](https://flutter.dev)

A blazing fast 🔥 Flutter asset optimization package that helps you reduce your app size by compressing assets and removing unused ones. Built with performance in mind.

## Features 💫

- 🎯 **Smart Asset Compression**
  - Up to 70% size reduction while maintaining quality
  - Supports PNG, JPEG, and font files (TTF/OTF)
  - Intelligent compression algorithms
  
- 🔍 **Unused Asset Detection**
  - Finds unused assets in your project
  - Smart detection with regex patterns
  - Configurable exclusion rules
  
- ⚡ **Lightning Fast Processing**
  - Parallel processing for better performance
  - Optimized for large projects
  - Memory-efficient operations

- 🎮 **Easy-to-use CLI**
  - Simple commands
  - Configurable options
  - Progress tracking

## Installation 📦

Add to your `pubspec.yaml`:

```yaml
dev_dependencies:
  assetkamkaro: ^1.0.0
```

Or install via command line:

```bash
flutter pub add --dev assetkamkaro
```

## Quick Start 🚀

1. **Basic Usage**

```bash
flutter pub run assetkamkaro optimize
```

2. **With Options**

```bash
flutter pub run assetkamkaro optimize --compression=high --exclude=assets/fonts
```

## Advanced Usage 🛠️

### 1. Configuration File

Create `.assetkamkaro.yaml` in your project root:

```yaml
compression: medium  # low, medium, high
exclude:
  - assets/icons/
  - assets/fonts/
report_path: reports/assets.json
dry_run: false
delete_unused: false
```

### 2. Compression Levels

```bash
# Low compression (90% quality)
flutter pub run assetkamkaro optimize --compression=low

# Medium compression (85% quality)
flutter pub run assetkamkaro optimize --compression=medium

# High compression (78% quality)
flutter pub run assetkamkaro optimize --compression=high
```

### 3. Asset Validation

```bash
# Find unused assets
flutter pub run assetkamkaro validate

# Find and delete unused assets
flutter pub run assetkamkaro validate --delete

# Generate detailed report
flutter pub run assetkamkaro validate --report
```

### 4. Programmatic Usage

```dart
import 'package:assetkamkaro/assetkamkaro.dart';

void main() async {
  final compressor = AssetCompressor();
  
  // Compress single image
  final result = await compressor.compressImage(
    inputFile: 'assets/image.png',
    outputFile: 'assets/image_compressed.png',
    level: 'medium',
  );
  
  print('Reduced size by ${result.reduction}%');
  
  // Validate assets
  final validator = AssetValidator();
  final unusedAssets = await validator.findUnusedAssets(
    projectPath: '.',
    exclude: ['assets/fonts'],
  );
  
  print('Found ${unusedAssets.length} unused assets');
}
```

## Performance Tips 🎯

1. **Use Appropriate Compression Levels**
   - `low`: For high-quality images (logos, hero images)
   - `medium`: For general assets
   - `high`: For background images and textures

2. **Exclude Unnecessary Directories**
   ```bash
   flutter pub run assetkamkaro optimize --exclude=test,assets/raw
   ```

3. **Batch Processing**
   ```bash
   flutter pub run assetkamkaro optimize --batch-size=10
   ```

## Benchmarks 📊

| Asset Type | Original Size | Compressed Size | Reduction |
|------------|--------------|-----------------|-----------|
| PNG Images | 1.0 MB       | 300 KB         | 70%       |
| JPEG Images| 2.0 MB       | 700 KB         | 65%       |
| Fonts (TTF)| 1.5 MB       | 900 KB         | 40%       |

## Contributing 🤝

Contributions are welcome! Please read our [contributing guidelines](CONTRIBUTING.md).

## License 📄

MIT License - see the [LICENSE](LICENSE) file for details.

## Author ✨

Built with 💙 by [Ali Arain](https://github.com/aliarain)

---

If you find this package helpful, please give it a ⭐️ on [GitHub](https://github.com/aliarain/assetkamkaro)!
