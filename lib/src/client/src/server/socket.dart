part of server;

class _SocketRespServer implements RespServerConnection {
  final Socket socket;

  _SocketRespServer(this.socket);

  @override
  IOSink get outputSink {
    return socket;
  }

  @override
  Stream<List<int>> get inputStream {
    return socket;
  }

  @override
  Future<void> close() async {
    await socket.flush();
    return socket.close();
  }
}

///
/// Creates a server connection using a socket.
/// 普通 socket 连接参数
///
Future<RespServerConnection> connectSocket(String host,
    {int port = 6379, Duration? timeout}) async {
  Socket socket = await Socket.connect(host, port, timeout: timeout);

  return _SocketRespServer(socket);
}

///
/// Creates a server connection using a socket.
/// 带 tls 认证
Future<RespServerConnection> connectSecureSocket(
  String host, {
  int port = 6379,
  Duration? timeout,
  List<int> caCertBytes = const [],
  List<int> certBytes = const [],
  List<int> keyBytes = const [],
}) async {
  // 创建一个 SecurityContext
  SecurityContext context = SecurityContext(withTrustedRoots: true);

  // 加载 CA 证书
  context.setTrustedCertificatesBytes(caCertBytes);

  // 加载客户端证书和私钥
  context.useCertificateChainBytes(certBytes);
  context.usePrivateKeyBytes(keyBytes);

  SecureSocket socket = await SecureSocket.connect(
    host,
    port,
    context: context,
    onBadCertificate: (X509Certificate cert) => true,
    timeout: timeout,
  );

  return _SocketRespServer(socket);
}
