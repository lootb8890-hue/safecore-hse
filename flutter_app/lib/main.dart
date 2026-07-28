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
import 'features/assets/qr_scanner.screen.dart';
import 'features/tasks_and_ai/tasks_ai_studio.screen.dart';
import 'features/emergency/emergency_red_button.screen.dart';

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
      title: 'SafeCore Enterprise HSE Platform',
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
    if (index >= 0 && index < 5) {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final brandingProvider = Provider.of<BrandingProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final branding = brandingProvider.branding;
    final user = authProvider.currentUser;

    final screens = [
      AdminDashboardScreen(onNavigate: _onNavigate),
      const LayoutCanvasScreen(),
      const QrScannerScreen(),
      const TasksAndAiStudioScreen(),
      const EmergencyRedButtonScreen(),
    ];

    return Scaffold(
      drawer: AppSidebarDrawer(onNavigate: _onNavigate),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.amber, size: 28),
            tooltip: 'القائمة الجانبية والصلاحيات',
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Row(
          children: [
            const Icon(Icons.shield, color: Colors.amber),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                branding.tenantName,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          // Live Role Indicator Badge
          if (user != null)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: authProvider.isAdmin ? Colors.amber.withOpacity(0.2) : Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: authProvider.isAdmin ? Colors.amberAccent : Colors.greenAccent,
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    authProvider.isAdmin ? Icons.admin_panel_settings : Icons.engineering,
                    size: 14,
                    color: authProvider.isAdmin ? Colors.amberAccent : Colors.greenAccent,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    authProvider.isAdmin ? 'ADMIN' : 'MEMBER',
                    style: TextStyle(
                      color: authProvider.isAdmin ? Colors.amberAccent : Colors.greenAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),

          // White-Label Live Tenant Workspace Switcher Demo Button
          DropdownButton<String>(
            value: branding.tenantId == 'petroapex' || branding.tenantId == 'alnoor' ? branding.tenantId : null,
            hint: const Text('🏢 Workspace', style: TextStyle(fontSize: 11, color: Colors.white70)),
            dropdownColor: Theme.of(context).cardColor,
            underline: const SizedBox(),
            icon: const Icon(Icons.business, color: Colors.amberAccent, size: 22),
            onChanged: (val) {
              if (val == 'petroapex') {
                brandingProvider.applyTenantBranding(TenantBranding.defaultPetroApex());
              } else if (val == 'alnoor') {
                brandingProvider.applyTenantBranding(
                  const TenantBranding(
                    tenantId: 'alnoor',
                    tenantName: 'مدينة النور الطبية للصحة والسلامة',
                    logoUrl: 'https://safecore-assets.s3.amazonaws.com/logos/alnoor.png',
                    primaryColor: Color(0xFF2B6CB0),
                    secondaryColor: Color(0xFFE53E3E),
                    accentColor: Color(0xFF4FD1C5),
                    fontFamily: 'IBM Plex Sans Arabic',
                    isRtl: true,
                  ),
                );
              }
            },
            items: const [
              DropdownMenuItem(value: 'petroapex', child: Text('🏢 PetroApex Refinery (LTR/Navy)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
              DropdownMenuItem(value: 'alnoor', child: Text('🏥 مدينة النور الطبية (RTL / Arabic)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
            ],
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => _onNavigate(index),
        indicatorColor: branding.secondaryColor.withOpacity(0.3),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard, color: Colors.amberAccent), label: 'الرئيسية'),
          NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map, color: Colors.amberAccent), label: 'الخرائط'),
          NavigationDestination(icon: Icon(Icons.qr_code_scanner_outlined), selectedIcon: Icon(Icons.qr_code_scanner, color: Colors.amberAccent), label: 'الماسح'),
          NavigationDestination(icon: Icon(Icons.task_alt_outlined), selectedIcon: Icon(Icons.task_alt, color: Colors.amberAccent), label: 'المهام الذكية'),
          NavigationDestination(icon: Icon(Icons.emergency_outlined, color: Colors.redAccent), selectedIcon: Icon(Icons.emergency, color: Colors.red), label: 'الطوارئ'),
        ],
      ),
    );
  }
}
