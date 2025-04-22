import 'dart:io';
import 'package:args/args.dart';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';
import '../assetkamkaro.dart';
import 'types.dart';

/// Command-line interface for the AssetKamKaro package.
class AssetKamKaroCli {
  /// Creates a new [AssetKamKaroCli].
  const AssetKamKaroCli();

  /// Runs the CLI with the given arguments.
  Future<void> run(List<String> args) async {
    final parser =
        ArgParser()
          ..addOption(
            'compression',
            abbr: 'c',
            defaultsTo: 'medium',
            allowed: ['low', 'medium', 'high'],
            help: 'Compression level (low, medium, high)',
          )
          ..addFlag(
            'dry-run',
            abbr: 'd',
            defaultsTo: false,
            help: 'Simulate optimization without making changes',
          )
          ..addFlag(
            'backup',
            abbr: 'b',
            defaultsTo: true,
            help: 'Create backups of original files',
          )
          ..addOption(
            'exclude',
            abbr: 'e',
            help: 'Comma-separated list of directories to exclude',
          )
          ..addFlag(
            'delete',
            abbr: 'D',
            defaultsTo: false,
            help: 'Delete unused assets instead of just reporting them',
          )
          ..addOption('config', abbr: 'C', help: 'Path to configuration file');

    try {
      final results = parser.parse(args);
      final config = await _loadConfig(results['config'] as String?);

      final optimizer = AssetKamKaro(
        enableParallelProcessing: config['parallel'] ?? true,
        enableCache: config['cache'] ?? true,
      );

      final result = await optimizer.optimize(
        projectPath: Directory.current.path,
        compressionLevel: results['compression'] as String,
        dryRun: results['dry-run'] as bool,
        backup: results['backup'] as bool,
        exclude: results['exclude'] as String?,
      );

      print(result.toString());

      if (results['delete'] as bool) {
        await _deleteUnusedAssets(result.unusedAssets);
      }
    } catch (e) {
      print('Error: $e');
      print('\nUsage:');
      print(parser.usage);
      exit(1);
    }
  }

  /// Loads configuration from a YAML file.
  Future<Map<String, dynamic>> _loadConfig(String? configPath) async {
    final defaultConfig = {
      'parallel': true,
      'cache': true,
      'compression': 'medium',
      'exclude': ['test/', 'example/'],
    };

    if (configPath == null) {
      return defaultConfig;
    }

    final file = File(configPath);
    if (!file.existsSync()) {
      return defaultConfig;
    }

    try {
      final content = await file.readAsString();
      final yaml = loadYaml(content) as YamlMap;
      return {
        'parallel': yaml['parallel'] ?? defaultConfig['parallel'],
        'cache': yaml['cache'] ?? defaultConfig['cache'],
        'compression': yaml['compression'] ?? defaultConfig['compression'],
        'exclude': yaml['exclude'] ?? defaultConfig['exclude'],
      };
    } catch (e) {
      print('Warning: Failed to load config file: $e');
      return defaultConfig;
    }
  }

  /// Deletes unused assets.
  Future<void> _deleteUnusedAssets(List<String> unusedAssets) async {
    for (final asset in unusedAssets) {
      final file = File(asset);
      if (file.existsSync()) {
        await file.delete();
        print('Deleted unused asset: $asset');
      }
    }
  }
}
