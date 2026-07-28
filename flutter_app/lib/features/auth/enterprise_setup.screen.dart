import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/theme/branding_engine.dart';

class EnterpriseSetupScreen extends StatefulWidget {
  const EnterpriseSetupScreen({Key? key}) : super(key: key);

  @override
  State<EnterpriseSetupScreen> createState() => _EnterpriseSetupScreenState();
}

class _EnterpriseSetupScreenState extends State<EnterpriseSetupScreen> {
  final _tenantNameController = TextEditingController(text: 'شركة نورس لصناعات الطاقة والسلامة');
  final _subdomainController = TextEditingController(text: 'petroapex');
  final _adminEmailController = TextEditingController(text: 'admin@petroapex.com');
  final _adminFullNameController = TextEditingController(text: 'م. خالد المنصور (مدير السلامة)');
  final _adminPasswordController = TextEditingController(text: 'SafeCore@2026!');
  final _departmentController = TextEditingController(text: 'الإدارة العامة لحوكمة الأمان والجودة');
  final _branchController = TextEditingController(text: 'المقر الرئيسي - مجمع الرياض');

  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 550),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.business_center_rounded, size: 48, color: Color(0xFF1E5E3A)),
                    const SizedBox(height: 12),
                    const Text(
                      'إعداد منشأة سحابية جديدة وتأسيس حساب المشرف الأول (الأدمن)',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF2D3748)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'هذا المعبر يختص فقط بمدير ومسؤول المنشأة لإطلاق النظام. لاحقاً، يقوم الأدمن بإضافة حسابات الأعضاء الميدانيين ليتمكنوا من التسجيل والدخول.',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    _buildSectionHeader('1. المعرف والاسم المؤسسي للمنشأة'),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _tenantNameController,
                      decoration: _buildInputDecoration('الاسم الكامل للمنشأة (Tenant Name)', Icons.business),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _subdomainController,
                      decoration: _buildInputDecoration('المعرف السحابي للمنشأة (Subdomain slug)', Icons.language),
                    ),
                    const SizedBox(height: 20),

                    _buildSectionHeader('2. بيانات حساب الأدمن (المشرف الأول)'),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _adminFullNameController,
                      decoration: _buildInputDecoration('الاسم الكامل للمشرف', Icons.person_outline),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _adminEmailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _buildInputDecoration('البريد الإلكتروني القيادي', Icons.email_outlined),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _adminPasswordController,
                      obscureText: _obscurePassword,
                      decoration: _buildInputDecoration(
                        'كلمة مرور حساب المسؤول',
                        Icons.lock_outline,
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _departmentController,
                      decoration: _buildInputDecoration('الإدارة القيادية', Icons.corporate_fare),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _branchController,
                      decoration: _buildInputDecoration('المقر الرئيسي / الفرع الميداني', Icons.place_outlined),
                    ),
                    const SizedBox(height: 24),

                    if (authProvider.errorMessage != null) ...[
                      Text(
                        authProvider.errorMessage!,
                        style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 14),
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
                                primaryColor: const Color(0xFF1E5E3A),
                                secondaryColor: const Color(0xFF1B2533),
                                isRtl: true,
                              );

                              if (success && mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('تم تأسيس منشأة [${_tenantNameController.text}] بنجاح وتفعيل حساب الأدمن!'),
                                    backgroundColor: const Color(0xFF1E5E3A),
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E5E3A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: authProvider.isLoading ? const SizedBox() : const Icon(Icons.verified_user),
                      label: authProvider.isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('إطلاق المنشأة وتفعيل حساب الأدمن', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    ),

                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        // Skip/bypass to login if they want to bypass setting up
                        authProvider.resetSetup().then((_) {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                        });
                      },
                      child: const Text('التوجه لصفحة تسجيل الدخول المباشر (Bypass to Login)', style: TextStyle(color: Colors.grey)),
                    ),
                  ],
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1E5E3A).withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: const Border(right: BorderSide(color: Color(0xFF1E5E3A), width: 4)),
      ),
      child: Text(
        title,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E5E3A)),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 13),
      prefixIcon: Icon(icon, color: const Color(0xFF1E5E3A)),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF1E5E3A), width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    );
  }
}
