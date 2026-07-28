import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/theme/glassmorphism.dart';
import '../../core/theme/branding_engine.dart';

class EnterpriseSetupScreen extends StatefulWidget {
  const EnterpriseSetupScreen({Key? key}) : super(key: key);

  @override
  State<EnterpriseSetupScreen> createState() => _EnterpriseSetupScreenState();
}

class _EnterpriseSetupScreenState extends State<EnterpriseSetupScreen> {
  final _tenantNameController = TextEditingController(text: 'شركة نورس لصناعات الطاقة والسلامة');
  final _subdomainController = TextEditingController(text: 'nawras-hse');
  final _adminEmailController = TextEditingController(text: 'ceo@nawras-hse.com');
  final _adminFullNameController = TextEditingController(text: 'م. فهد القرني (المدير التنفيذي للأمان)');
  final _adminPasswordController = TextEditingController(text: 'Admin@2026!');
  final _departmentController = TextEditingController(text: 'الإدارة العامة لحوكمة الأمان والجودة');
  final _branchController = TextEditingController(text: 'المقر الرئيسي - مجمع الرياض التحتي');

  Color _selectedPrimaryColor = const Color(0xFF1B4332);
  Color _selectedSecondaryColor = const Color(0xFF081C15);
  bool _isRtl = true;
  bool _obscurePassword = true;

  final List<Map<String, dynamic>> _paletteOptions = [
    {'name': 'الزمرد الصناعي (Emerald)', 'primary': const Color(0xFF1B4332), 'secondary': const Color(0xFF081C15)},
    {'name': 'البترول والكبريت (PetroApex)', 'primary': const Color(0xFF1E3A8A), 'secondary': const Color(0xFF0F172A)},
    {'name': 'الحزم الفولاذي (Steel Slate)', 'primary': const Color(0xFF334155), 'secondary': const Color(0xFF0F172A)},
    {'name': 'المستودعات البرتقالية (Amber Force)', 'primary': const Color(0xFFC2410C), 'secondary': const Color(0xFF431407)},
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              _selectedSecondaryColor.withOpacity(0.95),
              _selectedPrimaryColor,
              const Color(0xFF050B14),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: GlassContainer(
                  padding: const EdgeInsets.all(32),
                  borderColor: Colors.amberAccent.withOpacity(0.4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios, color: Colors.amberAccent),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Expanded(
                            child: Text(
                              'إعداد منشأة سحابية جديدة وتأسيس حساب المسؤول العام (Enterprise & Admin Setup)',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(width: 40),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'هذا المعبر يختص فقط بالمؤسس والمدير العام لإطلاق الهوية المؤسسية (White-Label UI). لاحقاً، يمكن للمدير إضافة وتفعيل الأعضاء والمراقبين من لوحة التحكُّم في القائمة الجانبية للنظام.',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade300, height: 1.6),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 28),

                      // Section 1: Enterprise Branding
                      _buildSectionHeader('1. الهوية والمعرف المؤسسي (Enterprise White-Label Workspace)'),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _tenantNameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _buildInputDecoration('الاسم الكامل للمنشأة (Tenant Name)', Icons.business),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _subdomainController,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        decoration: _buildInputDecoration('المعرف الرقمي السحابي (Subdomain slug)', Icons.language),
                      ),
                      const SizedBox(height: 18),

                      const Text(
                        'اختر اللون المؤسسي الرسمي لبوابة الأمان الخاصة بالمنشأة:',
                        style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 12,
                        runSpacing: 10,
                        children: _paletteOptions.map((opt) {
                          final isSelected = _selectedPrimaryColor == opt['primary'];
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedPrimaryColor = opt['primary'];
                                _selectedSecondaryColor = opt['secondary'];
                              });
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: (opt['primary'] as Color).withOpacity(0.85),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected ? Colors.amberAccent : Colors.white24,
                                  width: isSelected ? 2.5 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isSelected ? Icons.check_circle : Icons.circle,
                                    color: isSelected ? Colors.amberAccent : Colors.white60,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    opt['name'],
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 30),

                      // Section 2: Sovereign Admin Governance Account
                      _buildSectionHeader('2. بيانات المسؤول العام (Sovereign Admin Profile)'),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _adminFullNameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _buildInputDecoration('الاسم الكامل للمسؤول العام (Admin Full Name)', Icons.person_add_alt_1),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _adminEmailController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.emailAddress,
                        decoration: _buildInputDecoration('البريد الإلكتروني القيادي (Admin Work Email)', Icons.email),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _adminPasswordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'كلمة مرور حساب المسؤول (Admin Password)',
                          labelStyle: TextStyle(color: Colors.grey.shade300, fontSize: 13),
                          prefixIcon: const Icon(Icons.admin_panel_settings, color: Colors.amberAccent),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.white70),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          filled: true,
                          fillColor: Colors.black.withOpacity(0.3),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _departmentController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _buildInputDecoration('الإدارة القيادية (Executive Department)', Icons.corporate_fare),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _branchController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _buildInputDecoration('المقر التشغيلي الرئيسي (Main HQ Branch)', Icons.place),
                      ),
                      const SizedBox(height: 28),

                      if (authProvider.errorMessage != null) ...[
                        Text(
                          authProvider.errorMessage!,
                          style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                      ],

                      ElevatedButton.icon(
                        onPressed: authProvider.isLoading
                            ? null
                            : () async {
                                final success = await authProvider.setupEnterprise(
                                  tenantName: _tenantNameController.text.trim(),
                                  subdomain: _subdomainController.text.trim(),
                                  adminEmail: _adminEmailController.text.trim(),
                                  adminPassword: _adminPasswordController.text.trim(),
                                  adminFullName: _adminFullNameController.text.trim(),
                                  department: _departmentController.text.trim(),
                                  branch: _branchController.text.trim(),
                                  primaryColor: _selectedPrimaryColor,
                                  secondaryColor: _selectedSecondaryColor,
                                  isRtl: _isRtl,
                                );

                                if (success && mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          const Icon(Icons.stars, color: Colors.amber),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              'تم تأسيس البيئة السحابية لمنشأة [${_tenantNameController.text}] بنجاح وتفعيل رتبة المسؤول العام (ADMIN) !',
                                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                                            ),
                                          ),
                                        ],
                                      ),
                                      backgroundColor: const Color(0xFF1E3A8A),
                                      duration: const Duration(seconds: 4),
                                    ),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 6,
                        ),
                        icon: authProvider.isLoading ? const SizedBox() : const Icon(Icons.verified_user, color: Colors.black, size: 24),
                        label: authProvider.isLoading
                            ? const CircularProgressIndicator(color: Colors.black)
                            : const Text('إطلاق المنشأة وتفعيل رتبة المسؤول العام', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: const Border(right: BorderSide(color: Colors.amberAccent, width: 4)),
      ),
      child: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.amberAccent),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey.shade300, fontSize: 13),
      prefixIcon: Icon(icon, color: Colors.amberAccent),
      filled: true,
      fillColor: Colors.black.withOpacity(0.3),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.white.withOpacity(0.15))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.amberAccent, width: 1.5)),
    );
  }
}
