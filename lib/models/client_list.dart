part of models;

/// ClientList
class ClientList {
  final List<ClientInfo> list;

  /// ClientList
  ClientList({
    required this.list,
  });

  /// fromResult
  factory ClientList.fromResult(Object result) {
    List<ClientInfo> _list = [];

    // List<String>
    if (result is RespType2<dynamic>) {
      final bulkString = result.toBulkString().payload;
      if (bulkString != null) {
        final bulkString1 = bulkString
            .split('\n')
            .where((e) => e.isNotEmpty)
            .toList(growable: false);
        _list = bulkString1
            .where((line) => line.isNotEmpty)
            .map((line) => _parseClientInfo(line))
            .toList(growable: false);
      }

      return ClientList(list: _list);
    }

    final bulkString = (result as RespType3<dynamic>).toBulkString().payload;
    if (bulkString != null) {
      final bulkString1 = bulkString
          .split('\n')
          .where((e) => e.isNotEmpty)
          .toList(growable: false);

      _list = bulkString1
          .where((line) => line.isNotEmpty)
          .map((line) => _parseClientInfo(line))
          .toList(growable: false);
    }

    return ClientList(list: _list);
  }

  static ClientInfo _parseClientInfo(String line) {
    Map<String, String> clientData = {};

    for (String pair in line.split(' ')) {
      List<String> keyValue = pair.split('=');
      if (keyValue.length == 2) {
        clientData[keyValue[0]] = keyValue[1];
      }
    }

    return ClientInfo(
      id: int.tryParse(clientData['id'] ?? '0') ?? 0,
      addr: clientData['addr'],
      fd: int.tryParse(clientData['fd'] ?? '0') ?? 0,
      name: clientData['name'],
      age: int.tryParse(clientData['age'] ?? '0') ?? 0,
      idle: int.tryParse(clientData['idle'] ?? '0') ?? 0,
      flags: clientData['flags'],
      db: int.tryParse(clientData['db'] ?? '0') ?? 0,
      subscribed: int.tryParse(clientData['subscribed'] ?? '0') ?? 0,
      psubscribed: int.tryParse(clientData['psubscribed'] ?? '0') ?? 0,
      multi: int.tryParse(clientData['multi'] ?? '0') ?? 0,
      qbuf: int.tryParse(clientData['qbuf'] ?? '0') ?? 0,
      qbufFree: int.tryParse(clientData['qbuf_free'] ?? '0') ?? 0,
      obl: int.tryParse(clientData['obl'] ?? '0') ?? 0,
      oll: int.tryParse(clientData['oll'] ?? '0') ?? 0,
      omem: int.tryParse(clientData['omem'] ?? '0') ?? 0,
      events: clientData['events'],
      cmd: clientData['cmd'],
    );
  }

  @override
  String toString() {
    return 'ClientList('
        'list: [${list.join(", ")}]'
        ')';
  }
}

/// ClientInfo
class ClientInfo {
  /// 客户端的唯一标识符。
  final int id;

  /// 客户端的 IP 地址和端口号，比如 127.0.0.1:6379。
  final String? addr;

  /// 与客户端相关联的文件描述符。
  final int fd;

  /// 客户端的名称，如果设置了的话。
  final String? name;

  /// 客户端连接的时间（以秒为单位）。
  final int age;

  /// 客户端在当前连接中空闲的时间（以秒为单位）。
  final int idle;

  /// 客户端的标志，表示连接的状态，比如是否为订阅者、是否为从节点等。
  final String? flags;

  /// 客户端当前选择的数据库的编号。
  final int db;

  /// 如果客户端订阅了频道，这里会显示其订阅的频道数量。
  final int subscribed;

  /// 如果客户端订阅了模式，这里显示其模式订阅的数量。
  final int psubscribed;

  /// 如果客户端处于 MULTI 状态（事务状态），会显示为 1。
  final int multi;

  /// 客户端的查询缓冲区的字节数。
  final int qbuf;

  /// 查询缓冲区的剩余空间。
  final int qbufFree;

  /// 输出缓冲区的字节数。
  final int obl;

  /// 输出缓冲区的列表长度。
  final int oll;

  /// 输出缓冲区的内存使用量。
  final int omem;

  /// 客户端是否在等待特定事件（如可读或可写）。
  final String? events;

  /// 客户端最近执行的命令。
  final String? cmd;

  /// ClientInfo
  ClientInfo({
    required this.id,
    required this.addr,
    required this.fd,
    required this.name,
    required this.age,
    required this.idle,
    required this.flags,
    required this.db,
    required this.subscribed,
    required this.psubscribed,
    required this.multi,
    required this.qbuf,
    required this.qbufFree,
    required this.obl,
    required this.oll,
    required this.omem,
    required this.events,
    required this.cmd,
  });

  @override
  String toString() {
    return 'ClientInfo('
        'id: $id, '
        'addr: $addr, '
        'fd: $fd, '
        'name: $name, '
        'age: $age, '
        'idle: $idle, '
        'flags: $flags, '
        'db: $db, '
        'subscribed: $subscribed, '
        'psubscribed: $psubscribed, '
        'multi: $multi, '
        'qbuf: $qbuf, '
        'qbufFree: $qbufFree, '
        'obl: $obl, '
        'oll: $oll, '
        'omem: $omem, '
        'events: $events, '
        'cmd: $cmd, '
        ')';
  }
}
