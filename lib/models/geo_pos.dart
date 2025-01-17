part of models;

/// GeoPos
class GeoPos {
  /// 存储地理坐标的列表
  final List<GeoPoint> positions;

  /// GeoPos
  GeoPos({
    required this.positions,
  });

  /// fromResult
  factory GeoPos.fromResult(Object reqResult) {
    var _positions = <GeoPoint>[];

    if (reqResult is RespType2<dynamic>) {
      final result = reqResult.toArray().payload;
      if (result != null) {
        for (var item in result) {
          if (item is RespArray2) {
            final coords = item.payload;
            if (coords != null && coords.length == 2) {
              final longitudeItem = coords[0] as RespBulkString2;
              final latitudeItem = coords[1] as RespBulkString2;

              if (longitudeItem.payload != null &&
                  latitudeItem.payload != null) {
                final longitude = double.parse(longitudeItem.payload!);
                final latitude = double.parse(latitudeItem.payload!);
                _positions
                    .add(GeoPoint(longitude: longitude, latitude: latitude));
              }
            }
          }
        }
      }
      return GeoPos(positions: _positions);
    }

    final result = (reqResult as RespType3<dynamic>).toArray().payload;
    if (result != null) {
      for (var item in result) {
        if (item is RespArray3) {
          final coords = item.payload;
          if (coords != null && coords.length == 2) {
            final longitudeItem = coords[0] as RespBulkString2;
            final latitudeItem = coords[1] as RespBulkString2;

            if (longitudeItem.payload != null && latitudeItem.payload != null) {
              final longitude = double.parse(longitudeItem.payload!);
              final latitude = double.parse(latitudeItem.payload!);
              _positions
                  .add(GeoPoint(longitude: longitude, latitude: latitude));
            }
          }
        }
      }
    }

    return GeoPos(positions: _positions);
  }

  @override
  String toString() {
    return 'GeoPos(positions: $positions)';
  }
}

/// GeoPoint
class GeoPoint {
  /// longitude
  final double longitude;

  /// latitude
  final double latitude;

  /// GeoPoint
  GeoPoint({
    required this.longitude,
    required this.latitude,
  });

  @override
  String toString() {
    return 'GeoPoint(longitude: $longitude, latitude: $latitude)';
  }
}
