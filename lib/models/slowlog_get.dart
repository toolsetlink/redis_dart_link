part of models;

/// SlowlogGet
class SlowlogGet {
  /// list
  final List<SlowlogGetInfo> list;

  /// SlowlogGet
  SlowlogGet({
    required this.list,
  });

  /// fromResult
  factory SlowlogGet.fromResult(Object result) {
    List<SlowlogGetInfo> _list = [];

    if (result is RespType2<dynamic>) {
      final result1 = result.toArray().payload;
      if (result1 == null) {
        return SlowlogGet(list: _list);
      }

      for (var item in result1) {
        if (item is RespArray2) {
          final payload = item.payload;

          if (payload != null && payload.length == 6) {
            // 提取 id、timestamp 和 duration
            final id = (payload[0] as RespInteger2).payload;
            final timestamp = (payload[1] as RespInteger2).payload;
            final duration = (payload[2] as RespInteger2).payload;

            // // 提取 command，command 是一个数组
            final commandArray = (payload[3] as RespArray2).payload;
            List<String>? command = [];
            if (commandArray != null) {
              command = commandArray.map((cmd) {
                return (cmd as RespBulkString2).payload ?? '';
              }).toList(); // 将命令部分转换为 List<String>
            }

            // 提取 client
            String? client = (payload[4] as RespBulkString2).payload;

            // extraInfo 可以根据需要进行处理，这里假设总是存在且为字符串
            String? extraInfo =
                (payload.length > 5 && payload[5] is RespBulkString2)
                    ? (payload[5] as RespBulkString2).payload
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
      return SlowlogGet(list: _list);
    }

    final result1 = (result as RespType3<dynamic>).toArray().payload;
    if (result1 == null) {
      return SlowlogGet(list: _list);
    }

    for (var item in result1) {
      if (item is RespArray3) {
        final payload = item.payload;

        if (payload != null && payload.length == 6) {
          // 提取 id、timestamp 和 duration
          final id = (payload[0] as RespInteger3).payload;
          final timestamp = (payload[1] as RespInteger3).payload;
          final duration = (payload[2] as RespInteger3).payload;

          // 提取 command，command 是一个数组
          final commandArray = (payload[3] as RespArray3).payload;
          List<String>? command = [];
          if (commandArray != null) {
            command = commandArray.map((cmd) {
              return (cmd as RespBulkString3).payload ?? '';
            }).toList(); // 将命令部分转换为 List<String>
          }

          // 提取 client
          String? client = (payload[4] as RespBulkString3).payload;

          // extraInfo 可以根据需要进行处理，这里假设总是存在且为字符串
          String? extraInfo =
              (payload.length > 5 && payload[5] is RespBulkString3)
                  ? (payload[5] as RespBulkString3).payload
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
    return SlowlogGet(list: _list);
  }

  @override
  String toString() {
    return 'SlowlogGet('
        'list: [${list.map((info) => info.toString()).join(", ")}]'
        ')';
  }
}

/// SlowlogGetInfo
class SlowlogGetInfo {
  /// 命令ID
  final int id;

  /// 命令执行时间
  final int timestamp;

  /// 命令执行时长
  final int duration;

  /// 命令
  final List<String>? command;

  /// 客户端
  final String? client;

  /// 额外信息
  final String? extraInfo;

  /// SlowlogGetInfo
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
