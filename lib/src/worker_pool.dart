import 'dart:isolate';
import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'types.dart';

/// Represents a work item to be processed by a worker.
class WorkItem {
  /// Creates a new [WorkItem].
  const WorkItem({
    required this.inputFile,
    required this.outputFile,
    required this.compressionLevel,
  });

  /// Path to the input file.
  final String inputFile;

  /// Path to the output file.
  final String outputFile;

  /// Compression level to use.
  final String compressionLevel;
}

/// Manages a pool of worker isolates for parallel processing.
class WorkerPool {
  /// Creates a new [WorkerPool].
  WorkerPool({this.numberOfWorkers = 4});

  /// Number of worker isolates to spawn.
  final int numberOfWorkers;

  /// List of worker isolates.
  final List<Isolate> workers = [];

  /// Queue of work items to be processed.
  final Queue<WorkItem> workQueue = Queue();

  /// List of send ports for communicating with workers.
  final List<SendPort> workerPorts = [];

  /// Initializes the worker pool by spawning isolates.
  Future<void> initialize() async {
    for (var i = 0; i < numberOfWorkers; i++) {
      final receivePort = ReceivePort();
      final isolate = await Isolate.spawn(
        _workerFunction,
        receivePort.sendPort,
      );
      workers.add(isolate);
      workerPorts.add(await receivePort.first);
    }
  }

  /// Processes a list of files in parallel using the worker pool.
  Future<List<AssetProcessingResult>> processFiles(
    List<WorkItem> workItems,
  ) async {
    final chunks = _splitIntoChunks(workItems, numberOfWorkers);
    final futures = <Future<List<AssetProcessingResult>>>[];

    for (var i = 0; i < chunks.length; i++) {
      futures.add(_processChunk(chunks[i], workerPorts[i % numberOfWorkers]));
    }

    final results = await Future.wait(futures);
    return results.expand((list) => list).toList();
  }

  /// Splits a list into chunks for parallel processing.
  List<List<T>> _splitIntoChunks<T>(List<T> list, int n) {
    final chunks = <List<T>>[];
    final size = (list.length / n).ceil();

    for (var i = 0; i < list.length; i += size) {
      chunks.add(
        list.sublist(i, i + size > list.length ? list.length : i + size),
      );
    }

    return chunks;
  }

  /// Processes a chunk of work items using a specific worker.
  Future<List<AssetProcessingResult>> _processChunk(
    List<WorkItem> chunk,
    SendPort workerPort,
  ) async {
    final receivePort = ReceivePort();
    workerPort.send(receivePort.sendPort);
    workerPort.send(chunk);

    final results = <AssetProcessingResult>[];
    await for (final result in receivePort) {
      if (result is AssetProcessingResult) {
        results.add(result);
      } else if (result == null) {
        break;
      }
    }

    return results;
  }

  /// Disposes of the worker pool by killing all isolates.
  void dispose() {
    for (final worker in workers) {
      worker.kill();
    }
    workers.clear();
    workerPorts.clear();
    workQueue.clear();
  }
}

/// Worker function that runs in a separate isolate.
void _workerFunction(SendPort sendPort) {
  final receivePort = ReceivePort();
  sendPort.send(receivePort.sendPort);

  receivePort.listen((message) async {
    if (message is List<WorkItem>) {
      final results = <AssetProcessingResult>[];
      for (final item in message) {
        try {
          final result = await _processWorkItem(item);
          results.add(result);
        } catch (e) {
          print('Error processing ${item.inputFile}: $e');
        }
      }
      sendPort.send(results);
      sendPort.send(null); // Signal completion
    }
  });
}

/// Processes a single work item.
Future<AssetProcessingResult> _processWorkItem(WorkItem item) async {
  final inputFile = File(item.inputFile);
  final outputFile = File(item.outputFile);

  if (!inputFile.existsSync()) {
    throw FileSystemException('Input file not found: ${item.inputFile}');
  }

  final originalBytes = await inputFile.readAsBytes();
  final originalSize = originalBytes.length;

  // Process the file (placeholder for actual processing)
  final processedBytes = originalBytes; // Replace with actual processing
  final processedSize = processedBytes.length;

  await outputFile.writeAsBytes(processedBytes);

  return AssetProcessingResult(
    originalSize: originalSize,
    newSize: processedSize,
    bytesSaved: originalSize - processedSize,
    reductionPercentage: ((originalSize - processedSize) / originalSize) * 100,
  );
}
