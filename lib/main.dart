import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

// ==========================================
// MÀU SẮC CHỦ ĐẠO (DARK THEME - JOY SAFE DRIVE)
// ==========================================
const Color navy = Color(0xFF0B192C);
const Color panel = Color(0xFF1E3E62);
const Color green = Color(0xFF00FF66);
const Color orange = Color(0xFFFF6F00);
const Color muted = Color(0xFF94A3B8);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const JoySafeDriveApp());
}

class JoySafeDriveApp extends StatelessWidget {
  const JoySafeDriveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Joy Safe Drive',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: navy,
        primaryColor: green,
        colorScheme: const ColorScheme.dark(
          primary: green,
          secondary: orange,
          surface: panel,
        ),
      ),
      home: const MainContainerScreen(),
    );
  }
}

// ==========================================
// TAB 1: TRANG CHỦ (HOME)
// ==========================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _currentSpeed = 0.0;
  String _latLngText = "Đang lấy tọa độ...";
  String _accuracyText = "--";
  bool _isTracking = false;
  StreamSubscription<Position>? _positionStream;
  late FlutterTts _flutterTts;

  @override
  void initState() {
    super.initState();
    _flutterTts = FlutterTts();
    _flutterTts.setLanguage("vi-VN");
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _toggleGpsTracking() async {
    if (_isTracking) {
      _positionStream?.cancel();
      setState(() {
        _isTracking = false;
        _currentSpeed = 0.0;
        _latLngText = "Đã dừng đo GPS";
        _accuracyText = "--";
      });
    } else {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() { _latLngText = "GPS chưa bật trên thiết bị!"; });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() { _latLngText = "Quyền vị trí bị từ chối!"; });
          return;
        }
      }

      setState(() {
        _isTracking = true;
        _latLngText = "Đang kết nối vệ tinh...";
      });

      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 1,
        ),
      ).listen((Position position) {
        setState(() {
          _currentSpeed = (position.speed >= 0) ? position.speed * 3.6 : 0.0;
          _latLngText = "${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}";
          _accuracyText = "${position.accuracy.toStringAsFixed(1)} m";
        });
      });
    }
  }

  Future<void> _openGoogleMaps() async {
    final Uri url = Uri.parse('https://www.google.com/maps/search/?api=1&query=TP.Hồ+Chí+Minh');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: panel,
        title: const Text('Joy Safe Drive', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: panel,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: green.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Text('TỐC ĐỘ THỰC TẾ (GPS)', style: TextStyle(color: muted, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        _currentSpeed.toStringAsFixed(0),
                        style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: green),
                      ),
                      const SizedBox(width: 5),
                      const Text('km/h', style: TextStyle(color: muted, fontSize: 16)),
                    ],
                  ),
                  const Divider(color: Colors.white24, height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Tọa độ Lat/Lng:', style: TextStyle(color: muted, fontSize: 11)),
                            const SizedBox(height: 2),
                            Text(_latLngText, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Độ chính xác:', style: TextStyle(color: muted, fontSize: 11)),
                          const SizedBox(height: 2),
                          Text(_accuracyText, style: const TextStyle(color: green, fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton.icon(
                    onPressed: _toggleGpsTracking,
                    icon: Icon(_isTracking ? Icons.stop : Icons.play_arrow, color: navy),
                    label: Text(_isTracking ? 'DỪNG ĐO GPS' : 'BẮT ĐẦU ĐO GPS', style: const TextStyle(fontWeight: FontWeight.bold, color: navy)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isTracking ? Colors.redAccent : green,
                      minimumSize: const Size(double.infinity, 45),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Hành trình của bạn', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 10),
                  const Text('Điểm đến: TP. Hồ Chí Minh', style: TextStyle(color: muted, fontSize: 13)),
                  const SizedBox(height: 15),
                  OutlinedButton.icon(
                    onPressed: _openGoogleMaps,
                    icon: const Icon(Icons.map, color: green),
                    label: const Text('MỞ GOOGLE MAPS', style: TextStyle(color: Colors.white)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: green),
                      minimumSize: const Size(double.infinity, 45),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
}

// ==========================================
// TAB 2: CẢNH BÁO (ALERTS)
// ==========================================
class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: panel, title: const Text('Cảnh báo an toàn', style: TextStyle(color: Colors.white))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          CardItem(title: 'Cảnh báo tốc độ', desc: 'Hệ thống tự động nhắc nhở bằng giọng nói khi bạn vượt quá tốc độ giới hạn cài đặt.', icon: Icons.speed, color: orange),
          CardItem(title: 'Thời tiết & Đường trơn', desc: 'Giảm tốc độ khi trời mưa lớn, tầm nhìn hạn chế để đảm bảo an toàn.', icon: Icons.water_drop, color: Colors.blueAccent),
          CardItem(title: 'Khu vực đông dân cư', desc: 'Chú ý quan sát biển báo hạn chế tốc độ khu vực nội đô.', icon: Icons.people, color: green),
        ],
      ),
    );
  }
}

// ==========================================
// TAB 3: HƯỚNG XỬ LÝ (GUIDE)
// ==========================================
class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: panel, title: const Text('Hướng xử lý khẩn cấp', style: TextStyle(color: Colors.white))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          CardItem(title: 'Xử lý khi mất phanh', desc: 'Giữ bình tĩnh, thả chân ga, bật đèn cảnh báo, về số thấp dần và kéo phanh tay từ từ.', icon: Icons.car_crash, color: Colors.redAccent),
          CardItem(title: 'Va chạm giao thông', desc: 'Dừng xe, bật đèn hazard, kiểm tra người bị thương, gọi cấp cứu và lực lượng chức năng nếu cần.', icon: Icons.medical_services, color: orange),
        ],
      ),
    );
  }
}

