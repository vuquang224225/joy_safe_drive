import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const JoySafeDriveApp());
}

// Bảng màu Xanh Da Trời (Sky Blue Theme)
const skyDarkBg = Color(0xFF0B192C);      // Nền tối xanh thẫm
const skyPanel = Color(0xFF1E3E62);       // Panel xanh da trời đậm
const skyPrimary = Color(0xFF00D2FF);     // Xanh da trời sáng (Neon Sky Blue)
const skyAccent = Color(0xFF80E5FF);      // Xanh da trời nhạt
const skyTextMuted = Color(0xFF90A4AE);  // Chữ xám xanh phụ
const skyWarning = Color(0xFFFF9800);    // Cam cảnh báo

class JoySafeDriveApp extends StatelessWidget {
  const JoySafeDriveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Joy Safe Drive',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: skyDarkBg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: skyPrimary,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedTab = 0;
  double currentSpeed = 0.0;
  double latitude = 0.0;
  double longitude = 0.0;
  double accuracy = 0.0;
  bool isTracking = false;
  StreamSubscription<Position>? positionStream;

  @override
  void dispose() {
    positionStream?.cancel();
    super.dispose();
  }

  Future<void> toggleGpsTracking() async {
    bool serviceEnabled;
    LocationPermission permission;

    if (isTracking) {
      positionStream?.cancel();
      setState(() {
        isTracking = false;
        currentSpeed = 0.0;
      });
      return;
    }

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('GPS chưa được bật trên điện thoại.')),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quyền truy cập vị trí bị từ chối.')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quyền vị trí bị từ chối vĩnh viễn trong Cài đặt.')),
      );
      return;
    }

    setState(() {
      isTracking = true;
    });

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 1, // Cập nhật ngay khi di chuyển từ 1 mét
    );

    positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position position) {
        setState(() {
          latitude = position.latitude;
          longitude = position.longitude;
          accuracy = position.accuracy;
          
          // Tính tốc độ thực tế theo m/s chuyển đổi sang km/h (* 3.6)
          double speedKmh = position.speed * 3.6;
          currentSpeed = speedKmh.isNegative ? 0.0 : speedKmh;
        });
      },
      onError: (e) {
        setState(() {
          isTracking = false;
        });
      },
    );
  }

  Future<void> openMap() async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=Ho+Chi+Minh+City',
    );

    if (!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chưa mở được bản đồ.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: selectedTab,
          children: [
            buildHome(),
            buildAlerts(),
            buildGuide(),
            buildDevices(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: skyPanel,
        indicatorColor: skyPrimary.withValues(alpha: 0.25),
        selectedIndex: selectedTab,
        onDestinationSelected: (index) {
          setState(() => selectedTab = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: skyPrimary),
            label: 'Trang chủ',
          ),
          NavigationDestination(
            icon: Icon(Icons.warning_amber_rounded),
            label: 'Cảnh báo',
          ),
          NavigationDestination(
            icon: Icon(Icons.health_and_safety_outlined),
            label: 'Hướng xử lý',
          ),
          NavigationDestination(
            icon: Icon(Icons.sensors_outlined),
            label: 'Thiết bị',
          ),
        ],
      ),
    );
  }

  Widget buildHome() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: skyPanel,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: skyPrimary.withValues(alpha: 0.3)),
              ),
              child: const Icon(
                Icons.shield_rounded,
                color: skyPrimary,
                size: 30,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'JOY SAFE DRIVE',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                      color: skyPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'AN TOÀN TRÊN MỌI HÀNH TRÌNH',
                    style: TextStyle(fontSize: 9, color: skyTextMuted),
                  ),
                ],
              ),
            ),
            const Icon(Icons.notifications_none, color: skyTextMuted, size: 27),
          ],
        ),
        const SizedBox(height: 26),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [skyPanel, skyDarkBg],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: skyPrimary.withValues(alpha: 0.4)),
            boxShadow: [
              BoxShadow(
                color: skyPrimary.withValues(alpha: 0.1),
                blurRadius: 15,
                spreadRadius: 2,
              )
            ],
          ),
          child: Column(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TỐC ĐỘ THỰC TẾ (GPS)',
                    style: TextStyle(
                      color: skyAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  StatusPill(),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    isTracking ? currentSpeed.toStringAsFixed(0) : '--',
                    style: const TextStyle(
                      fontSize: 70,
                      height: 1.15,
                      fontWeight: FontWeight.bold,
                      color: skyPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('km/h', style: TextStyle(color: skyAccent, fontSize: 16)),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: Colors.white12),
              const SizedBox(height: 8),
              if (isTracking) ...[
                Text(
                  'Lat: ${latitude.toStringAsFixed(5)} | Lng: ${longitude.toStringAsFixed(5)}',
                  style: const TextStyle(color: skyAccent, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Độ chính xác cảm biến: ~${accuracy.toStringAsFixed(1)}m',
                  style: const TextStyle(color: skyTextMuted, fontSize: 11),
                ),
                const SizedBox(height: 8),
              ],
              Icon(
                isTracking ? Icons.gps_fixed : Icons.gps_off,
                color: isTracking ? skyPrimary : skyTextMuted,
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                isTracking ? 'Đang bật đo vị trí thực tế' : 'Chưa bật GPS thực tế',
                style: TextStyle(
                  color: isTracking ? skyPrimary : skyTextMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: toggleGpsTracking,
                  icon: Icon(isTracking ? Icons.stop : Icons.play_arrow),
                  label: Text(isTracking ? 'DỪNG ĐO GPS' : 'BẬT ĐO GPS THỰC TẾ'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isTracking ? skyWarning : skyPrimary,
                    side: BorderSide(color: isTracking ? skyWarning : skyPrimary, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 25),
        const SectionTitle(
          title: 'Hành trình của bạn',
          subtitle: 'Chuẩn bị cho chuyến đi an toàn hơn',
        ),
        const SizedBox(height: 13),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: skyPanel,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 105,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: skyDarkBg,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Center(
                  child: Icon(
                    Icons.map_outlined,
                    color: skyPrimary,
                    size: 48,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Bản đồ & chỉ đường',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Mở bản đồ để tìm đường và chuẩn bị điểm đến.',
                style: TextStyle(color: skyTextMuted, fontSize: 13),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: openMap,
                  icon: const Icon(Icons.near_me),
                  label: const Text('MỞ GOOGLE MAPS'),
                  style: FilledButton.styleFrom(
                    backgroundColor: skyPrimary,
                    foregroundColor: skyDarkBg,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildAlerts() => const InformationPage(icon: Icons.warning_amber_rounded, title: 'Trung tâm cảnh báo', subtitle: 'Nhận biết nguy cơ, chủ động bảo vệ hành trình.', items: []);
  Widget buildGuide() => const InformationPage(icon: Icons.health_and_safety_outlined, title: 'Hướng xử lý an toàn', subtitle: 'Nguyên tắc cơ bản.', items: []);
  Widget buildDevices() => const InformationPage(icon: Icons.sensors_outlined, title: 'Thiết bị tương thích', subtitle: 'Mở rộng trong tương lai.', items: []);
}

class StatusPill extends StatelessWidget {
  const StatusPill({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: skyPrimary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: skyPrimary.withValues(alpha: 0.3)),
      ),
      child: const Text('THỰC TẾ', style: TextStyle(color: skyPrimary, fontSize: 9, fontWeight: FontWeight.bold)),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  const SectionTitle({super.key, required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Text(subtitle, style: const TextStyle(color: skyTextMuted, fontSize: 12)),
      ],
    );
  }
}

class InformationPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<dynamic> items;
  const InformationPage({super.key, required this.icon, required this.title, required this.subtitle, required this.items});
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Icon(icon, color: skyPrimary, size: 42),
        const SizedBox(height: 16),
        Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(subtitle, style: const TextStyle(color: skyTextMuted, height: 1.5)),
      ],
    );
  }
}