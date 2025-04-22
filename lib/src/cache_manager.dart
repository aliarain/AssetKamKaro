import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';

class AssetCache {
  final String cacheDir = '.assetkamkaro_cache';

  Future<bool> hasValidCache(String filePath, String compressionLevel) async {
    final hash = await _computeFileHash(filePath);
    final cacheKey = '$hash-$compressionLevel';
    final cacheFile = File('$cacheDir/$cacheKey');

    return cacheFile.existsSync();
  }

  Future<String> _computeFileHash(String filePath) async {
    final bytes = await File(filePath).readAsBytes();
    return md5.convert(bytes).toString();
  }
}
