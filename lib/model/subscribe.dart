import '../src/client.dart';

class Subscribe {
  final String? type;
  final String? channel;
  final String? message;

  Subscribe({
    required this.type,
    required this.channel,
    required this.message,
  });

  factory Subscribe.fromResult(List<RespType<dynamic>>? result) {
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
