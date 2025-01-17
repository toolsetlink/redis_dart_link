part of client;

///
/// Base class for all RESP3 types.
/// 所有RESP3类型的基类。
///
abstract class RespType3<P> {
  /// prefix
  final String prefix;

  /// payload
  final P payload;

  const RespType3._(this.prefix, this.payload);

  ///
  /// Serializes this type to RESP.
  /// 将此类型序列化为RESP。
  ///
  List<int> serialize() {
    return utf8.encode('$prefix$payload$suffix');
  }

  @override
  String toString() {
    return utf8.decode(serialize());
  }

  ///
  /// The name of the concrete type.
  /// 具体类型的名称。
  ///
  String get typeName;

  ///
  /// Calls one of the given handlers based on the
  /// concrete type. Returns [true] if a handler for
  /// the concrete type was provided, otherwise [false]
  /// is returned. If the handler throws an error while
  /// executing, the error is raised to the caller of
  /// this method.
  ///
  /// 方法调用一个给定的处理程序具体类型。处理程序返回[true]
  /// 提供具体类型，否则为[false]返回。如果处理程序抛出错误
  /// 执行时，将错误引发给方法的调用者。
  T handleAs<T>({
    T Function(RespSimpleString3)? simple,
    T Function(RespBulkString3)? bulk,
    T Function(RespInteger3)? integer,
    T Function(RespArray3)? array,
    T Function(RespError3)? error,
    T Function(RespMap3)? map,
    T Function(RespNull3)? null3,
  }) {
    if (isSimpleString && simple != null) {
      return simple(toSimpleString());
    } else if (isBulkString && bulk != null) {
      return bulk(toBulkString());
    } else if (isInteger && integer != null) {
      return integer(toInteger());
    } else if (isArray && array != null) {
      return array(toArray());
    } else if (isError && error != null) {
      return error(toError());
    } else if (isMap && map != null) {
      return map(toMap());
    } else if (isNull && null3 != null) {
      return null3(toNull());
    }

    throw ArgumentError('No handler provided for type $typeName!');
  }

  ///
  /// Converts this type to a simple string. Throws a
  /// [StateError] if this is not a simple string.
  ///
  RespSimpleString3 toSimpleString() =>
      throw StateError('${toString()} is not a simple string!');

  ///
  /// Converts this type to a bulk string. Throws a
  /// [StateError] if this is not a bulk string.
  ///
  RespBulkString3 toBulkString() =>
      throw StateError('${toString()} is not a bulk string!');

  ///
  /// Converts this type to an integer. Throws a
  /// [StateError] if this is not an integer.
  ///
  RespInteger3 toInteger() =>
      throw StateError('${toString()} is not an integer!');

  ///
  /// Converts this type to an array. Throws a
  /// [StateError] if this is not an array.
  ///
  RespArray3 toArray() => throw StateError('${toString()} is not an array!');

  ///
  /// Converts this type to an error. Throws a
  /// [StateError] if this is not an error.
  ///
  RespError3 toError() => throw StateError('${toString()} is not an error!');

  ///
  /// Converts this type to an map. Throws a
  /// [StateError] if this is not an map.
  ///
  RespMap3 toMap() => throw StateError('${toString()} is not an map!');

  ///
  /// Converts this type to an null. Throws a
  /// [StateError] if this is not an null.
  ///
  RespNull3 toNull() => throw StateError('${toString()} is not an null!');

  ///
  /// Return [true] if this type is a simple string.
  ///
  bool get isSimpleString => false;

  ///
  /// Return [true] if this type is a bulk string.
  ///
  bool get isBulkString => false;

  ///
  /// Return [true] if this type is an integer.
  /// 如果此类型为整数，则返回[true]。
  ///
  bool get isInteger => false;

  ///
  /// Return [true] if this type is an array.
  /// 如果此类型是数组，则返回[true]。
  ///
  bool get isArray => false;

  ///
  /// Return [true] if this type is an error.
  /// 如果此类型是错误，则返回[true]。
  ///
  bool get isError => false;

  ///
  /// Return [true] if this type is an map.
  /// 如果此类型为map，则返回[true]。
  ///
  bool get isMap => false;

  ///
  /// Return [true] if this type is an null.
  /// 如果此类型为null，则返回[true]。
  ///
  bool get isNull => false;
}

///
/// Implementation of a RESP simple string.
///
class RespSimpleString3 extends RespType3<String> {
  const RespSimpleString3(String payload) : super._('+', payload);

  @override
  RespSimpleString3 toSimpleString() => this;

  @override
  bool get isSimpleString => true;

  @override
  String get typeName => 'simple string';
}

///
/// Implementation of a RESP bulk string.
/// 实现一个RESP批量字符串。
///
class RespBulkString3 extends RespType3<String?> {
  static final nullString = utf8.encode('\_$suffix');

  /// Resp3BulkString
  const RespBulkString3(String? payload) : super._('\$', payload);

  @override
  List<int> serialize() {
    final pl = payload;
    if (pl != null) {
      final length = utf8.encode(pl).length;
      return utf8.encode('$prefix${length}$suffix$pl$suffix');
    }
    return nullString;
  }

  @override
  RespBulkString3 toBulkString() => this;

  @override
  bool get isBulkString => true;

  @override
  String get typeName => 'bulk string';
}

///
/// Implementation of a RESP integer.
/// 实现一个RESP整数。
///
class RespInteger3 extends RespType3<int> {
  /// RespInteger
  const RespInteger3(int payload) : super._(':', payload);

