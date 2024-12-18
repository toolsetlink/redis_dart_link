import 'package:redis_dart_link/client.dart';
import 'package:test/test.dart';

import 'redis_client_init.dart';

void main() {
  group('Redis Commands Tests', () {
    late RedisClient client;

    setUpAll(() async {
      // 初始化Redis客户端，在所有测试用例执行前进行一次初始化
      client = await initRedisClient();
    });

    tearDownAll(() async {
      // 在所有测试用例执行完毕后关闭客户端连接
      await closeRedisClient(client);
    });

    test('jsonGet command test', () async {
      try {
        var Val = await client.jsonGet('json1');
        print("Val.toString() : ${Val}");
      } catch (e) {
        print("An error occurred: $e");
      }
    });

    // test('jsonDel command test', () async {
    //   try {
    //     var Val = await client.jsonDel('json-test');
    //     print("Val.toString() : ${Val}");
    //   } catch (e) {
    //     print("An error occurred: $e");
    //   }
    // });
    //
    // test('jsonSet command test', () async {
    //   try {
    //     await client.jsonSet(
    //       key: 'json-test',
    //       value: '["Alice"]',
    //     );
    //   } catch (e) {
    //     print("An error occurred: $e");
    //   }
    // });
    //

    test('jsonArrappend command test', () async {
      try {
        var Val = await client.jsonArrappend(
          'json1',
          r'"blue3"',
          path: r'$',
        );
        print("Val.toString() : ${Val}");
      } catch (e) {
        print("An error occurred: $e");
      }
    });
  });
}
