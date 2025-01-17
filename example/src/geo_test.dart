import 'package:redis_dart_link/client.dart';
import 'package:test/test.dart';

import 'redis_client_init.dart';

void main() {
  group('Redis Commands GEO Tests', () {
    late RedisClient client;

    setUpAll(() async {
      client = await initRedisClient();
    });

    tearDownAll(() async {
      await closeRedisClient(client);
    });

    test('geoAdd command test', () async {
      try {
        await client.geoAdd(
          'test-geoAdd-Sicily',
          13.361389,
          38.115556,
          'Palermo',
        );

        await client.geoAdd(
          'test-geoAdd-Sicily',
          15.087269,
          37.502669,
          'Catania',
        );

        var Val = await client.geoDist(
          'test-geoAdd-Sicily',
          'Palermo',
          'Catania',
        );
        print("geoDist Val.toString() : ${Val}");
      } catch (e) {
        print("An error occurred: $e");
      }
      // });
    }, skip: 'jsonGet Skipping this test temporarily');

    test('geoHash command test', () async {
      try {
        var Val =
            await client.geoHash('test-geoAdd-Sicily', ['Catania', 'Palermo']);
        print("geoHash Val.toString() : ${Val}");
      } catch (e) {
        print("An error occurred: $e");
      }
    }, skip: 'jsonGet Skipping this test temporarily');

    test('geoPos command test', () async {
      try {
        var Val = await client.geoPos(
            'test-geoAdd-Sicily', ['Catania', 'Palermo', 'NonExisting']);
        print("GeoPos Val.toString() : ${Val.toString()}");
      } catch (e) {
        print("An error occurred: $e");
      }
      // });
    }, skip: 'jsonGet Skipping this test temporarily');
  });
}
