part of commands;

///
/// The most basic form of a RESP command.
/// 最基本的RESP命令形式。
///
class RespCommandsTier0 {
  final RespClient client;

  RespCommandsTier0(this.client);

  ///
  /// Writes an array of bulk strings to the [outputSink]
  /// of the underlying server connection and reads back
  /// the RESP type of the response.
  ///
  /// All elements of [elements] are converted to bulk
  /// strings by using to Object.toString().
  ///
  ///
  /// 将一个大容量字符串数组写入[outputSink]
  /// 返回底层服务器连接 响应的RESP类型。
  /// [elements]中的所有元素都被转换为bulk 使用Object.toString()。
  Future<RespType> execute(List<Object?> elements) async {
    print("elements: $elements");
    return client.writeType(
      RespArray(
        elements
            .map((e) => RespBulkString(e?.toString()))
            .toList(growable: false),
      ),
    );
  }
}
