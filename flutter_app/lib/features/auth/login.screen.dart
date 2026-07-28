import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/theme/branding_engine.dart';
import 'enterprise_setup.screen.dart';
import 'member_registration.screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _subdomainController = TextEditingController(text: 'petroapex');
  final _emailController = TextEditingController(text: 'admin@petroapex.com');
  final _passwordController = TextEditingController(text: 'SafeCore@2026!');
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final brandingProvider = Provider.of<BrandingProvider>(context);
    final branding = brandingProvider.branding;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Corporate Emblem matching the safety logo
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E5E3A).withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF1E5E3A), width: 2),
                      ),
                      child: const Icon(Icons.health_and_safety, size: 48, color: Color(0xFF1E5E3A)),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      branding.tenantName.isNotEmpty ? branding.tenantName : 'السلامة المهنية - SafeCore HSE',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1B2533),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'بوابة المراقبة الميدانية والحكامة الصناعية',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Quick-Login Evaluation Shortcuts (One-Click Testing)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            '⚡ تجربة سريعة واختبار الصلاحيات (Demo Login):',
                            style: TextStyle(color: Color(0xFF1E5E3A), fontWeight: FontWeight.bold, fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: authProvider.isLoading
                                      ? null
                                      : () => authProvider.quickLoginDemo(true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1B2533),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  icon: const Icon(Icons.admin_panel_settings, color: Colors.amber, size: 18),
                                  label: const Text('أدمن مسؤول', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: authProvider.isLoading
                                      ? null
                                      : () => authProvider.quickLoginDemo(false),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1E5E3A),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  icon: const Icon(Icons.engineering, color: Colors.lightGreenAccent, size: 18),
                                  label: const Text('عضو ميداني', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey.shade300)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('أو تسجيل الدخول المباشر', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                        ),
                        Expanded(child: Divider(color: Colors.grey.shade300)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Subdomain Field
                    TextField(
                      controller: _subdomainController,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      decoration: _buildInputDecoration(
                        label: 'معرف المنشأة السحابي (Tenant Subdomain)',
                        hint: 'مثال: petroapex',
                        icon: Icons.domain,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Email Field
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _buildInputDecoration(
                        label: 'البريد الإلكتروني للعمل',
                        hint: 'inspector@company.com',
                        icon: Icons.email_outlined,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Password Field
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: _buildInputDecoration(
                        label: 'كلمة المرور',
                        hint: '••••••••••••',
                        icon: Icons.lock_outline,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey.shade600,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (authProvider.errorMessage != null) ...[
                      Text(
                        authProvider.errorMessage!,
                        style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Sign In Action Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: authProvider.isLoading
                            ? null
                            : () async {
                                await authProvider.login(
                                  _subdomainController.text.trim(),
                                  _emailController.text.trim(),
                                  _passwordController.text.trim(),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E5E3A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: authProvider.isLoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('تسجيل الدخول إلى بيئة العمل', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Sign Up (Member Registration) Link
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const MemberRegistrationScreen()),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF1E5E3A), width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.person_add_outlined, color: Color(0xFF1E5E3A)),
                        label: const Text(
                          'تسجيل كعضو في الفريق',
                          style: TextStyle(color: Color(0xFF1E5E3A), fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    Divider(color: Colors.grey.shade300),
                    const SizedBox(height: 8),

                    // Setup Reset option for demo testing
                    TextButton.icon(
                      onPressed: () async {
                        await authProvider.resetSetup();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تم تصفير وإعادة تعيين إعدادات المنشأة الافتراضية بنجاح!'), backgroundColor: Colors.orange),
                        );
                      },
                      icon: const Icon(Icons.refresh, color: Colors.grey, size: 16),
                      label: const Text(
                        'إعادة تهيئة الإعدادات العامة (Reset Setup)',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
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

  InputDecoration _buildInputDecoration({required String label, required String hint, required IconData icon, Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 13),
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
      prefixIcon: Icon(icon, color: const Color(0xFF1E5E3A)),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF1E5E3A), width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    );
  }
}
