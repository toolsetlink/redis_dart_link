part of client;

/// StreamReader
class StreamReader {
  /// buffer
  final buffer = Queue<int>();

  /// controller
  final controller = StreamController<void>.broadcast();

  /// StreamReader
  StreamReader(Stream<List<int>> stream) {
    stream.listen(onData);
  }

  /// onData
  void onData(List<int> data) {
    buffer.addAll(data);
    controller.add(null);
  }

  /// takeCount
  Future<List<int>> takeCount(int count) {
    final completer = Completer<List<int>>();
    final buffer = <int>[];
    final subscription = controller.stream.listen(null);

    subscription.onData((_) {
      while (buffer.length < count && this.buffer.isNotEmpty) {
        buffer.add(this.buffer.removeFirst());
      }
      if (buffer.length == count) {
        subscription.cancel();
        completer.complete(buffer);
      }
    });
    controller.add(null);

    return completer.future;
  }

  /// takeOne
  Future<int> takeOne() async {
    final data = await takeCount(1);
    return data[0];
  }

  /// takeWhile
  Future<List<int>> takeWhile(bool Function(int) predicate) {
    final completer = Completer<List<int>>();
    final buffer = <int>[];
    final subscription = controller.stream.listen(null);

    subscription.onData((_) {
      while (this.buffer.isNotEmpty && predicate(this.buffer.first)) {
        buffer.add(this.buffer.removeFirst());
      }
      if (this.buffer.isNotEmpty && !predicate(this.buffer.first)) {
        subscription.cancel();
        completer.complete(buffer);
      }
    });
    controller.add(null);

    return completer.future;
  }
}
