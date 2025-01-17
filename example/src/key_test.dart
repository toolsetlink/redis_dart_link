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

    test('scan command test', () async {
      try {
        final List<Object> values = ["member1", "member2"];

        await client.sadd(
          'scan-test',
          values,
        );

        Scan scanResult = await client.scan(0, count: 10000);
        print('1 cursor: ${scanResult.cursor}');
        print('1 keys.len: ${scanResult.keys.length}');
      } catch (e) {
        print("An error occurred: $e");
      }
      // }, skip: 'scan Skipping this test temporarily');
    });
  });
}
