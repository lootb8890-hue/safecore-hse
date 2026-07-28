import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/branding_engine.dart';
import '../../core/theme/glassmorphism.dart';
import '../../core/offline_db/offline_storage_service.dart';

class AdminDashboardScreen extends StatelessWidget {
  final Function(int) onNavigate;

  const AdminDashboardScreen({Key? key, required this.onNavigate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final branding = Provider.of<BrandingProvider>(context).branding;
    final offlineDb = Provider.of<OfflineStorageService>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Executive Header Banner
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SafeCore Corporate Command',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: branding.accentColor,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    branding.tenantName,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : branding.primaryColor,
                    ),
                  ),
                ],
              ),
              CircleAvatar(
                radius: 26,
                backgroundColor: branding.secondaryColor.withOpacity(0.15),
                child: Icon(Icons.security, color: branding.secondaryColor, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Offline Status Alert Banner if disconnected
          if (offlineDb.isOfflineModeActive)
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.amber.shade800,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.offline_bolt, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Offline Operations Mode Active. (${offlineDb.pendingSyncCount} checkups queued for cloud sync)',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

          // Core Safety Score & KPI Glassmorphic Cards
          Row(
            children: [
              Expanded(
                flex: 2,
                child: GlassContainer(
                  padding: const EdgeInsets.all(22),
                  borderColor: branding.primaryColor.withOpacity(0.3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('CORPORATE SAFETY INDEX', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: branding.primaryColor)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: branding.accentColor.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                            child: Text('GRADE A+', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: branding.accentColor)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text('96.8%', style: TextStyle(fontSize: 44, fontWeight: FontWeight.w900, color: branding.primaryColor)),
                          const SizedBox(width: 8),
                          const Text('+1.4% vs last audit', style: TextStyle(fontSize: 13, color: Colors.green, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: 0.968,
                        backgroundColor: Colors.grey.withOpacity(0.2),
                        color: branding.accentColor,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 4 Grid KPI Boxes
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 700 ? 4 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildKpiBox(context, 'Active Safety Twins', '1,420', Icons.qr_code_2, branding.primaryColor),
              _buildKpiBox(context, 'Pending Inspections', '18 Due Today', Icons.assignment_turned_in, branding.secondaryColor),
              _buildKpiBox(context, 'Emergency Alerts', '0 Active Alarms', Icons.warning_amber_rounded, Colors.green),
              _buildKpiBox(context, 'AI Hazard Reports', '2 Resolved', Icons.smart_toy, Colors.purple),
            ],
          ),
          const SizedBox(height: 30),

          // Action Shortcuts & Feature Grid
          Text(
            'ENTERPRISE MODULE SHORTCUTS',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: branding.primaryColor.withOpacity(0.8), letterSpacing: 1.0),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 700 ? 3 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.1,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildActionCard(context, 'Interactive Floor Plans', 'Zoomable 2D blueprint layout pins', Icons.map_outlined, () => onNavigate(1)),
              _buildActionCard(context, 'QR / Barcode Scanner', 'Instant scan asset compliance tags', Icons.qr_code_scanner, () => onNavigate(2)),
              _buildActionCard(context, "Today's Work & Calendar", 'Consolidated daily checkup roster', Icons.today_outlined, () => onNavigate(3)),
              _buildActionCard(context, 'Zero-Latency Sirens', 'Instant red emergency alarm center', Icons.emergency, () => onNavigate(4)),
              _buildActionCard(context, 'AI Hazard Analyzer', 'Computer vision PPE & risk diagnostic', Icons.psychology_outlined, () => onNavigate(5)),
              _buildActionCard(context, 'Document & SOP Center', 'ISO & OSHA safety repository', Icons.description_outlined, () => onNavigate(6)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKpiBox(BuildContext context, String title, String value, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 26),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ],
          ),
          const Spacer(),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: isDark ? Colors.white : Colors.black87)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title, String subtitle, IconData icon, VoidCallback onTap) {
    final branding = Provider.of<BrandingProvider>(context, listen: false).branding;
    return GlassContainer(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      borderColor: branding.primaryColor.withOpacity(0.15),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: branding.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: branding.primaryColor, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade600), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
