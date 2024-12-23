import '../src/client.dart';

/// GeoPos
class GeoPos {
  final List<GeoPoint> positions; // 存储地理坐标的列表

  GeoPos({
    required this.positions,
  });

  factory GeoPos.fromResult(List<RespType<dynamic>>? result) {
    var _positions = <GeoPoint>[];

    if (result != null) {
      for (var item in result) {
        if (item is RespArray) {
          final coords = item.payload;
          if (coords != null && coords.length == 2) {
            final longitudeItem = coords[0] as RespBulkString;
            final latitudeItem = coords[1] as RespBulkString;

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