// ==========================================
// TAB 4: THIẾT BỊ (DEVICES)
// ==========================================
class DevicesScreen extends StatelessWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: panel, title: const Text('Thiết bị thông minh', style: TextStyle(color: Colors.white))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          CardItem(title: 'GPS tích hợp điện thoại', desc: 'Đang hoạt động - Đo tốc độ và tọa độ chính xác cao.', icon: Icons.phone_android, color: green),
          CardItem(title: 'Cảm biến Bluetooth ngoài', desc: 'Chưa kết nối - Nhấn để tìm kiếm thiết bị OBD2 hoặc cảm biến áp suất lốp.', icon: Icons.bluetooth, color: muted),
        ],
      ),
    );
  }
}

// ==========================================
// TAB 5: BẢN ĐỒ & TỐC ĐỘ THỜI GIAN THỰC (MAP & SPEEDOMETER)
// ==========================================
class SpeedometerMapScreen extends StatefulWidget {
  const SpeedometerMapScreen({super.key});

  @override
  State<SpeedometerMapScreen> createState() => _SpeedometerMapScreenState();
}

class _SpeedometerMapScreenState extends State<SpeedometerMapScreen> {
  double _currentSpeed = 0.0;
  int _speedLimit = 50;
  bool _isVoiceAlertsEnabled = true;
  
  StreamSubscription<Position>? _positionStream;
  late FlutterTts _flutterTts;
  final MapController _mapController = MapController();
  LatLng _currentLocation = const LatLng(10.7769, 106.7009);
  bool _hasLocation = false;
  DateTime? _lastSpokenTime;