  @override
  RespInteger3 toInteger() => this;

  @override
  List<int> serialize() {
    return utf8.encode('$prefix${payload}');
  }

  @override
  bool get isInteger => true;

  @override
  String get typeName => 'integer';
}

///
/// Implementation of a RESP array.
/// 一个RESP数组的实现。
class RespArray3 extends RespType3<List<RespType3>?> {
  /// nullArray
  static final nullArray = utf8.encode('\*-1$suffix');

  /// RespArray3
  const RespArray3(List<RespType3>? payload) : super._('*', payload);

  @override
  List<int> serialize() {
    final pl = payload;
    if (pl != null) {
      return [
        ...utf8.encode('$prefix${pl.length}$suffix'),
        ...pl.expand((element) => element.serialize()),
        ...utf8.encode('$suffix'),
      ];
    }
    return nullArray;
  }

  @override
  RespArray3 toArray() => this;

  @override
  bool get isArray => true;

  @override
  String get typeName => 'array';
}

///
/// Implementation of a RESP error.
/// 实现一个RESP错误。
///
class RespError3 extends RespType3<String> {
  /// RespError3
  const RespError3(String payload) : super._('-', payload);

  @override
  RespError3 toError() => this;

  @override
  bool get isError => true;

  @override
  String get typeName => 'error';
}

///
/// Implementation of a RESP null.
/// 实现一个RESP错误。
///
class RespNull3 extends RespType3<String> {
  /// RespError3
  const RespNull3(String payload) : super._('_', payload);

  @override
  RespNull3 toNull() => this;

  @override
  bool get isNull => true;

  @override
  String get typeName => 'null';
}

///
/// Implementation of a RESP map.
/// 一个RESP map的实现。
///
class RespMap3 extends RespType3<List<RespType3>?> {
  static final nullMap = utf8.encode('%0$suffix');

  /// RespMap3
  const RespMap3(List<RespType3>? payload) : super._('%', payload);

  @override
  List<int> serialize() {
    final pl = payload;
    if (pl != null) {
      return [
        ...utf8.encode('$prefix${pl.length}$suffix'),
        ...pl.expand((element) => element.serialize()),
        ...utf8.encode('$suffix'),
      ];
    }
    return nullMap;
  }

  @override
  RespMap3 toMap() => this;

  @override
  bool get isMap => true;

  @override
  String get typeName => 'map';
}

/// deserializeRespType
Future<RespType3> deserializeRespType3(StreamReader streamReader) async {
  final typePrefix = await streamReader.takeOne();
  // print("deserializeRespType3() typePrefix: $typePrefix");

  // 0x0d 回车
  // 0x2b：加号（+）     43  simple string
  // 0x2d：减号（-）     45  error
  // 0x3a：冒号（:）     58  integer
  // 0x24：美元符号（$）  36  bulk string
  // 0x2a：星号（*）     42  array
  // 0x25：百分号（%）   37  map /// 实际使用跟 array 一样
  // 0x5F：(_)         95  Null
  // 0x2C：(,)         44  Double
  // 0x23：(#)         35  Boolean  // 其中true被表示为#t\r\n，而false被表示为#f\r\n
  // 0x21：(!)         33  Blob error
  // 0x3D：(=)         61  Verbatim string
  // 0x28：(()         40  Big number
  // 0x7E：(~)         126 Set /// 实际使用跟 array 一样
  // 0x7C：(|)         124 Attribute
  // 0x3E：(>)         62  Push /// 实际使用 Blob string
  // Stream 未实装
  switch (typePrefix) {
    case 0x2b: // simple string
      final payload =
          utf8.decode(await streamReader.takeWhile((data) => data != 0x0d));
      await streamReader.takeCount(2);
      return RespSimpleString3(payload);
    case 0x2d: // error
      final payload =
          utf8.decode(await streamReader.takeWhile((data) => data != 0x0d));
      await streamReader.takeCount(2);
      return RespError3(payload);
    case 0x3a: // integer
      final payload = int.parse(
          utf8.decode(await streamReader.takeWhile((data) => data != 0x0d)));
      await streamReader.takeCount(2);
      return RespInteger3(payload);
    case 0x24: // bulk string
      final length = int.parse(
          utf8.decode(await streamReader.takeWhile((data) => data != 0x0d)));
      await streamReader.takeCount(2);
      if (length == -1) {
        return RespBulkString3(null);
      }
      final payload = utf8.decode(await streamReader.takeCount(length));
      await streamReader.takeCount(2);
      return RespBulkString3(payload);
    case 0x2a: // array
      final count = int.parse(
          utf8.decode(await streamReader.takeWhile((data) => data != 0x0d)));
      await streamReader.takeCount(2);
      if (count == -1) {
        return RespArray3(null);
      }
      final elements = <RespType3>[];
      for (var i = 0; i < count; i++) {
        elements.add(await deserializeRespType3(streamReader));
      }
      return RespArray3(elements);
    case 0x25: // map
      final count = int.parse(
          utf8.decode(await streamReader.takeWhile((data) => data != 0x0d)));
      await streamReader.takeCount(2);
      if (count == -1) {
        return RespMap3(null);
      }
      final elements = <RespType3>[];
      for (var i = 0; i < count; i++) {
        elements.add(await deserializeRespType3(streamReader));
      }
      return RespMap3(elements);
    default:
      throw StateError('resp3 unexpected character: $typePrefix');
  }
}
