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

    test('jsonDel command test', () async {
      try {
        var Val = await client.jsonDel('json1');
        print("jsonDel Val.toString() : ${Val}");
      } catch (e) {
        print("An error occurred: $e");
      }
    }, skip: 'jsonDel Skipping this test temporarily');

    test('jsonGet command test', () async {
      try {
        var Val = await client.jsonGet('json1');
        print("Val.toString() : ${Val}");
      } catch (e) {
        print("An error occurred: $e");
      }
    }, skip: 'jsonGet Skipping this test temporarily');

    test('jsonSet command test', () async {
      try {
        await client.jsonSet(
          key: 'json1',
          value: '["val1","val2","val3"]',
        );
      } catch (e) {
        print("An error occurred: $e");
      }
    }, skip: 'jsonSet Skipping this test temporarily');

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

    test('jsonArrAppend command test', () async {
      try {
        var Val = await client.jsonArrAppend(
          'json1',
          '"val5"',
          path: '\$',
        );
        print("jsonArrAppend Val.toString() : ${Val}");
      } catch (e) {
        print("An error occurred: $e");
      }
    }, skip: 'jsonArrAppend Skipping this test temporarily');

    test('jsonGet command test', () async {
      try {
        var Val = await client.jsonGet('json1');
        print("jsonGet1 Val.toString() : ${Val}");
      } catch (e) {
        print("An error occurred: $e");
      }
    }, skip: 'jsonGet Skipping this test temporarily');

    test('jsonArrTrim command test', () async {
      try {
        var Val = await client.jsonArrTrim('json1', start: 1, stop: 2);
        print("jsonArrTrim Val.toString() : ${Val}");
      } catch (e) {
        print("An error occurred: $e");
      }
    }, skip: 'jsonArrTrim Skipping this test temporarily');

    test('jsonArrPop command test', () async {
      try {
        var Val = await client.jsonArrPop('json1');
        print("jsonArrPop Val.toString() : ${Val}");
      } catch (e) {
        print("An error occurred: $e");
      }
    }, skip: 'jsonArrPop Skipping this test temporarily');

    test('jsonGet command test', () async {
      try {
        var Val = await client.jsonGet('json1');
        print("jsonGet2 Val.toString() : ${Val}");
      } catch (e) {
        print("An error occurred: $e");
      }
    }, skip: 'jsonGet Skipping this test temporarily');

    test('jsonClear command test', () async {
      try {
        var Val = await client.jsonClear('json1');
        print("jsonClear Val.toString() : ${Val}");
      } catch (e) {
        print("An error occurred: $e");
      }
    }, skip: 'jsonClear Skipping this test temporarily');

    test('jsonGet command test', () async {
      try {
        var Val = await client.jsonGet('json1');
        print("jsonGet3 Val.toString() : ${Val}");
      } catch (e) {
        print("An error occurred: $e");
      }
    }, skip: 'jsonGet Skipping this test temporarily');

    test('jsonLen command test', () async {
      try {
        var Val = await client.jsonArrLen('json1');
        print("jsonArrLen Val.toString() : ${Val}");
      } catch (e) {
        print("An error occurred: $e");
      }
    }, skip: 'jsonLen Skipping this test temporarily');

    // todo 待解决
    // test('jsonMerge command test', () async {
    //   try {
    //     await client.jsonMerge('json1', path: '\$', value: '["val-jsonMerge"]');
    //   } catch (e) {
    //     print("An error occurred: $e");
    //   }
    // });

    test('jsonMget command test', () async {
      try {
        var Val = await client.jsonMget(['json1'], path: '\$');
        print("jsonMget Val.toString() : ${Val}");
      } catch (e) {
        print("An error occurred: $e");
      }
    }, skip: 'jsonMget Skipping this test temporarily');

    test('jsonForget command test', () async {
      try {
        var Val = await client.jsonForget('json1');
        print("jsonForget Val.toString() : ${Val}");
      } catch (e) {
        print("An error occurred: $e");
      }
    }, skip: 'jsonForget Skipping this test temporarily');

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
      // }, skip: 'jsonMset Skipping this test temporarily');
    }, skip: 'jsonMget Skipping this test temporarily');

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

    // todo 有问题， 方法一直返回 null
    // test('jsonObjkeys command test', () async {
    //   try {
    //     await client.jsonSet(
    //       key: 'test-json-jsonObjkeys1',
    //       value: '{"a":[3], "nested": {"a": {"b":2, "c": 1}}}',
    //     );
    //
    //     var Val1 =
    //         await client.jsonObjkeys('test-json-jsonObjkeys1', path: r'$..a');
    //     print("jsonObjkeys1 Val.toString() : ${Val1}");
    //
    //     // var Val2 = await client.jsonDel('test-json-jsonObjkeys1');
    //     // print("jsonObjkeys1 Val.toString() : ${Val2}");
    //   } catch (e) {
    //     print("An error occurred: $e");
    //   }
    // }, skip: 'jsonObjkeys Skipping this test temporarily');

    // todo 待解决
    // test('jsonStrappend command test', () async {
    //   try {
    //     await client.jsonSet(
    //       key: 'test-json-jsonStrappend1',
    //       value: '{"a":"foo", "nested": {"a": "hello"}, "nested2": {"a": 31}}',
    //     );
    //
    //     var Val1 = await client.jsonStrappend(
    //       'test-json-jsonStrappend1',
    //       path: r'$..a',
    //       value: '"baz"',
    //     );
    //     print("jsonStrappend1 Val.toString() : ${Val1}");
    //   } catch (e) {
    //     print("An error occurred: $e");
    //   }
    // }, skip: 'jsonStrappend Skipping this test temporarily');

    // todo 执行有问题
    //   test('jsonStrlen command test', () async {
    //     try {
    //       await client.jsonSet(
    //         key: 'test-json-jsonStrlen1',
    //         value: '{"a":"foo", "nested": {"a": "hello"}, "nested2": {"a": 31}}',
    //       );
    //
    //       var Val1 = await client.jsonStrappend(
    //         'test-json-jsonStrlen1',
    //         path: r'$..a',
    //         value: '"baz"',
    //       );
    //       print("jsonStrlen1 Val.toString() : ${Val1}");
    //     } catch (e) {
    //       print("An error occurred: $e");
    //     }
    //   }, skip: 'jsonStrlen Skipping this test temporarily');
  });
}
