import 'package:mapping_in_flutter/data/api/api_service.dart';
import 'package:mapping_in_flutter/data/models/lat_long.dart';

class GeocodingRepo {
  GeocodingRepo({required this.apiService});

  final ApiService apiService;

  Future<String> getAddress(LatLong latLong, String kind) =>
      apiService.getLocationName(geoCodeText: "${latLong.longitude},${latLong.lattitude}",kind:kind );
}
