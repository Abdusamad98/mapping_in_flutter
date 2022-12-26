import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mapping_in_flutter/data/geocoding/geocoding.dart';
import 'package:mapping_in_flutter/utils/constants.dart';

class ApiService {
  Dio dio = Dio();

  Future<String> getLocationName({required String geoCodeText, required String kind}) async {
    String text = '';
    try {
      late Response response;
      Map<String, String> queryParams = {
        'apikey': mapApiKey,
        'geocode': geoCodeText,
        'lang': 'uz_UZ',
        'format': 'json',
        'kind': kind,
        'rspn': '1',
        'results': '1',
      };
      debugPrint("QueryParams>>>>>>>>>>$queryParams");
      response = await dio.get(
        "https://geocode-maps.yandex.ru/1.x/",
        queryParameters: queryParams,
      );

      if (response.statusCode! == HttpStatus.ok) {
        Geocoding geocoding = Geocoding.fromJson(response.data);
        if (geocoding.response.geoObjectCollection.featureMember.isNotEmpty) {
          text = geocoding.response.geoObjectCollection.featureMember[0]
              .geoObject.metaDataProperty.geocoderMetaData.text;
          debugPrint("text>>>>>>>>>>>> $text");
        } else {
          text = 'Aniqlanmagan hudud';
        }
        return text;
      } else {
        throw Exception();
      }
    } catch (e) {
      throw Exception(e);
    }
  }
}
