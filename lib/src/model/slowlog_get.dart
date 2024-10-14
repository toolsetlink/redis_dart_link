import '../client/commands.dart';

class SlowlogGet {
  final List<SlowlogGetInfo> list;

  SlowlogGet({
    required this.list,
  });

  factory SlowlogGet.fromResult(SlowlogGetResult result) {
    List<SlowlogGetInfo> infoList = [];
    for (var line in result.list) {
      infoList.add(SlowlogGetInfo(
        id: line.id,
        timestamp: line.timestamp,
        duration: line.duration,
        command: line.command,
        client: line.client,
        extraInfo: line.extraInfo,
      ));
    }

    return SlowlogGet(list: infoList);
  }

  @override
  String toString() {
    return 'SlowlogGet('
        'list: [${list.map((info) => info.toString()).join(", ")}]'
        ')';
  }
}

class SlowlogGetInfo {
  final int id;
  final int timestamp;
  final int duration;
  final List<String>? command;
  final String? client;
  final String? extraInfo;

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
