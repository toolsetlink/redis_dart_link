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

/// Creates a server connection using a socket.
Future<RespServerConnection> connectSocket(String host,
    {int port = 6379, Duration? timeout}) async {
  Socket socket = await Socket.connect(host, port, timeout: timeout);

  return _SocketRespServer(socket);
}

/// Creates a server connection using a socket.
Future<RespServerConnection> connectSecureSocket(
  String host, {
  int port = 6379,
  Duration? timeout,
  List<int>? caCertBytes,
  List<int>? certBytes,
  List<int>? keyBytes,
}) async {
  SecurityContext context = SecurityContext(withTrustedRoots: true);

  context.setTrustedCertificatesBytes(caCertBytes!);

  context.useCertificateChainBytes(certBytes!);
  context.usePrivateKeyBytes(keyBytes!);

  SecureSocket socket = await SecureSocket.connect(
    host,
    port,
    context: context,
    onBadCertificate: (X509Certificate cert) => true,
    timeout: timeout,
  );

  return _SocketRespServer(socket);
}
