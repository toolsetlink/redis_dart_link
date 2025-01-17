part of model;

/// Subscribe
class Subscribe {
  /// type
  final String? type;

  /// channel
  final String? channel;

  /// message
  final String? message;

  /// Subscribe
  Subscribe({
    required this.type,
    required this.channel,
    required this.message,
  });

  /// fromResult
  factory Subscribe.fromResult(Object reqResult) {
    final result = (reqResult as RespType2).toArray().payload;

    final _type = result![0].toBulkString().payload;
    final _channel = result[1].toBulkString().payload;
    final _message = result[2].toBulkString().payload;
    return Subscribe(type: _type, channel: _channel, message: _message);
  }

  @override
  String toString() {
    return 'Subscribe('
        'type: $type, '
        'channel: $channel, '
        'message: $message'
        ')';
  }
}
