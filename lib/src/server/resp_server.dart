part of server;

/// Connection to the RESP server. It must provide one
/// [outputSink] is used by [RespClient] to write requests to the server.
/// [inputStream] is used by [RespClient] to read responses from the server.
/// 到RESP服务器的连接。它必须提供一个
/// [outputSink]被[RespClient]用来写请求到服务器。
/// [inputStream]被[RespClient]使用从服务器读取响应。
abstract class RespServerConnection {
  StreamSink<List<int>> get outputSink;

  Stream<List<int>> get inputStream;

  Future<void> close();
}
