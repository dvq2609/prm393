import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class OrderTrackingPage extends StatefulWidget {
  final LatLng shipperLocation;
  final LatLng customerLocation;

  const OrderTrackingPage({
    super.key,
    required this.shipperLocation,
    required this.customerLocation,
  });

  @override
  State<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends State<OrderTrackingPage> {
  List<LatLng> routePoints = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRoute();
  }

  Future<void> _fetchRoute() async {
    final lon1 = widget.shipperLocation.longitude;
    final lat1 = widget.shipperLocation.latitude;
    final lon2 = widget.customerLocation.longitude;
    final lat2 = widget.customerLocation.latitude;
    
    // API OSRM: http://router.project-osrm.org/route/v1/driving/{lon},{lat};{lon},{lat}
    final String url = 'http://router.project-osrm.org/route/v1/driving/$lon1,$lat1;$lon2,$lat2?geometries=geojson';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final routes = data['routes'] as List;
        if (routes.isNotEmpty) {
          final geometry = routes[0]['geometry'];
          final coordinates = geometry['coordinates'] as List;
          
          List<LatLng> points = coordinates.map((coord) {
            return LatLng(coord[1], coord[0]); // GeoJSON is [lon, lat], latlong2 is [lat, lon]
          }).toList();

          setState(() {
            routePoints = points;
            isLoading = false;
          });
        }
      } else {
        // Fallback nét thẳng nếu API quá tải
        setState(() {
          routePoints = [widget.shipperLocation, widget.customerLocation];
          isLoading = false;
        });
      }
    } catch (e) {
      // Xử lý lỗi
      setState(() {
        routePoints = [widget.shipperLocation, widget.customerLocation];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Zoom sao cho thấy được cả shipper và khách hàng
    final bounds = LatLngBounds.fromPoints([
      widget.shipperLocation,
      widget.customerLocation,
      ...routePoints,
    ]);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theo dõi đơn hàng'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(
          color: Colors.black, 
          fontSize: 18, 
          fontWeight: FontWeight.bold
        ),
      ),
      body: isLoading 
          ? const Center(child: CircularProgressIndicator()) 
          : FlutterMap(
              options: MapOptions(
                initialCameraFit: CameraFit.bounds(
                  bounds: bounds,
                  padding: const EdgeInsets.all(50.0),
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.prm393', // Tên package ứng dụng
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routePoints,
                      strokeWidth: 4.0,
                      color: Colors.blueAccent,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: widget.shipperLocation,
                      width: 50,
                      height: 50,
                      child: const _MapPin(
                        icon: Icons.local_shipping, 
                        color: Colors.green
                      ),
                    ),
                    Marker(
                      point: widget.customerLocation,
                      width: 50,
                      height: 50,
                      child: const _MapPin(
                        icon: Icons.person_pin, 
                        color: Colors.redAccent
                      ),
                    ),
                  ],
                )
              ],
            ),
    );
  }
}

class _MapPin extends StatelessWidget {
  final IconData icon;
  final Color color;
  
  const _MapPin({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}
