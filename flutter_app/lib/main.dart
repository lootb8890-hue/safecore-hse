import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/branding_engine.dart';
import 'core/offline_db/offline_storage_service.dart';
import 'core/network/sync_engine.dart';
import 'core/network/socket_service.dart';

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
      home: const MainNavigationShell(),
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
    final branding = brandingProvider.branding;

    final screens = [
      AdminDashboardScreen(onNavigate: _onNavigate),
      const LayoutCanvasScreen(),
      const QrScannerScreen(),
      const TasksAndAiStudioScreen(),
      const EmergencyRedButtonScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.shield, color: Colors.amber),
            const SizedBox(width: 8),
            Text(branding.tenantName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          ],
        ),
        actions: [
          // White-Label Live Tenant Workspace Switcher Demo Button
          DropdownButton<String>(
            value: branding.tenantId,
            dropdownColor: Theme.of(context).cardColor,
            underline: const SizedBox(),
            icon: const Icon(Icons.business, color: Colors.blueGrey),
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
          const SizedBox(width: 16),
        ],
      ),
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        indicatorColor: branding.secondaryColor.withOpacity(0.2),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map), label: 'Layout Plan'),
          NavigationDestination(icon: Icon(Icons.qr_code_scanner_outlined), selectedIcon: Icon(Icons.qr_code_scanner), label: 'Scan Asset'),
          NavigationDestination(icon: Icon(Icons.task_alt_outlined), selectedIcon: Icon(Icons.task_alt), label: 'Tasks & AI'),
          NavigationDestination(icon: Icon(Icons.emergency_outlined, color: Colors.red), selectedIcon: Icon(Icons.emergency, color: Colors.red), label: 'Emergency'),
        ],
      ),
    );
  }
}
