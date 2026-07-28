import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/theme/branding_engine.dart';
import '../members/member_management.screen.dart';

class AppSidebarDrawer extends StatelessWidget {
  final Function(int)? onNavigate;
  const AppSidebarDrawer({Key? key, this.onNavigate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final brandingProvider = Provider.of<BrandingProvider>(context);
    final user = authProvider.currentUser;
    final branding = brandingProvider.branding;

    if (user == null) {
      return const Drawer(child: Center(child: Text('Please sign in.')));
    }

    final isAdmin = authProvider.isAdmin;

    return Drawer(
      backgroundColor: const Color(0xFF0F172A),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Section: Tenant & User Profile with Role Badge
            Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    branding.secondaryColor,
                    branding.primaryColor,
                  ],
                ),
                border: const Border(bottom: BorderSide(color: Colors.white24, width: 1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.amber, width: 1.2),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.business, color: Colors.amber, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              branding.tenantName,
                              style: const TextStyle(color: Colors.amberAccent, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.verified, color: Colors.white70, size: 20),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: isAdmin ? Colors.amber.shade600 : Colors.green.shade700,
                        child: Icon(
                          isAdmin ? Icons.admin_panel_settings : Icons.engineering,
                          color: Colors.black87,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.fullName,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${user.department} • ${user.branch}',
                              style: TextStyle(color: Colors.grey.shade300, fontSize: 11, fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Prominent Role Badge
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                    decoration: BoxDecoration(
                      color: isAdmin ? Colors.amber.withOpacity(0.2) : Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isAdmin ? Colors.amberAccent : Colors.greenAccent,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      authProvider.roleBadgeText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isAdmin ? Colors.amberAccent : Colors.greenAccent,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Navigation Menu
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                children: [
                  _buildNavItem(context, Icons.dashboard, 'الرئیسية ومناطق السلامة (Dashboard)', () => _handleNav(context, 0)),
                  _buildNavItem(context, Icons.smart_toy, 'المساعد الذكي الفوري (AI HSE Inspector)', () => _handleNav(context, 1)),
                  _buildNavItem(context, Icons.notification_important, 'إدارة الطوارئ والإنذارات (Emergencies)', () => _handleNav(context, 2)),
                  _buildNavItem(context, Icons.assignment_turned_in, 'سجل التدقيق والمراجعات (Inspections)', () => _handleNav(context, 3)),

                  const SizedBox(height: 16),

                  // Admin Exclusive section
                  if (isAdmin) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: const Border(right: BorderSide(color: Colors.amber, width: 4)),
                      ),
                      child: const Text(
                        '⚡ حوكمة وصلاحيات المسؤول العام (ADMIN PORTAL)',
                        style: TextStyle(color: Colors.amber, fontWeight: FontWeight.w900, fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildNavItem(
                      context,
                      Icons.people_alt_rounded,
                      'إدارة شؤون الأعضاء والمراقبين (Team Members)',
                      () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const MemberManagementScreen()));
                      },
                      highlight: true,
                      badgeText: 'مفعل',
                    ),
                    _buildNavItem(context, Icons.color_lens, 'تخصيص هوية المنشأة (White-Label UI)', () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يمكنك تعديل ألوان وشعار الهوية مباشرة من إعدادات المؤسسة السحابية.')));
                    }),
                    _buildNavItem(context, Icons.policy, 'سجل التدقيق التشريعي (Compliance Audit)', () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('جميع الحركات مسجلة ومشفرة بخوارزميات الأمان والتوثيق المرجعي.')));
                    }),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.lock_outline, color: Colors.amberAccent, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'إدارة شؤون المؤسسة وإضافة الأعضاء مخصصة لحساب المسؤول العام (Admin) فقط.',
                              style: TextStyle(color: Colors.grey.shade400, fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
                  // One-click Evaluation Role switcher inside drawer
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blueGrey.shade400),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          '🔄 التبديل الفوري التجريبي لاختبار الصلاحيات:',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            authProvider.quickLoginDemo(!isAdmin);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isAdmin ? const Color(0xFF166534) : const Color(0xFF1E3A8A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          icon: Icon(isAdmin ? Icons.engineering : Icons.admin_panel_settings, size: 18),
                          label: Text(isAdmin ? 'التبديل إلى صلاحية (عضو مراقب)' : 'التبديل إلى صلاحية (مسؤول عام)', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Logout Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.white12, width: 1)),
              ),
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  authProvider.logout();
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.logout, color: Colors.redAccent),
                label: const Text('تسجيل الخروج من المنشأة', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleNav(BuildContext context, int index) {
    Navigator.pop(context);
    if (onNavigate != null) {
      onNavigate!(index);
    }
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, VoidCallback onTap, {bool highlight = false, String? badgeText}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: highlight ? Colors.amberAccent : Colors.white70),
        title: Text(
          label,
          style: TextStyle(
            color: highlight ? Colors.amberAccent : Colors.white,
            fontWeight: highlight ? FontWeight.w900 : FontWeight.w600,
            fontSize: 14,
          ),
        ),
        trailing: badgeText != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(badgeText, style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w900)),
              )
            : const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        tileColor: highlight ? Colors.amber.withOpacity(0.1) : Colors.transparent,
      ),
    );
  }
}
