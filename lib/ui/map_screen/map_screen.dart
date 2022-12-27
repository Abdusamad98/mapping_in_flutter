import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mapping_in_flutter/data/api/api_service.dart';
import 'package:mapping_in_flutter/data/models/lat_long.dart';
import 'package:mapping_in_flutter/data/repositories/geociding_repository.dart';
import 'package:mapping_in_flutter/ui/map_screen/widgets/my_drop_down.dart';
import 'dart:ui' as ui;
import 'package:mapping_in_flutter/view_models/map_view_model.dart';
import 'package:provider/provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key, required this.latLong}) : super(key: key);
  final LatLong latLong;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  late CameraPosition initialCameraPosition;
  late CameraPosition cameraPosition;

  Set<Marker> mapMarkers = {
    const Marker(
      markerId: MarkerId("id_1"),
      infoWindow: InfoWindow(
        title: "Najot Ta'lim",
        snippet: "Zamonaviy kasblar markazi",
      ),
      position: LatLng(
        41.286393176986685,
        69.20411702245474,
      ),
    ),
  };

  _init() {
    initialCameraPosition = CameraPosition(
      target: LatLng(
        widget.latLong.lattitude,
        widget.latLong.longitude,
      ),
      zoom: 15,
    );
    cameraPosition = CameraPosition(
      target: LatLng(
        widget.latLong.lattitude,
        widget.latLong.longitude,
      ),
      zoom: 15,
    );

    // SystemChrome.setSystemUIOverlayStyle(
    //   const SystemUiOverlayStyle(
    //     statusBarColor: Colors.transparent,
    //     statusBarBrightness: Brightness.dark,
    //     statusBarIconBrightness: Brightness.dark,
    //   ),
    // );
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          MapViewModel(geocodingRepo: GeocodingRepo(apiService: ApiService())),
      builder: (context, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarBrightness: Brightness.dark,
            statusBarIconBrightness: Brightness.dark,
          ),
          child: Scaffold(
            body: Consumer<MapViewModel>(
              builder: (context, viewModel, child) {
                return Stack(
                  children: [
                    GoogleMap(
                      markers: mapMarkers,
                      padding: const EdgeInsets.all(16),
                      //  myLocationEnabled: true,
                      // liteModeEnabled: true,
                      // zoomControlsEnabled: false,
                      // zoomGesturesEnabled: true,
                      mapType: MapType.normal,
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                      },
                      initialCameraPosition: initialCameraPosition,
                      onCameraMoveStarted: () {
                        print("MOVE STARTED");
                      },
                      onCameraMove: (position) {
                        print("CAMERA POSITION:${position.target.toString()}");
                        cameraPosition = position;
                      },
                      //polylines: ,
                      onCameraIdle: () {
                        print("CAMERA POSITION STOPPED");
                        print(
                            "CAMERA POSITION STOPPED:${cameraPosition.target.toString()}");
                        context.read<MapViewModel>().fetchAddress(
                              latLong: LatLong(
                                lattitude: cameraPosition.target.latitude,
                                longitude: cameraPosition.target.longitude,
                              ),
                              kind: "house",
                            );
                      },
                    ),
                    Positioned(
                      top: 100,
                      left: 0,
                      right: 0,
                      child: Text(
                        viewModel.addressText,
                        maxLines: 5,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 22,
                          overflow: TextOverflow.ellipsis,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: 50,
                        height: 50,
                        child: Image.asset(
                          "assets/location_icon.png",
                        ),
                      ),
                    ),
                    Positioned(
                      top: 50,
                      left: 20,
                      child: MyDropDown(
                        onDropSelected: (value) {},
                      ),
                    ),
                  ],
                );
              },
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                // mapMarkers.add(
                //   Marker(
                //       markerId: MarkerId(
                //           cameraPosition.target.latitude.toString()),
                //       infoWindow: InfoWindow(
                //         title: "Manzil",
                //         snippet: context
                //             .read<MapViewModel>()
                //             .addressText,
                //       ),
                //       position: cameraPosition.target,
                //   ),
                // );
                _addMarker(context.read<MapViewModel>().addressText);
              },
              child: const Icon(Icons.done),
            ),
          ),
        );
      },
    );
  }

  Future<void> _addMarker(String title) async {
    Uint8List markerImage = await getBytesFromAsset(
      "assets/courier.png",
      150,
    );
    mapMarkers.add(
      Marker(
        markerId: MarkerId(cameraPosition.target.latitude.toString()),
        infoWindow: InfoWindow(
          title: "Manzil",
          snippet: title,
        ),
        position: cameraPosition.target,
        icon: BitmapDescriptor.fromBytes(markerImage),
      ),
    );
    setState(() {});
  }

  static Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
    );
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }
}
