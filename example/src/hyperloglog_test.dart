import 'package:redis_dart_link/client.dart';
import 'package:test/test.dart';

import 'redis_client_init.dart';

void main() {
  group('Redis Commands HyperLogLog Tests', () {
    late RedisClient client;

    setUpAll(() async {
      client = await initRedisClient();
    });

    tearDownAll(() async {
      await closeRedisClient(client);
    });

    test('PFADD command test', () async {
      try {
        await client.pfadd(
          'test-pfadd',
          ['a', 'b', 'c'],
        );

        var Val = await client.pfcount(
          ['test-pfadd'],
        );
        print("pfcount Val.toString() : ${Val}");
      } catch (e) {
        print("An error occurred: $e");
      }
    });
    // }, skip: 'PFADD Skipping this test temporarily');

    test('PFADD command test', () async {
      try {
        await client.pfadd(
          'test-PFMERGE-1',
          ['foo', 'bar', 'zap', 'a'],
        );
        await client.pfadd(
          'test-PFMERGE-2',
          ['a', 'b', 'c', 'foo'],
        );

        await client.pfmerge(
          'test-PFMERGE-1',
          ['test-PFMERGE-2'],
        );

        var Val1 = await client.pfcount(
          ['test-PFMERGE-1'],
        );
        print("pfcount Val.toString() : ${Val1}");
      } catch (e) {
        print("An error occurred: $e");
      }
    });
    // }, skip: 'PFADD Skipping this test temporarily');
  });
}
