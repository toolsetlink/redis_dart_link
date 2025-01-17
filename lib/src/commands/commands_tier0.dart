part of commands;

/// The most basic form of a RESP command.
/// 最基本的RESP命令形式。
class RespCommandsTier0 {
  /// client
  final RespClient client;

  /// RespCommandsTier0
  RespCommandsTier0(this.client);

  /// Writes an array of bulk strings to the [outputSink]
  /// of the underlying server connection and reads back
  /// the RESP type of the response.
  /// All elements of [elements] are converted to bulk
  /// strings by using to Object.toString().
  ///
  /// 将一个大容量字符串数组写入[outputSink]
  /// 返回底层服务器连接 响应的RESP类型。
  /// [elements]中的所有元素都被转换为bulk 使用Object.toString()。
  Future<Object> execute<T>(List<Object?> elements) async {
    // print("execute() elements: $elements");
    // print("execute() client.respType: ${client.respType}");

    if (client.respType == 2) {
      return client.writeType2(
        RespArray2(
          elements
              .map((e) => RespBulkString2(e?.toString()))
              .toList(growable: false),
        ),
      );
    }

    return client.WriteType3(
      RespArray3(
        elements
            .map((e) => RespBulkString3(e?.toString()))
            .toList(growable: false),
      ),
    );
  }

  Stream<RespType2> subscribe(List<String> channels) {
    Stream<RespType2> stream = client.subscribe(channels);
    return stream;
  }

  Stream<RespType2> psubscribe(List<String> pattern) {
    Stream<RespType2> stream = client.psubscribe(pattern);
    return stream;
  }
}
