import 'package:flutter/cupertino.dart';
import 'package:mapping_in_flutter/data/models/lat_long.dart';
import 'package:mapping_in_flutter/data/repositories/geociding_repository.dart';

class MapViewModel extends ChangeNotifier {
  MapViewModel({required this.geocodingRepo});

  final GeocodingRepo geocodingRepo;

  String addressText = "";

  fetchAddress({required LatLong latLong, required String kind}) async {
    print("CAME1");
    addressText = await geocodingRepo.getAddress(latLong, kind);
    print("CAM2");
    notifyListeners();
  }
}
