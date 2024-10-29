part of client;

///
/// The client for a RESP server.
/// RESP服务器的客户端。
///
class RespClient {
  final RespServerConnection _connection;
  final StreamReader _streamReader;
  final Queue<Completer> _pendingResponses = Queue();
  bool _isProccessingResponse = false;

  RespClient(this._connection)
      : _streamReader = StreamReader(_connection.inputStream);

  ///
  /// Writes a RESP type to the server using the
  /// [outputSink] of the underlying server connection and
  /// reads back the RESP type of the response using the
  /// [inputStream] of the underlying server connection.
  ///
  /// 类向服务器写入一个RESP类型
  /// [outputSink]的底层服务器连接和返回响应的RESP类型
  /// 底层服务器连接的[inputStream]。
  ///
  Future<RespType> writeType(RespType data) {
    final completer = Completer<RespType>();
    _pendingResponses.add(completer);
    _connection.outputSink.add(data.serialize());
    _processResponse(false);
    return completer.future;
  }

  /// 返回值
  void _processResponse(bool selfCall) {
    if (_isProccessingResponse == false || selfCall) {
      if (_pendingResponses.isNotEmpty) {
        _isProccessingResponse = true;
        final c = _pendingResponses.removeFirst();
        deserializeRespType(_streamReader).then((response) {
          c.complete(response);
          _processResponse(true);
        });
      } else {
        _isProccessingResponse = false;
      }
    }
  }

  // 监听
  Stream<RespType> subscribe(List<String> channels) {
    final controller = StreamController<RespType>();

    // 构建 SUBSCRIBE 命令
    final subscribeCommand = RespArray([
      RespBulkString('SUBSCRIBE'),
      ...channels.map((channel) => RespBulkString(channel)).toList(),
    ]);

    // 发送 SUBSCRIBE 命令
    _connection.outputSink.add(subscribeCommand.serialize());

    // 启动监听消息的异步方法
    _subscribeListenForMessages(controller);

    // 关闭时清理
    controller.onCancel = () {
      // 发送 UNSUBSCRIBE 命令以取消订阅
      final unsubscribeCommand = RespArray([
        RespBulkString('UNSUBSCRIBE'),
        ...channels.map((channel) => RespBulkString(channel)).toList(),
      ]);
      _connection.outputSink.add(unsubscribeCommand.serialize());
      controller.close();
    };

    return controller.stream;
  }

  Future<void> _subscribeListenForMessages(
      StreamController<RespType> controller) async {
    while (true) {
      try {
        // 尝试读取数据
        RespType<dynamic> response = await deserializeRespType(_streamReader);
        print("response: ${response.toString()}");

        if (response is RespArray) {
          List<RespType>? array = response.toArray().payload;
          if (array!.isNotEmpty) {
            final type = array[0].toBulkString().payload;
            if (type == 'subscribe') {
              print("订阅成功信息");
            } else if (type == 'message') {
              controller.add(response);
            }
          }
        }
      } catch (e, stackTrace) {
        // 处理反序列化错误
        controller.addError(e);
        break; // 退出循环
      }

      // 添加延迟以调长监听时间（例如，延迟 1 秒）
      await Future.delayed(Duration(seconds: 1));
    }
  }

  // 监听
  Stream<RespType> psubscribe(List<String> pattern) {
    final controller = StreamController<RespType>();

    // 构建 SUBSCRIBE 命令
    final psubscribeCommand = RespArray([
      RespBulkString('PSUBSCRIBE'),
      ...pattern.map((channel) => RespBulkString(channel)).toList(),
    ]);

    // 发送 SUBSCRIBE 命令
    _connection.outputSink.add(psubscribeCommand.serialize());

    // 启动监听消息的异步方法
    _psubscribeListenForMessages(controller);

    // 关闭时清理
    controller.onCancel = () {
      // 发送 UNSUBSCRIBE 命令以取消订阅
      final unpsubscribeCommand = RespArray([
        RespBulkString('PUNSUBSCRIBE'),
        ...pattern.map((channel) => RespBulkString(channel)).toList(),
      ]);
      _connection.outputSink.add(unpsubscribeCommand.serialize());
      controller.close();
    };

    return controller.stream;
  }

  // 定义一个异步方法来监听消息
  Future<void> _psubscribeListenForMessages(
      StreamController<RespType> controller) async {
    while (true) {
      try {
        // 尝试读取数据
        RespType<dynamic> response = await deserializeRespType(_streamReader);

        if (response is RespArray) {
          List<RespType>? array = response.toArray().payload;
          if (array!.isNotEmpty) {
            final type = array[0].toBulkString().payload;
            if (type == 'psubscribe') {
              print("订阅成功信息");
            } else if (type == 'pmessage') {
              controller.add(response);
            }
          }
        }
      } catch (e, stackTrace) {
        // 处理反序列化错误
        controller.addError(e);
        break; // 退出循环
      }

      // 添加延迟以调长监听时间（例如，延迟 1 秒）
      await Future.delayed(Duration(seconds: 1));
    }
  }
}
