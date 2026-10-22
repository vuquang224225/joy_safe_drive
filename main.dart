
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const JoySafeDriveApp());
}

const navy = Color(0xFF0B1424);
const panel = Color(0xFF14243A);
const green = Color(0xFF72E6A2);
const muted = Color(0xFFA8B7CC);
const orange = Color(0xFFFFBF69);

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
        colorScheme: ColorScheme.fromSeed(
          seedColor: green,
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
        backgroundColor: panel,
        indicatorColor: green.withValues(alpha: 0.18),
        selectedIndex: selectedTab,
        onDestinationSelected: (index) {
          setState(() => selectedTab = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: green),
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
                color: panel,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.shield_rounded,
                color: green,
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
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'AN TOÀN TRÊN MỌI HÀNH TRÌNH',
                    style: TextStyle(fontSize: 9, color: muted),
                  ),
                ],
              ),
            ),
            const Icon(Icons.notifications_none, color: muted, size: 27),
          ],
        ),
        const SizedBox(height: 26),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1B3550), panel],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TỐC ĐỘ HIỆN TẠI',
                    style: TextStyle(
                      color: muted,
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                  StatusPill(),
                ],
              ),
              const SizedBox(height: 12),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '--',
                    style: TextStyle(
                      fontSize: 65,
                      height: 1.15,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text('km/h', style: TextStyle(color: muted)),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: Colors.white12),
              const SizedBox(height: 8),
              const Icon(Icons.gps_fixed, color: green, size: 22),
              const SizedBox(height: 8),
              const Text(
                'Chưa bật theo dõi GPS',
                style: TextStyle(
                  color: green,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Tốc độ sẽ được bổ sung ở phiên bản tiếp theo.',
                textAlign: TextAlign.center,
                style: TextStyle(color: muted, fontSize: 12),
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
            color: panel,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 105,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF1B3046),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Center(
                  child: Icon(
                    Icons.map_outlined,
                    color: green,
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
                style: TextStyle(color: muted, fontSize: 13),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: openMap,
                  icon: const Icon(Icons.near_me),
                  label: const Text('MỞ GOOGLE MAPS'),
                  style: FilledButton.styleFrom(
                    backgroundColor: green,
                    foregroundColor: navy,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 25),
        const SectionTitle(
          title: 'Trung tâm an toàn',
          subtitle: 'Những công cụ cốt lõi của Joy Safe Drive',
        ),
        const SizedBox(height: 13),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.08,
          children: const [
            FeatureCard(
              icon: Icons.speed_rounded,
              title: 'Cảnh báo tốc độ',
              subtitle: 'Kiểm soát tốc độ an toàn',
              color: green,
            ),
            FeatureCard(
              icon: Icons.warning_amber_rounded,
              title: 'Nguy cơ đường',
              subtitle: 'Nhận biết nguy hiểm',
              color: orange,
            ),
            FeatureCard(
              icon: Icons.menu_book_rounded,
              title: 'Hướng xử lý',
              subtitle: 'Hướng dẫn tình huống',
              color: green,
            ),
            FeatureCard(
              icon: Icons.sensors_rounded,
              title: 'Thiết bị thông minh',
              subtitle: 'Sẵn sàng mở rộng',
              color: green,
            ),
          ],
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF18372F),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.favorite, color: green, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Nhận biết nguy cơ sớm hơn. '
                  'Quyết định an toàn hơn. '
                  'Cùng nhau giảm tai nạn.',
                  style: TextStyle(
                    color: Colors.white,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildAlerts() {
    return const InformationPage(
      icon: Icons.warning_amber_rounded,
      title: 'Trung tâm cảnh báo',
      subtitle: 'Nhận biết nguy cơ, chủ động bảo vệ hành trình.',
      items: [
        InfoItem(
          icon: Icons.speed,
          title: 'Cảnh báo tốc độ',
          description:
              'Tính năng GPS và đối chiếu giới hạn tốc độ sẽ được phát triển tiếp.',
          color: green,
        ),
        InfoItem(
          icon: Icons.water,
          title: 'Đường trơn, mưa lớn',
          description:
              'Giảm tốc độ từ từ, tăng khoảng cách với xe trước và tránh phanh gấp.',
          color: const Color(0xFF64B5F6),
        ),
        InfoItem(
          icon: Icons.car_crash_outlined,
          title: 'Sự cố phía trước',
          description:
              'Quan sát tình hình, giữ khoảng cách và chỉ chuyển hướng khi an toàn.',
          color: orange,
        ),
        InfoItem(
          icon: Icons.report_gmailerrorred,
          title: 'Điểm nguy hiểm',
          description:
              'Dữ liệu điểm nguy hiểm cộng đồng sẽ cần nguồn tin và quy trình xác minh.',
          color: orange,
        ),
      ],
    );
  }

  Widget buildGuide() {
    return const InformationPage(
      icon: Icons.health_and_safety_outlined,
      title: 'Hướng xử lý an toàn',
      subtitle: 'Một số nguyên tắc cơ bản khi gặp tình huống nguy hiểm.',
      items: [
        InfoItem(
          icon: Icons.cloud,
          title: 'Khi trời mưa, đường trơn',
          description:
              'Giảm tốc độ nhẹ nhàng, giữ khoảng cách lớn hơn và tránh thao tác đột ngột.',
          color: const Color(0xFF64B5F6),
        ),
        InfoItem(
          icon: Icons.warning_amber,
          title: 'Khi gặp chướng ngại vật',
          description:
              'Giữ bình tĩnh, quan sát xung quanh và chỉ đánh lái nếu có khoảng trống an toàn.',
          color: orange,
        ),
        InfoItem(
          icon: Icons.car_crash,
          title: 'Khi xảy ra va chạm',
          description:
              'Ưu tiên an toàn con người, gọi dịch vụ khẩn cấp phù hợp và không đứng ở làn xe chạy.',
          color: Colors.redAccent,
        ),
        InfoItem(
          icon: Icons.local_hospital_outlined,
          title: 'Khi có người bị thương',
          description:
              'Gọi cấp cứu. Không tự ý di chuyển người bị nghi chấn thương nghiêm trọng trừ khi có nguy cơ tức thời.',
          color: green,
        ),
      ],
    );
  }

  Widget buildDevices() {
    return const InformationPage(
      icon: Icons.sensors_outlined,
      title: 'Thiết bị tương thích',
      subtitle: 'Nền tảng để Joy Safe Drive mở rộng trong tương lai.',
      items: [
        InfoItem(
          icon: Icons.gps_fixed,
          title: 'GPS điện thoại',
          description:
              'Dự kiến dùng vị trí và vận tốc GPS khi người dùng cấp quyền.',
          color: green,
        ),
        InfoItem(
          icon: Icons.sensors,
          title: 'Cảm biến ngoài',
          description:
              'Chưa kết nối phần cứng. Sẽ thiết kế giao thức sau khi xác định loại thiết bị.',
          color: orange,
        ),
        InfoItem(
          icon: Icons.bluetooth,
          title: 'Kết nối thiết bị',
          description:
              'Có thể nghiên cứu Bluetooth hoặc kết nối khác tùy phần cứng thực tế.',
          color: const Color(0xFF64B5F6),
        ),
      ],
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: orange.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'BẢN THỬ NGHIỆM',
        style: TextStyle(
          color: orange,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const SectionTitle({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: const TextStyle(color: muted, fontSize: 12),
        ),
      ],
    );
  }
}

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(19),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 13),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: const TextStyle(color: muted, fontSize: 10, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class InfoItem {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const InfoItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}

class InformationPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<InfoItem> items;

  const InformationPage({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      children: [
        Icon(icon, color: green, size: 42),
        const SizedBox(height: 16),
        Text(
          title,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(color: muted, height: 1.5),
        ),
        const SizedBox(height: 24),
        ...items.map(
          (item) => Container(
            margin: const EdgeInsets.only(bottom: 13),
            padding: const EdgeInsets.all(17),
            decoration: BoxDecoration(
              color: panel,
              borderRadius: BorderRadius.circular(19),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(item.icon, color: item.color, size: 25),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        item.description,
                        style: const TextStyle(
                          color: muted,
                          fontSize: 12,
                          height: 1.55,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Thông tin hướng dẫn mang tính tham khảo. '
          'Luôn tuân thủ luật giao thông và hướng dẫn của lực lượng chức năng.',
          style: TextStyle(color: muted, fontSize: 11, height: 1.5),
        ),
      ],
    );
  }
}