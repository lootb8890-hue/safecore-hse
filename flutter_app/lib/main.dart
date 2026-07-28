import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/branding_engine.dart';
import 'core/auth/auth_provider.dart';
import 'core/offline_db/offline_storage_service.dart';
import 'core/network/sync_engine.dart';
import 'core/network/socket_service.dart';

import 'features/auth/login.screen.dart';
import 'features/navigation/app_sidebar_drawer.dart';
import 'features/dashboard/admin_dashboard.screen.dart';
import 'features/layout/layout_canvas.screen.dart';
import 'features/tasks_and_ai/tasks_ai_studio.screen.dart';
import 'features/members/member_management.screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize offline synchronization engines
  SyncEngine().initializeMonitoring();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BrandingProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => OfflineStorageService()),
        ChangeNotifierProvider(create: (_) => SyncEngine()),
        ChangeNotifierProvider(create: (_) => SocketService()),
      ],
      child: const SafeCoreEnterpriseApp(),
    ),
  );
}

class SafeCoreEnterpriseApp extends StatelessWidget {
  const SafeCoreEnterpriseApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final brandingProvider = Provider.of<BrandingProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    // Register branding provider inside auth for atomic theme swapping during onboarding
    authProvider.registerBrandingProvider(brandingProvider);

    return MaterialApp(
      title: 'السلامة المهنية - SafeCore HSE',
      debugShowCheckedModeBanner: false,
      theme: brandingProvider.generateThemeData(),
      builder: (context, child) {
        return Directionality(
          textDirection: brandingProvider.textDirection,
          child: child!,
        );
      },
      home: authProvider.isAuthenticated ? const MainNavigationShell() : const LoginScreen(),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({Key? key}) : super(key: key);

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  void _onNavigate(int index) {
    if (index >= 0 && index < 4) {
      setState(() => _currentIndex = index);
    }
  }

  void _showNotificationsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('إشعارات وتنبيهات السلامة الميدانية', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E5E3A))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: const Text('3 تنبيهات عاجلة', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildNotificationItem('⚠️ إنذار ميداني', 'تم رصد مخالفة عدم ارتداء خوذة في مبنى الإنتاج (أحمد علي).', 'الآن'),
            _buildNotificationItem('🔥 تقرير مطفأة', 'مطفأة رغوية رقم #FE-003 بحاجة لإعادة فحص وتعبئة فورية.', 'منذ ساعتين'),
            _buildNotificationItem('📝 اسكار جديد', 'تسجيل خطر في الدرج المكسور عند مبنى الإنتاج الدور الأول.', 'أمس'),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E5E3A), foregroundColor: Colors.white),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('إغلاق وتأكيد القراءة'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem(String title, String desc, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8, height: 8,
            margin: const EdgeInsets.only(top: 6),
            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF2D3748))),
                    Text(time, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(desc, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    final screens = [
      AdminDashboardScreen(onNavigate: _onNavigate),
      const TasksAndAiStudioScreen(),
      const LayoutCanvasScreen(),
      const MemberManagementScreen(),
    ];

    return Scaffold(
      drawer: AppSidebarDrawer(onNavigate: _onNavigate),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Color(0xFF2D3748), size: 28),
            tooltip: 'القائمة الجانبية وإدارة الحسابات',
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF1E5E3A).withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.health_and_safety, color: Color(0xFF1E5E3A), size: 22),
              const SizedBox(width: 8),
              const Text(
                'السلامة المهنية',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF1E5E3A)),
              ),
              if (user != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: authProvider.isAdmin ? Colors.amber.shade700 : const Color(0xFF1E5E3A),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    authProvider.isAdmin ? 'ADMIN' : 'MEMBER',
                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          // Notification Bell with Red Badge ("3") exactly as in screenshot
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined, color: Color(0xFF2D3748), size: 28),
                  onPressed: _showNotificationsModal,
                ),
                Positioned(
                  top: 8,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: const Text(
                      '3',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, -3)),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) => _onNavigate(index),
          backgroundColor: Colors.white,
          elevation: 0,
          indicatorColor: const Color(0xFF1E5E3A).withOpacity(0.12),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: Color(0xFF64748B)),
              selectedIcon: Icon(Icons.home_rounded, color: Color(0xFF1E5E3A)),
              label: 'الرئيسية',
            ),
            NavigationDestination(
              icon: Icon(Icons.task_outlined, color: Color(0xFF64748B)),
              selectedIcon: Icon(Icons.task_rounded, color: Color(0xFF1E5E3A)),
              label: 'المهام',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined, color: Color(0xFF64748B)),
              selectedIcon: Icon(Icons.bar_chart_rounded, color: Color(0xFF1E5E3A)),
              label: 'التقارير',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined, color: Color(0xFF64748B)),
              selectedIcon: Icon(Icons.settings, color: Color(0xFF1E5E3A)),
              label: 'الإعدادات',
            ),
          ],
        ),
      ),
    );
  }
}
