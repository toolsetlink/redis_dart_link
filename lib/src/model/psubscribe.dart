import '../client/client.dart';

class Psubscribe {
  final String? type;
  final String? channel;
  final String? message;

  Psubscribe({
    required this.type,
    required this.channel,
    required this.message,
  });

  factory Psubscribe.fromResult(List<RespType<dynamic>>? result) {
    final _type = result![0].toBulkString().payload;
    final _channel = result[1].toBulkString().payload;
    final _message = result[2].toBulkString().payload;
    return Psubscribe(type: _type, channel: _channel, message: _message);
  }

  @override
  String toString() {
    return 'Psubscribe('
        'type: $type, '
        'channel: $channel, '
        'message: $message'
        ')';
  }
}
