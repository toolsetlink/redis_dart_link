import '../client/client.dart';

class SlowlogGet {
  final List<SlowlogGetInfo> list;

  SlowlogGet({
    required this.list,
  });

  factory SlowlogGet.fromResult(List<RespType<dynamic>>? result) {
    List<SlowlogGetInfo> _list = [];

    if (result != null) {
      for (var item in result) {
        if (item is RespArray) {
          final payload = item.payload;

          if (payload != null && payload.length == 6) {
            // 提取 id、timestamp 和 duration
            final id = (payload[0] as RespInteger).payload;
            final timestamp = (payload[1] as RespInteger).payload;
            final duration = (payload[2] as RespInteger).payload;

            // // 提取 command，command 是一个数组
            final commandArray = (payload[3] as RespArray).payload;
            List<String>? command = [];
            if (commandArray != null) {
              command = commandArray.map((cmd) {
                return (cmd as RespBulkString).payload ?? '';
              }).toList(); // 将命令部分转换为 List<String>
            }

            // 提取 client
            String? client = (payload[4] as RespBulkString).payload;

            // extraInfo 可以根据需要进行处理，这里假设总是存在且为字符串
            String? extraInfo =
                (payload.length > 5 && payload[5] is RespBulkString)
                    ? (payload[5] as RespBulkString).payload
                    : '';

            _list.add(SlowlogGetInfo(
              id: id,
              timestamp: timestamp,
              duration: duration,
              command: command,
              client: client,
              extraInfo: extraInfo,
            ));
          }
        }
      }
    }

    return SlowlogGet(list: _list);
  }

  @override
  String toString() {
    return 'SlowlogGet('
        'list: [${list.map((info) => info.toString()).join(", ")}]'
        ')';
  }
}

class SlowlogGetInfo {
  final int id; // 命令ID
  final int timestamp; // 命令执行时间
  final int duration; // 命令执行时长
  final List<String>? command; // 命令
  final String? client; // 客户端
  final String? extraInfo; // 额外信息

  SlowlogGetInfo({
    required this.id,
    required this.timestamp,
    required this.duration,
    required this.command,
    required this.client,
    required this.extraInfo,
  });

  @override
  String toString() {
    return 'SlowlogGetInfo('
        'id: $id, '
        'timestamp: $timestamp, '
        'duration: $duration, '
        'command: ${command?.join(" ")}, '
        'client: $client, '
        'extraInfo: $extraInfo'
        ')';
  }
}
