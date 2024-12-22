import 'package:redis_dart_link/client.dart';
import 'package:test/test.dart';

import 'redis_client_init.dart';

void main() {
  group('Redis Transaction Tests', () {
    late RedisClient client;

    setUpAll(() async {
      // 初始化Redis客户端，在所有测试用例执行前进行一次初始化
      client = await initRedisClient();
    });

    tearDownAll(() async {
      // 在所有测试用例执行完毕后关闭客户端连接
      await closeRedisClient(client);
    });

    test('multi1 command test', () async {
      try {
        await client.multi();

        var Val1 = await client.set(
          'test-multi-1',
          '"val1"',
        );
        print("multi1 Val.toString() : ${Val1}");

        var Val2 = await client.set(
          'test-multi-2',
          '"val2"',
        );
        print("multi2 Val.toString() : ${Val2}");

        await client.exec();

        ///
      } catch (e) {
        print("An error occurred: $e");
      }
    }, skip: 'multi Skipping this test temporarily');

    test('multi2 command test', () async {
      try {
        await client.multi();

        var Val1 = await client.set(
          'test-multi-1',
          '"val1"',
        );
        print("multi1 Val.toString() : ${Val1}");

        var Val2 = await client.set(
          'test-multi-2',
          '"val2"',
        );
        print("multi2 Val.toString() : ${Val2}");

        await client.discard();

        ///
      } catch (e) {
        print("An error occurred: $e");
      }
    }, skip: 'multi Skipping this test temporarily');

    test('multi3 command test', () async {
      try {
        await client.multi();

        try {
          var Val1 = await client.set(
            'test-multi-1',
            '"val1"',
          );
          print("multi1 Val.toString() : ${Val1}");
        } catch (e) {
          print("An error occurred while setting test-multi-1: $e");
        }

        try {
          var Val2 = await client.execute('sets 1 1');
          print("multi2 Val.toString() : ${Val2}");
        } catch (e) {
          print("An error occurred while executing sets 1 1: $e");
        }

        await client.exec();

        ///
      } catch (e) {
        print("An error occurred: $e");
      }
    });
    // }, skip: 'multi Skipping this test temporarily');
  });
}
