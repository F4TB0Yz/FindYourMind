class MapUtils {
  static Map<String, dynamic> convertToMap(dynamic data) {
    if (data is Map) {
      return data.map((key, value) {
        if (value is List) {
          return MapEntry(
            key.toString(),
            value.map((item) {
              if (item is Map) {
                return MapUtils.convertToMap(item);
              }
              return item;
            }).toList(),
          );
        } else if (value is Map) {
          return MapEntry(key.toString(), MapUtils.convertToMap(value));
        }
        return MapEntry(key.toString(), value);
      });
    }
    return {};
  }
}