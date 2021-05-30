import 'package:system/map/fixed_gps_icon.dart';
import 'package:system/map/location_user.dart';
import 'package:system/map/map_option.dart';
import 'package:system/map/range_radius.dart';
import 'package:system/map/search_place.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'bloc/maps_bloc.dart';
import 'bloc/maps_event.dart';
import 'bloc/maps_state.dart';

class Maps extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MapState();
  }
}

class _MapState extends State<Maps> {
  GoogleMapController _controller;
  final Set<Marker> _markers = {};
  final Set<Circle> _circle = {};
  double _radius = 100.0;
  double _zoom = 18.0;
  bool _showFixedGpsIcon = false;
  bool _isRadiusFixed = false;
  String error;

  ///starting location on the map .

  static const LatLng _center = const LatLng(33.64465251537059, 72.95860641609693);
  MapType _currentMapType = MapType.normal;
  LatLng _lastMapPosition = _center;

  /// worked with blocs
  /// maps_bloc.dart
  MapsBloc _mapsBloc;

  Widget _googleMapsWidget(MapsState state) {

    /// generating marker to the starting location
    return GoogleMap(
      onTap: (LatLng location) {
        if (_isRadiusFixed) {
          _mapsBloc.add(GenerateMarkerToCompareLocation(
              mapPosition: location,
              radiusLocation: _lastMapPosition,
              radius: _radius));
        }
      },
      onMapCreated: _onMapCreated,
      myLocationButtonEnabled: true,
      initialCameraPosition: CameraPosition(
        target: _center,
        zoom: _zoom,
      ),
      circles: _circle,
      markers: _markers,
      onCameraMove: _onCameraMove,
      onCameraIdle: () {
        if (_isRadiusFixed != true)
          _mapsBloc.add(

            /// generating marker with radius
            GenerateMarkerWithRadius(
                lastPosition: _lastMapPosition, radius: _radius),
          );
      },
      mapType: _currentMapType,
    );
  }

  @override
  void initState() {
    super.initState();
    _mapsBloc = BlocProvider.of<MapsBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener(
        bloc: _mapsBloc,
        listener: (BuildContext context, MapsState state) {

          ///setting the last position of the map to the user location

          if (state is LocationUserfound) {
            Scaffold.of(context)..hideCurrentSnackBar();
            _lastMapPosition =
                LatLng(state.locationModel.lat, state.locationModel.long);
            _animateCamera();
          }
          if (state is MarkerWithRadius) {
            Scaffold.of(context)..hideCurrentSnackBar();
            _showFixedGpsIcon = false;

            if (_markers.isNotEmpty) {
              _markers.clear();
            }
            if (_circle.isNotEmpty) {
              _circle.clear();
            }
            _markers.add(state.raidiusModel.marker);
            _circle.add(state.raidiusModel.circle);
          }
          /// fixing the radius on the map

          if (state is RadiusFixedUpdate) {
            Scaffold.of(context)..hideCurrentSnackBar();
            _isRadiusFixed = state.radiusFixed;
          }
          /// changing the type of map

          if (state is MapTypeChanged) {
            Scaffold.of(context)..hideCurrentSnackBar();
            _currentMapType = state.mapType;
          }

          /// updating the radius
          if (state is RadiusUpdate) {
            Scaffold.of(context)..hideCurrentSnackBar();
            _radius = state.radius;
            _zoom = state.zoom;
            _animateCamera();
          }
          if (state is MarkerWithSnackbar) {
            _markers.add(state.marker);
            Scaffold.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(state.snackBar);
          }
          if (state is LocationFromPlaceFound) {
            Scaffold.of(context)..hideCurrentSnackBar();
            _lastMapPosition =
                LatLng(state.locationModel.lat, state.locationModel.long);
          }

          /// getting the result of the map
          if (state is Failure) {
            print('Failure');
            Scaffold.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Text('Error'), Icon(Icons.error)],
                  ),
                  backgroundColor: Colors.red,
                ),
              );
          }
          if (state is Loading) {
            print('loading');
            Scaffold.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Charging'),
                      CircularProgressIndicator(),
                    ],
                  ),
                ),
              );
          }
        },
        child: BlocBuilder(
            bloc: _mapsBloc,
            builder: (BuildContext context, MapsState state) {
              return Scaffold(
                body: Stack(
                  children: <Widget>[

                    /// getting all the widgets in the stack form different classes

                    _googleMapsWidget(state),

                    /// calling from fixed_gps_icon.dart file
                    FixedLocationGps(showFixedGpsIcon: _showFixedGpsIcon),
                    /// calling from map_option.dart file
                    MapOption(mapType: _currentMapType),
                    /// calling from location_user.dart file
                    LocationUser(),
                    /// calling from search_place.dart file
                    SearchPlace(onPressed: _animateCamera),
                    /// calling from range_radius.dart file
                    RangeRadius(isRadiusFixed: _isRadiusFixed),
                  ],
                ),
              );
            }),
      ),
    );
  }


  /// functions for map
  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
  }

  void _onCameraMove(CameraPosition position) {
    if (!_isRadiusFixed) _lastMapPosition = position.target;
    if (_showFixedGpsIcon != true && _isRadiusFixed != true) {
      setState(() {
        _showFixedGpsIcon = true;
        if (_markers.isNotEmpty) {
          _markers.clear();
          _circle.clear();
        }
      });
    }
  }

  void _animateCamera() {
    _controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _lastMapPosition,
          zoom: _zoom,
        ),
      ),
    );
  }
}
