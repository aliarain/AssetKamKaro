import 'dart:io';
import 'package:args/args.dart';
import 'package:yaml/yaml.dart';
import '../assetkamkaro.dart';
import 'types.dart';

/// Command-line interface for AssetKamKaro.
class AssetKamKaroCli {
  final ArgParser _parser;

  AssetKamKaroCli() : _parser = ArgParser() {
    _parser
      ..addOption(
        'compression',
        abbr: 'c',
        help: 'Compression level (low, medium, high)',
        defaultsTo: 'medium',
      )
      ..addFlag(
        'dry-run',
        abbr: 'd',
        help: 'Analyze without making changes',
        defaultsTo: false,
      )
      ..addFlag(
        'backup',
        abbr: 'b',
        help: 'Create backup before optimization',
        defaultsTo: true,
      )
      ..addMultiOption(
        'exclude',
        abbr: 'e',
        help: 'Directories to exclude from optimization',
        defaultsTo: const [],
      )
      ..addFlag(
        'delete-unused',
        abbr: 'D',
        help: 'Delete unused assets',
        defaultsTo: false,
      )
      ..addOption(
        'config',
        help: 'Path to configuration file',
        defaultsTo: 'config.yaml',
      );
  }

  Future<void> run(List<String> arguments) async {
    try {
      final results = _parser.parse(arguments);
      final config = await _loadConfig(results['config'] as String);

      final optimizer = AssetKamKaro();
      final result = await optimizer.optimize(
        projectPath: Directory.current.path,
        compressionLevel:
            _parseCompressionLevel(results['compression'] as String),
        dryRun: results['dry-run'] as bool,
        createBackup: results['backup'] as bool,
        excludePatterns: results['exclude'] as List<String>,
        deleteUnused: results['delete-unused'] as bool,
      );

      print(result);
    } catch (e) {
      print('Error: $e');
      print(_parser.usage);
      exit(1);
    }
  }

  Future<Map<String, dynamic>> _loadConfig(String configPath) async {
    try {
      final file = File(configPath);
      if (await file.exists()) {
        final content = await file.readAsString();
        return loadYaml(content) as Map<String, dynamic>;
      }
    } catch (e) {
      print('Warning: Could not load config file: $e');
    }
    return {};
  }

  CompressionLevel _parseCompressionLevel(String level) {
    switch (level.toLowerCase()) {
      case 'low':
        return CompressionLevel.low;
      case 'high':
        return CompressionLevel.high;
      case 'medium':
      default:
        return CompressionLevel.medium;
    }
  }
}
