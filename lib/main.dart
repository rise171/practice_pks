import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_compass/flutter_compass.dart';

void main() => runApp(const GeoSensorsApp());

class GeoSensorsApp extends StatelessWidget {
  const GeoSensorsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Geo & Sensors',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          brightness: Brightness.light,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8),
        ),
      ),
      home: const GeoSensorsPage(),
    );
  }
}

class GeoSensorsPage extends StatefulWidget {
  const GeoSensorsPage({super.key});
  @override
  State<GeoSensorsPage> createState() => _GeoSensorsPageState();
}

class _GeoSensorsPageState extends State<GeoSensorsPage> {
  Position? _position;
  String _address = '–';
  List<double>? _accelerometerValues;
  List<double>? _gyroscopeValues;
  double? _compassHeading;

  Future<void> _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) return;

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    List<Placemark> placemarks = await placemarkFromCoordinates(
      pos.latitude,
      pos.longitude,
    );

    setState(() {
      _position = pos;
      _address =
      '${placemarks.first.locality}, ${placemarks.first.street ?? ''}';
    });
  }

  @override
  void initState() {
    super.initState();

    // Акселерометр
    accelerometerEvents.listen((event) {
      setState(() => _accelerometerValues = [event.x, event.y, event.z]);
    });

    // Гироскоп
    gyroscopeEvents.listen((event) {
      setState(() => _gyroscopeValues = [event.x, event.y, event.z]);
    });

    // Компас
    FlutterCompass.events?.listen((event) {
      setState(() {
        _compassHeading = event.heading;
      });
    });
  }

  Widget _buildInfoCard(String title, String value, {IconData? icon}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20, color: Colors.red.shade700),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geo & Sensors'),
        backgroundColor: Colors.red.shade100,
        foregroundColor: Colors.red.shade800,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.red.shade700),
      ),
      body: Container(
        color: Colors.red.shade50,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              FilledButton(
                onPressed: _getLocation,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_on_outlined, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Определить местоположение',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'Геолокация',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.red.shade800, // Красный заголовок
                ),
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                'Координаты',
                _position != null
                    ? '${_position!.latitude.toStringAsFixed(6)}, ${_position!.longitude.toStringAsFixed(6)}'
                    : '–',
                icon: Icons.my_location_outlined,
              ),
              _buildInfoCard(
                  'Адрес',
                  _address,
                  icon: Icons.place_outlined
              ),
              const SizedBox(height: 24),

              // Компас
              Text(
                'Компас',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.red.shade800,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: _buildCompassVisualization(),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Sensors Section
              Text(
                'Датчики',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.red.shade800,
                ),
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                'Акселерометр',
                _accelerometerValues != null
                    ? 'X: ${_accelerometerValues![0].toStringAsFixed(2)}\n'
                    'Y: ${_accelerometerValues![1].toStringAsFixed(2)}\n'
                    'Z: ${_accelerometerValues![2].toStringAsFixed(2)}'
                    : '–',
                icon: Icons.directions_run_outlined,
              ),
              _buildInfoCard(
                'Гироскоп',
                _gyroscopeValues != null
                    ? 'X: ${_gyroscopeValues![0].toStringAsFixed(2)}\n'
                    'Y: ${_gyroscopeValues![1].toStringAsFixed(2)}\n'
                    'Z: ${_gyroscopeValues![2].toStringAsFixed(2)}'
                    : '–',
                icon: Icons.sync_outlined,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompassVisualization() {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.red.shade400,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.red.shade100,
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 10,
                child: Text(
                  'N',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
              ),
              Positioned(
                right: 10,
                child: Text(
                  'E',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                child: Text(
                  'S',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
              ),
              Positioned(
                left: 10,
                child: Text(
                  'W',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
              ),
              // Стрелка компаса
              Transform.rotate(
                angle: (_compassHeading ?? 0) * (3.14159 / 180),
                child: Icon(
                  Icons.navigation,
                  size: 50,
                  color: Colors.red.shade600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _compassHeading != null
              ? '${_compassHeading!.toStringAsFixed(1)}°'
              : '–',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.red.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _getDirectionName(_compassHeading ?? 0),
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  String _getDirectionName(double degrees) {
    if (degrees >= 337.5 || degrees < 22.5) return 'Север';
    if (degrees >= 22.5 && degrees < 67.5) return 'Северо-Восток';
    if (degrees >= 67.5 && degrees < 112.5) return 'Восток';
    if (degrees >= 112.5 && degrees < 157.5) return 'Юго-Восток';
    if (degrees >= 157.5 && degrees < 202.5) return 'Юг';
    if (degrees >= 202.5 && degrees < 247.5) return 'Юго-Запад';
    if (degrees >= 247.5 && degrees < 292.5) return 'Запад';
    return 'Северо-Запад';
  }
}