import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;

/// Manages caching of processed assets to avoid reprocessing.
class CacheManager {
  final String _cacheDir;
  final Map<String, String> _cache = {};

  CacheManager({String? cacheDir})
    : _cacheDir = cacheDir ?? '.assetkamkaro_cache';

  /// Gets the cached hash for a file if it exists.
  String? getCachedHash(String filePath) {
    return _cache[filePath];
  }

  /// Caches the hash for a file.
  void cacheHash(String filePath, String hash) {
    _cache[filePath] = hash;
  }

  /// Saves the cache to disk.
  Future<void> saveCache() async {
    final cacheFile = File(path.join(_cacheDir, 'cache.json'));
    await cacheFile.create(recursive: true);
    await cacheFile.writeAsString(_cache.toString());
  }

  /// Loads the cache from disk.
  Future<void> loadCache() async {
    final cacheFile = File(path.join(_cacheDir, 'cache.json'));
    if (await cacheFile.exists()) {
      final content = await cacheFile.readAsString();
      // Parse the cache content
      // Implementation depends on how the cache is stored
    }
  }

  /// Clears the cache.
  Future<void> clearCache() async {
    _cache.clear();
    final cacheDir = Directory(_cacheDir);
    if (await cacheDir.exists()) {
      await cacheDir.delete(recursive: true);
    }
  }
}
