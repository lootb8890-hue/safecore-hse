import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/auth/auth_provider.dart';
import '../members/member_management.screen.dart';

class AppSidebarDrawer extends StatelessWidget {
  final Function(int)? onNavigate;
  const AppSidebarDrawer({Key? key, this.onNavigate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    if (user == null) {
      return const Drawer(child: Center(child: Text('يرجى تسجيل الدخول.')));
    }

    final isAdmin = authProvider.isAdmin;

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drawer Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E5E3A).withOpacity(0.08),
                border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 1)),
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
                          color: const Color(0xFF1E5E3A),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.business, color: Colors.white, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              authProvider.tenantName.isNotEmpty ? authProvider.tenantName : 'مؤسسة السلامة',
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.verified, color: Color(0xFF1E5E3A), size: 20),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: isAdmin ? Colors.amber.shade700 : const Color(0xFF1E5E3A),
                        child: Icon(
                          isAdmin ? Icons.admin_panel_settings : Icons.engineering,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.fullName,
                              style: const TextStyle(color: Color(0xFF1B2533), fontWeight: FontWeight.bold, fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${user.department} • ${user.branch}',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 11, fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Prominent Role Badge
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                    decoration: BoxDecoration(
                      color: isAdmin ? Colors.amber.shade700.withOpacity(0.12) : const Color(0xFF1E5E3A).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isAdmin ? Colors.amber.shade700 : const Color(0xFF1E5E3A),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      authProvider.roleBadgeText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isAdmin ? Colors.amber.shade900 : const Color(0xFF1E5E3A),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Navigation List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                children: [
                  _buildNavItem(context, Icons.dashboard_outlined, 'الرئيسية والمناطق الميدانية', () => _handleNav(context, 0)),
                  _buildNavItem(context, Icons.smart_toy_outlined, 'المساعد الذكي للسلامة (AI)', () => _handleNav(context, 1)),
                  _buildNavItem(context, Icons.analytics_outlined, 'سجل التقارير والإحصائيات', () => _handleNav(context, 2)),
                  _buildNavItem(context, Icons.settings_outlined, 'إعدادات المنشأة الافتراضية', () => _handleNav(context, 3)),

                  const SizedBox(height: 16),

                  // Admin exclusive members panel link
                  if (isAdmin) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border(right: BorderSide(color: Colors.amber.shade700, width: 4)),
                      ),
                      child: Text(
                        '⚡ حوكمة وصلاحيات الأدمن المسؤول',
                        style: TextStyle(color: Colors.amber.shade900, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildNavItem(
                      context,
                      Icons.people_outline_rounded,
                      'إدارة أعضاء الفريق (Team Roster)',
                      () {
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const MemberManagementScreen()));
                      },
                      highlight: true,
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.lock_outline, color: Colors.grey, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'إدارة شؤون أعضاء الفريق والتحكم مخصصة لحساب الأدمن فقط.',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 10, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Logout Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
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

  Widget _buildNavItem(BuildContext context, IconData icon, String label, VoidCallback onTap, {bool highlight = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: highlight ? Colors.amber.shade900 : const Color(0xFF1E5E3A)),
        title: Text(
          label,
          style: TextStyle(
            color: highlight ? Colors.amber.shade900 : const Color(0xFF2D3748),
            fontWeight: highlight ? FontWeight.bold : FontWeight.w600,
            fontSize: 13,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        tileColor: highlight ? Colors.amber.shade700.withOpacity(0.08) : Colors.transparent,
      ),
    );
  }
}
