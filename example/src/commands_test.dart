import 'package:redis_dart_link/client.dart';
import 'package:redis_dart_link/models.dart';
import 'package:test/test.dart';

import 'redis_client_init.dart';

void main() {
  group('Redis Commands Tests', () {
    late RedisClient client;

    setUpAll(() async {
      client = await initRedisClient();
    });

    tearDownAll(() async {
      await closeRedisClient(client);
    });

    test('moduleList command test', () async {
      try {
        await client.hello(3);

        ModuleList moduleList = await client.moduleList();
        print("moduleList.toString() : ${moduleList.toString()}");
      } catch (e) {
        print("An error occurred: $e");
      }
    });
    // }, skip: 'moduleList this test temporarily');
  });
}
