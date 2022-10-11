
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '.env.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'directions_model.dart';

class DirectionsRep{
  static const String _baseURL = 'https://maps.googleapis.com/maps/api/directions/json?';
  late Dio _dio;

  DirectionsRep({Dio? dio}): _dio = dio??Dio();

  Future<Directions?> getDirections({
    @required LatLng? origin,
    @required LatLng? destination,
    @required String? mode
  })async{
    final response = await _dio.get(
      _baseURL,
      queryParameters: {
        'origin':'${origin!.latitude},${origin.longitude}',
        'destination':'${destination!.latitude},${destination.longitude}',
        'key':googleAPIKey,
        'mode': mode
      }
    );
    if (response.statusCode == 200) {
      print(response.data['routes'][0]['legs'][0]);
      
      
      return Directions.fromMap(response.data);
    }
    return null;
  }
}