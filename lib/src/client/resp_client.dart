part of client;

/// The client for a RESP server.
/// RESP服务器的客户端。
class RespClient {
  /// respType
  int respType = 2;
  final RespServerConnection _connection;
  final StreamReader _streamReader;
  final Queue<Completer> _pendingResponses = Queue();

  bool _isProcessingResponse = false;

  /// RespClient
  RespClient(this._connection)
      : _streamReader = StreamReader(_connection.inputStream);

  /// 设置 resp 版本
  void setRespType(int type) {
    this.respType = type;
  }

  /// Writes a RESP type to the server using the
  /// [outputSink] of the underlying server connection and
  /// reads back the RESP type of the response using the
  /// [inputStream] of the underlying server connection.
  ///
  /// 类向服务器写入一个RESP类型
  /// [outputSink]的底层服务器连接和返回响应的RESP类型
  /// 底层服务器连接的[inputStream]。
  Future<RespType2> writeType2(RespType2 data) {
    final completer = Completer<RespType2>();
    _pendingResponses.add(completer);
    _connection.outputSink.add(data.serialize());
    _processResponse2(false);
    return completer.future;
  }

  void _processResponse2(bool selfCall) {
    if (_isProcessingResponse == false || selfCall) {
      if (_pendingResponses.isNotEmpty) {
        _isProcessingResponse = true;
        final c = _pendingResponses.removeFirst();
        deserializeRespType2(_streamReader).then((response) {
          c.complete(response);
          _processResponse2(true);
        });
      } else {
        _isProcessingResponse = false;
      }
    }
  }

  /// WriteType3
  Future<RespType3> WriteType3(RespType3 data) {
    final completer = Completer<RespType3>();
    _pendingResponses.add(completer);
    _connection.outputSink.add(data.serialize());
    _processResponse3(false);
    return completer.future;
  }

  void _processResponse3(bool selfCall) {
    if (_isProcessingResponse == false || selfCall) {
      if (_pendingResponses.isNotEmpty) {
        _isProcessingResponse = true;
        final c = _pendingResponses.removeFirst();

        deserializeRespType3(_streamReader).then((response) {
          print("_processResponse3() response: $response");
          c.complete(response);
          _processResponse3(true);
        });
      } else {
        _isProcessingResponse = false;
      }
    }
  }

  // 监听
  Stream<RespType2> subscribe(List<String> channels) {
    final controller = StreamController<RespType2>();

    // 构建 SUBSCRIBE 命令
    final subscribeCommand = RespArray2([
      RespBulkString2('SUBSCRIBE'),
      ...channels.map((channel) => RespBulkString2(channel)).toList(),
    ]);

    // 发送 SUBSCRIBE 命令
    _connection.outputSink.add(subscribeCommand.serialize());

    // 启动监听消息的异步方法
    _subscribeListenForMessages(controller);

    // 关闭时清理
    controller.onCancel = () {
      // 发送 UNSUBSCRIBE 命令以取消订阅
      final unsubscribeCommand = RespArray2([
        RespBulkString2('UNSUBSCRIBE'),
        ...channels.map((channel) => RespBulkString2(channel)).toList(),
      ]);
      _connection.outputSink.add(unsubscribeCommand.serialize());
      controller.close();
    };

    return controller.stream;
  }

  Future<void> _subscribeListenForMessages(
      StreamController<RespType2> controller) async {
    while (true) {
      try {
        // 尝试读取数据
        RespType2<dynamic> response = await deserializeRespType2(_streamReader);

        if (response is RespArray2) {
          List<RespType2>? array = response.toArray().payload;
          if (array!.isNotEmpty) {
            final type = array[0].toBulkString().payload;
            if (type == 'subscribe') {
              print("Subscribe success");
            } else if (type == 'message') {
              controller.add(response);
            }
          }
        }
      } catch (e) {
        // 处理反序列化错误
        controller.addError(e);
        break; // 退出循环
      }
    }
  }

  // 监听
  Stream<RespType2> psubscribe(List<String> pattern) {
    final controller = StreamController<RespType2>();

    // 构建 SUBSCRIBE 命令
    final psubscribeCommand = RespArray2([
      RespBulkString2('PSUBSCRIBE'),
      ...pattern.map((channel) => RespBulkString2(channel)).toList(),
    ]);

    // 发送 SUBSCRIBE 命令
    _connection.outputSink.add(psubscribeCommand.serialize());

    // 启动监听消息的异步方法
    _psubscribeListenForMessages(controller);

    // 关闭时清理
    controller.onCancel = () {
      // 发送 UNSUBSCRIBE 命令以取消订阅
      final unpsubscribeCommand = RespArray2([
        RespBulkString2('PUNSUBSCRIBE'),
        ...pattern.map((channel) => RespBulkString2(channel)).toList(),
      ]);
      _connection.outputSink.add(unpsubscribeCommand.serialize());
      controller.close();
    };

    return controller.stream;
  }

  // 定义一个异步方法来监听消息
  Future<void> _psubscribeListenForMessages(
      StreamController<RespType2> controller) async {
    while (true) {
      try {
        // 尝试读取数据
        RespType2<dynamic> response = await deserializeRespType2(_streamReader);

        if (response is RespArray2) {
          List<RespType2>? array = response.toArray().payload;
          if (array!.isNotEmpty) {
            final type = array[0].toBulkString().payload;
            if (type == 'psubscribe') {
              print("Subscribe success");
            } else if (type == 'pmessage') {
              controller.add(response);
            }
          }
        }
      } catch (e) {
        // 处理反序列化错误
        controller.addError(e);
        break; // 退出循环
      }
    }
  }
}
