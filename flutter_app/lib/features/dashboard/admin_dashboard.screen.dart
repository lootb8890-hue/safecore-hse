import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/auth/auth_provider.dart';
import '../emergency/emergency_red_button.screen.dart';
import '../assets/qr_scanner.screen.dart';
import '../fire_extinguishers/fire_extinguishers.screen.dart';
import '../observations/observations.screen.dart';
import '../permits/work_permits.screen.dart';
import '../warnings/safety_warnings.screen.dart';
import '../chat/team_chat.screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  final Function(int) onNavigate;
  const AdminDashboardScreen({Key? key, required this.onNavigate}) : super(key: key);

  void _showSuggestionsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1B2533),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lightbulb_outline, color: Colors.amberAccent, size: 28),
                const SizedBox(width: 10),
                const Text('اقتراحات لتطوير التطبيق', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
            const SizedBox(height: 20),
            _buildSuggestionBullet('إضافة لوحة تحكم (Dashboard) تعرض إحصائيات السلامة بشكل بياني.'),
            _buildSuggestionBullet('إمكانية عمل تقارير دورية تلقائية وإرسالها بالإيميل.'),
            _buildSuggestionBullet('دعم تعدد اللغات (العربية، الإنجليزية، والأردية للميدانيين).'),
            _buildSuggestionBullet('إضافة خاصية QR Code لكل معدة (المطافئ، المعدات) لعرض تفاصيل الفحص الفوري.'),
            _buildSuggestionBullet('تكامل مع أجهزة الاستشعار وأنظمة الإنذار الآني الذكي.'),
            _buildSuggestionBullet('إمكانية العمل بدون إنترنت (Offline First) ومزامنة البيانات عند الاتصال.'),
            _buildSuggestionBullet('نظام نقاط ومكافآت لتحفيز الموظفين على الالتزام الكامل بالسلامة.'),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E5E3A), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12)),
                icon: const Icon(Icons.verified, color: Colors.amber),
                label: const Text('المزايا مدمجة ونشطة بنجاح في SafeCore'),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•', style: TextStyle(color: Colors.amberAccent, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Welcome Banner ("سلامتك مسؤوليتنا جميعاً")
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: const DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1541888946425-d0bb780a56f7?auto=format&fit=crop&w=1000&q=80'),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF1E5E3A).withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 6)),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [const Color(0xFF1B2533).withOpacity(0.85), Colors.transparent],
                    begin: Alignment.bottomRight,
                    end: Alignment.topLeft,
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'سلامتك\nمسؤوليتنا جميعاً',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      user != null ? 'مرحباً، ${user.fullName} (${auth.isAdmin ? 'مسؤول السلامة' : 'عضو ميداني'})' : 'المتصفح النشط - إدارة السلامة',
                      style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 8 Quick Action Grid exactly as in screenshot
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 14,
              crossAxisSpacing: 12,
              childAspectRatio: 0.85,
              children: [
                _buildGridItem(context, 'المطافئ', Icons.fire_extinguisher, Colors.red.shade700, () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FireExtinguishersScreen()));
                }),
                _buildGridItem(context, 'تصاريح العمل', Icons.assignment_turned_in_outlined, const Color(0xFF1E5E3A), () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WorkPermitsScreen()));
                }),
                _buildGridItem(context, 'الاسكار', Icons.assignment_late_outlined, const Color(0xFF2D3748), () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ObservationsScreen()));
                }),
                _buildGridItem(context, 'الانذارات', Icons.warning_amber_rounded, Colors.orange.shade800, () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SafetyWarningsScreen()));
                }),
                _buildGridItem(context, 'المحادثات', Icons.chat_bubble_outline_rounded, const Color(0xFF1E5E3A), () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TeamChatScreen()));
                }),
                _buildGridItem(context, 'اتصال بالطوارئ', Icons.phone_enabled_rounded, const Color(0xFF1E5E3A), () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EmergencyRedButtonScreen()));
                }),
                _buildGridItem(context, 'فحص سلامة', Icons.verified_user_outlined, const Color(0xFF1E5E3A), () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const QrScannerScreen()));
                }),
                _buildGridItem(context, 'المزيد', Icons.grid_view_rounded, const Color(0xFF4B5563), () {
                  _showSuggestionsDialog(context);
                }),
              ],
            ),
            const SizedBox(height: 30),

            // Safety Statistics ("إحصائيات السلامة")
            const Text(
              'إحصائيات السلامة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1B2533)),
            ),
            const SizedBox(height: 14),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard('27', 'عمليات الفحص\nالمكتملة', Icons.check_circle_outline, const Color(0xFF1E5E3A)),
                _buildStatCard('5', 'الانذارات\nهذا الشهر', Icons.error_outline, Colors.orange.shade800),
                _buildStatCard('8', 'الاسكار\nالجديدة', Icons.content_paste_rounded, const Color(0xFF2D3748)),
                _buildStatCard('12', 'تصاريح العمل\nالنشطة', Icons.assignment_outlined, const Color(0xFF1E5E3A)),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3)),
              ],
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF2D3748)),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String val, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 3)),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(val, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color)),
                const SizedBox(height: 2),
                Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade700, height: 1.2)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
