import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class LocationPicker extends StatefulWidget {
  const LocationPicker({super.key});

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  LatLng? selectedLocation;
  bool isLoading = true;
  LatLng defaultCenter = const LatLng(21.0131, 105.5271); // Default is FPT Hanoi

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() { isLoading = false; });
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      // Nếu user cố tình từ chối hoặc đã từ chối vĩnh viễn
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        setState(() { isLoading = false; });
        return;
      }

      // Giới hạn 5 giây để lấy GPS, nếu máy ảo không có GPS sẽ bung catch
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 5));
      
      setState(() {
        defaultCenter = LatLng(position.latitude, position.longitude);
        selectedLocation = defaultCenter; 
        isLoading = false;
      });
    } catch (e) {
      // Nếu lỗi (timeout, máy ảo không có toạ độ), thoát loading để user còn dùng app
      if (mounted) {
        setState(() { isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn vị trí giao hàng', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        actions: [
          if (selectedLocation != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context, selectedLocation);
              },
              child: const Text("XONG", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
        ],
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator()) 
        : Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: defaultCenter,
              initialZoom: 15.0,
              onTap: (tapPosition, point) {
                setState(() {
                  selectedLocation = point;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.prm393',
              ),
              if (selectedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: selectedLocation!,
                      width: 50,
                      height: 50,
                      alignment: Alignment.topCenter,
                      child: const Icon(Icons.location_on, color: Colors.red, size: 50),
                    )
                  ],
                )
            ],
          ),
          if (selectedLocation == null)
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8)
                ),
                child: const Text(
                  "Chạm vào bản đồ để chọn vị trí nhận hàng",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            )
        ],
      ),
    );
  }
}
