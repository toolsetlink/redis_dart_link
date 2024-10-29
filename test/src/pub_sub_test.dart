import 'package:redis_dart_link/client.dart';
import 'package:redis_dart_link/socket_options.dart';
import 'package:test/test.dart';

void main() {
  test('adds one to input values', () async {
    /// Create a new redis instance
    RedisClient client = RedisClient(
      socket: RedisSocketOptions(
        host: '127.0.0.1',
        port: 7379,
        password: '123456',
      ),
    );

    // Connect to the Redis server.
    await client.connect();

    // subscribe 开启监听
    // final stream = client.subscribe(["1"]);
    // // 订阅流并打印每个接收到的响应
    // stream.listen((response) {
    //   print("client listen1 response: ${response.toString()}");
    // }, onError: (error) {
    //   print('client Error1: $error'); // 打印错误信息（如果有的话）
    // }, onDone: () {
    //   print('client Stream1 closed'); // 当流关闭时打印消息
    // });

    // psubscribe 开启监听
    final stream = client.psubscribe(["1*"]);
    // 订阅流并打印每个接收到的响应
    stream.listen((response) {
      print("client listen1 response: ${response.toString()}");
    }, onError: (error) {
      print('client Error1: $error'); // 打印错误信息（如果有的话）
    }, onDone: () {
      print('client Stream1 closed'); // 当流关闭时打印消息
    });

    // 保持主程序运行，直到手动终止 // 设置为4分钟
    await Future.delayed(Duration(minutes: 4));

    //
  }, timeout: Timeout(Duration(minutes: 5))); // 设置为5分钟
}
