import 'package:redis_dart_link/client.dart';
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

    test('jsonSet command test', () async {
      try {
        await client.jsonSet(
          key: 'jsonSet-json1',
          value: '["val1","val2","val3"]',
        );

        var Val = await client.jsonGet(
          'jsonSet-json1',
        );
        print("jsonSet Val.toString() : ${Val}");
      } catch (e) {
        print("An error occurred: $e");
      }
    }, skip: 'jsonSet Skipping this test temporarily');
    // });

    test('jsonDel command test', () async {
      try {
        await client.jsonSet(
          key: 'jsonDel-json1',
          value: '["val1","val2","val3"]',
        );

        var Val = await client.jsonDel('jsonDel-json1');
        print("jsonDel Val.toString() : ${Val}");
      } catch (e) {
        print("An error occurred: $e");
      }
    }, skip: 'jsonDel Skipping this test temporarily');
    // });

    test('jsonArrIndex command test', () async {
      try {
        var Val = await client.jsonArrIndex(
          'json1',
          '"val4"',
          path: '\$',
        );
        print("jsonArrIndex Val.toString() : ${Val}");
      } catch (e) {
        print("An error occurred: $e");
      }
    }, skip: 'jsonArrIndex Skipping this test temporarily');
    // });

    test('jsonArrAppend command test', () async {
      try {
        await client.jsonSet(
          key: 'jsonArrAppend-json1',
          value: '["val1","val2","val3"]',
        );

        var Val = await client.jsonArrAppend(
          'jsonArrAppend-json1',
          '"val5"',
          path: '\$',
        );
        print("jsonArrAppend Val.toString() : ${Val}");
      } catch (e) {
        print("An error occurred: $e");
      }
    }, skip: 'jsonArrAppend Skipping this test temporarily');
    // });

    test('jsonArrTrim command test', () async {
      try {
        await client.jsonSet(
          key: 'jsonArrTrim-json1',
          value: '["val1","val2","val3"]',
        );

        var Val =
            await client.jsonArrTrim('jsonArrTrim-json1', start: 1, stop: 2);
        print("jsonArrTrim Val.toString() : ${Val}");
      } catch (e) {
        print("An error occurred: $e");
      }
    }, skip: 'jsonArrTrim Skipping this test temporarily');
    // });

    test('jsonArrPop command test', () async {
      try {
        await client.jsonSet(
          key: 'jsonArrPop-json1',
          value: '["val1","val2","val3"]',
        );

        var Val = await client.jsonArrPop('jsonArrPop-json1');
        print("jsonArrPop Val.toString() : ${Val}");
      } catch (e) {
        print("An error occurred: $e");
      }
    }, skip: 'jsonArrPop Skipping this test temporarily');
    // });

    test('jsonClear command test', () async {
      try {
        await client.jsonSet(
          key: 'jsonClear-json1',
          value: '["val1","val2","val3"]',
        );

        var Val = await client.jsonClear('jsonClear-json1');
        print("jsonClear Val.toString() : ${Val}");
      } catch (e) {
        print("An error occurred: $e");
      }
    }, skip: 'jsonClear Skipping this test temporarily');
    // });

    test('jsonLen command test', () async {
      try {
        await client.jsonSet(
          key: 'jsonClear-json1',
          value: '["val1","val2","val3"]',
        );

        var Val = await client.jsonArrLen('jsonClear-json1');
        print("jsonArrLen Val.toString() : ${Val}");
      } catch (e) {
        print("An error occurred: $e");
      }
    }, skip: 'jsonLen Skipping this test temporarily');
    // });

    test('jsonMerge command test', () async {
      try {
        await client.jsonSet(
          key: 'jsonMerge-json1',
          value: '{"a":2}',
        );

        await client.jsonMerge('jsonMerge-json1', path: '\$.b', value: '8');

        var Val = await client.jsonGet('jsonMerge-json1');
        print("jsonMerge Val.toString() : ${Val}");
      } catch (e) {
        print("An error occurred: $e");
      }
    }, skip: 'jsonMerge Skipping this test temporarily');
    // });

    test('jsonMget command test', () async {
      try {
        await client.jsonSet(
          key: 'jsonMget-json1',
          value: '{"a":1, "b": 2, "nested": {"a": 3}, "c": null}',
        );

        await client.jsonSet(
          key: 'jsonMget-json2',
          value: '{"a":4, "b": 5, "nested": {"a": 6}, "c": null}',
        );

        var Val = await client
            .jsonMget(['jsonMget-json1', 'jsonMget-json2'], path: '\$..a');

        print("jsonMget Val.toString() : ${Val}");
      } catch (e) {
        print("An error occurred: $e");
      }
    }, skip: 'jsonMget Skipping this test temporarily');
    // });

    test('jsonForget command test', () async {
      try {
        await client.jsonSet(
          key: 'jsonForget-json1',
          value: '{"a":1, "b": 2, "nested": {"a": 3}, "c": null}',
        );

        var Val = await client.jsonForget('jsonForget-json1');
        print("jsonForget Val.toString() : ${Val}");
      } catch (e) {
        print("An error occurred: $e");
      }
    }, skip: 'jsonForget Skipping this test temporarily');
    // });

    test('jsonMGET command test', () async {
      try {
        await client.jsonSet(
          key: 'test-json-jsonMget1',
          value: '{"a":1, "b": 2, "nested": {"a": 3}, "c": null}',
        );

        await client.jsonSet(
            key: 'test-json-jsonMget2',
            value: '{"a":4, "b": 5, "nested": {"a": 6}, "c": null}');

        var Val = await client.jsonMget(
          ['test-json-jsonMget1', 'test-json-jsonMget2'],
        );
        print("jsonMget Val.toString() : ${Val}");
      } catch (e) {
        print("An error occurred: $e");
      }
    }, skip: 'jsonMget Skipping this test temporarily');
    // });

    test('jsonMset command test', () async {
      try {
        await client.jsonMset(
          'test-json-jsonMset1',
          value: '{"a":1}',
        );

        await client.jsonMset(
          'test-json-jsonMset1',
          value: '{"a":2}',
        );

        var Val = await client.jsonGet(
          'test-json-jsonMset1',
        );
        print("jsonMset Val.toString() : ${Val}");
      } catch (e) {
        print("An error occurred: $e");
      }
    }, skip: 'jsonMget Skipping this test temporarily');
    // });

    test('jsonNumincrby command test', () async {
      try {
        await client.jsonMset(
          'test-json-jsonNumincrby1',
          value: '{"a":"b","b":[{"a":2}, {"a":5}, {"a":"c"}]}',
        );

        var Val1 = await client.jsonNumincrby(
          'test-json-jsonNumincrby1',
          path: r'$.a',
          value: 2,
        );
        print("jsonNumincrby1 Val.toString() : ${Val1}");

        var Val2 = await client.jsonNumincrby(
          'test-json-jsonNumincrby1',
          path: r'$..a',
          value: 2,
        );
        print("jsonNumincrby2 Val.toString() : ${Val2}");
      } catch (e) {
        print("An error occurred: $e");
      }
    }, skip: 'jsonNumincrby Skipping this test temporarily');
    // });

    test('jsonNummultby command test', () async {
      try {
        await client.jsonSet(
          key: 'test-json-jsonNummultby1',
          value: '{"a":"b","b":[{"a":2}, {"a":5}, {"a":"c"}]}',
        );

        var Val1 = await client.jsonNummultby(
          'test-json-jsonNummultby1',
          path: r'$.a',
          value: 2,
        );
        print("jsonNumincrby1 Val.toString() : ${Val1}");

        var Val2 = await client.jsonNummultby(
          'test-json-jsonNummultby1',
          path: r'$..a',
          value: 2,
        );
        print("jsonNummultby2 Val.toString() : ${Val2}");
      } catch (e) {
        print("An error occurred: $e");
      }
    }, skip: 'jsonNummultby Skipping this test temporarily');
    // });

    test('jsonObjkeys command test', () async {
      try {
        await client.jsonSet(
          key: 'test-json-jsonObjkeys1',
          value: '{"a":[1], "nested": {"a": {"b":2, "c": 3}}}',
        );

        await client.jsonObjkeys(
          'test-json-jsonObjkeys1',
          path: r'$..nested',
        );
      } catch (e) {
        print("An error occurred: $e");
      }
    }, skip: 'jsonObjkeys Skipping this test temporarily');
    // });

    test('jsonStrappend command test', () async {
      try {
        await client.jsonSet(
          key: 'test-json-jsonStrappend1',
          value: '{"a":"foo", "nested": {"a": "hello"}, "nested2": {"a": 31}}',
        );

        var Val = await client.jsonGet('test-json-jsonStrappend1');
        print("jsonStrappend1.toString() : ${Val}");

        await client.jsonStrappend(
          'test-json-jsonStrappend1',
          path: r'$..a',
          value: r'"baz"',
        );
      } catch (e) {
        print("An error occurred: $e");
      }
    }, skip: 'jsonStrappend Skipping this test temporarily');
    // });

    test('jsonStrlen command test', () async {
      try {
        await client.jsonSet(
          key: 'test-json-jsonStrlen1',
          value: '{"a":"foo", "nested": {"a": "hello"}, "nested2": {"a": 31}}',
        );

        var Val1 = await client.jsonStrlen(
          'test-json-jsonStrlen1',
          path: r'$..a',
        );
        print("jsonStrlen.toString() : ${Val1}");
      } catch (e) {
        print("An error occurred: $e");
      }
    }, skip: 'jsonStrlen Skipping this test temporarily');
    // });
  });
}