  @override
  void initState() {
    super.initState();
    _initTts();
    _loadPreferences();
    _startLocationTracking();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _initTts() async {
    _flutterTts = FlutterTts();
    await _flutterTts.setLanguage("vi-VN");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _speedLimit = prefs.getInt('speed_limit') ?? 50;
      _isVoiceAlertsEnabled = prefs.getBool('voice_enabled') ?? true;
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('speed_limit', _speedLimit);
    await prefs.setBool('voice_enabled', _isVoiceAlertsEnabled);
  }

  Future<void> _speakAlert(String message) async {
    if (!_isVoiceAlertsEnabled) return;
    final now = DateTime.now();
    if (_lastSpokenTime != null && now.difference(_lastSpokenTime!).inSeconds < 10) {
      return;
    }
    _lastSpokenTime = now;
    await _flutterTts.speak(message);
  }

  Future<void> _startLocationTracking() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 1,
      ),
    ).listen((Position position) {
      setState(() {
        _currentSpeed = (position.speed >= 0) ? position.speed * 3.6 : 0.0;
        _currentLocation = LatLng(position.latitude, position.longitude);
        _hasLocation = true;
      });

      try {
        _mapController.move(_currentLocation, _mapController.camera.zoom);
      } catch (_) {}

      if (_currentSpeed > _speedLimit) {
        _speakAlert("Cảnh báo! Bạn đang chạy quá tốc độ cho phép.");
      }
    });
  }

  void _changeSpeedLimit(int newLimit) {
    setState(() {
      _speedLimit = newLimit;
    });
    _savePreferences();
  }

  @override
  Widget build(BuildContext context) {
    final isSpeeding = _currentSpeed > _speedLimit;

    return Scaffold(
      backgroundColor: navy,
      appBar: AppBar(
        backgroundColor: panel,
        elevation: 0,
        title: const Text(
          'Bản đồ & Tốc độ thời gian thực',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isVoiceAlertsEnabled ? Icons.volume_up : Icons.volume_off,
              color: green,
            ),
            onPressed: () {
              setState(() {
                _isVoiceAlertsEnabled = !_isVoiceAlertsEnabled;
              });
              _savePreferences();
              if (_isVoiceAlertsEnabled) {
                _flutterTts.speak("Đã bật cảnh báo giọng nói.");
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.my_location, color: green),
            onPressed: () {
              if (_hasLocation) {
                _mapController.move(_currentLocation, 16.0);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            color: panel,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('TỐC ĐỘ THỰC TẾ', style: TextStyle(color: muted, fontSize: 10, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          _currentSpeed.toStringAsFixed(0),
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: isSpeeding ? Colors.redAccent : green,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text('km/h', style: TextStyle(color: muted, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 65,
                      height: 65,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.red, width: 5),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('MAX', style: TextStyle(fontSize: 8, color: Colors.red, fontWeight: FontWeight.bold)),
                        Text(
                          '$_speedLimit',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87, height: 1.0),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            color: const Color(0xFF102238),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Giới hạn:', style: TextStyle(color: muted, fontSize: 12)),
                const SizedBox(width: 10),
                ...[40, 50, 60, 80].map((limit) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: ChoiceChip(
                    label: Text('$limit'),
                    selected: _speedLimit == limit,
                    selectedColor: green,
                    backgroundColor: panel,
                    labelStyle: TextStyle(
                      color: _speedLimit == limit ? navy : muted,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                    onSelected: (selected) {
                      if (selected) _changeSpeedLimit(limit);
                    },
                  ),
                )),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentLocation,
                    initialZoom: 16.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.quangvu.helloApp',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _currentLocation,
                          width: 45,
                          height: 45,
                          child: const Icon(
                            Icons.navigation,
                            color: green,
                            size: 38,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (isSpeeding)
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade700,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.white, size: 26),
                          SizedBox(width: 8),
                          Text(
                            'CẢNH BÁO: ĐANG CHẠY QUÁ TỐC ĐỘ!',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// KHUNG ĐIỀU HƯỚNG CHÍNH (5 TAB)
// ==========================================
class MainContainerScreen extends StatefulWidget {
  const MainContainerScreen({super.key});

  @override
  State<MainContainerScreen> createState() => _MainContainerScreenState();
}

class _MainContainerScreenState extends State<MainContainerScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const AlertsScreen(),
    const GuideScreen(),
    const DevicesScreen(),
    const SpeedometerMapScreen(), // Tab 5: Bản đồ & Tốc độ thời gian thực
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: panel,
        selectedItemColor: green,
        unselectedItemColor: muted,
        selectedFontSize: 11,
        unselectedFontSize: 10,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning_rounded),
            label: 'Cảnh báo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shield_rounded),
            label: 'Hướng xử lý',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sensors_rounded),
            label: 'Thiết bị',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_rounded),
            label: 'Bản đồ',
          ),
        ],
      ),
    );
  }
}

// Widget phụ trợ cho các danh sách thông tin
class CardItem extends StatelessWidget {
  final String title;
  final String desc;
  final IconData icon;
  final Color color;

  const CardItem({super.key, required this.title, required this.desc, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, size: 36, color: color),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(fontSize: 12, color: muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}