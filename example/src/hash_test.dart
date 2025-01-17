import 'package:redis_dart_link/client.dart';
import 'package:redis_dart_link/model.dart';
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

    test('hscan command test', () async {
      try {
        final Map<Object, double> values = {'member1': 1.0};

        await client.hmset(
          'hscan-test',
          values,
        );

        Hscan value1 = await client.hscan('hscan-test', 0);

        print("hscan Val.toString() : ${value1.toString()}");
      } catch (e) {
        print("An error occurred: $e");
      }
      // }, skip: 'hscan Skipping this test temporarily');
    });
  });
}
