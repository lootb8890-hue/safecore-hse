import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/theme/branding_engine.dart';
import '../../core/theme/glassmorphism.dart';
import 'enterprise_setup.screen.dart';

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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              branding.secondaryColor.withOpacity(0.9),
              branding.primaryColor,
              const Color(0xFF0F172A),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: GlassContainer(
                  padding: const EdgeInsets.all(28),
                  borderColor: Colors.white.withOpacity(0.2),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Corporate Emblem
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.amber, width: 2),
                        ),
                        child: const Icon(Icons.shield, size: 48, color: Colors.amber),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'SafeCore Enterprise HSE Platform',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'بوابة الأمان المهني والحكامة الصناعية',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade300,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Quick-Login Evaluation Shortcuts (One-Click Testing)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              '⚡ تجربة سريعة واختبار الصلاحيات (One-Click Demo):',
                              style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.w700, fontSize: 13),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: authProvider.isLoading
                                  ? null
                                  : () => authProvider.quickLoginDemo(true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E3A8A),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              icon: const Icon(Icons.admin_panel_settings, color: Colors.amber),
                              label: const Text('دخول كمسؤول عام (Admin Governance Role)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: authProvider.isLoading
                                  ? null
                                  : () => authProvider.quickLoginDemo(false),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2E6F40),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              icon: const Icon(Icons.engineering, color: Colors.greenAccent),
                              label: const Text('دخول كعضو / مراقب ميداني (Member Inspector)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey.shade600)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text('أو بتسجيل الدخول الاعتیادي', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                          ),
                          Expanded(child: Divider(color: Colors.grey.shade600)),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Credential Input Form
                      TextField(
                        controller: _subdomainController,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        decoration: _buildInputDecoration(
                          label: 'معرف المنشأة السحابي (Tenant Subdomain)',
                          hint: 'مثال: petroapex أو alnoor',
                          icon: Icons.domain,
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _emailController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.emailAddress,
                        decoration: _buildInputDecoration(
                          label: 'البريد الإلكتروني للعضو (Work Email)',
                          hint: 'inspector@company.com',
                          icon: Icons.email_outlined,
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(color: Colors.white),
                        decoration: _buildInputDecoration(
                          label: 'كلمة المرور (Password)',
                          hint: '••••••••••••',
                          icon: Icons.lock_outline,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: Colors.grey.shade400,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),

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
                            backgroundColor: Colors.amber.shade700,
                            foregroundColor: Colors.black87,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: authProvider.isLoading
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                              : const Text('تسجيل الدخول إلى بيئة العمل', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Enterprise Onboarding Link
                      Divider(color: Colors.grey.withOpacity(0.3)),
                      const SizedBox(height: 14),
                      OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const EnterpriseSetupScreen()),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.amberAccent, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.business_center, color: Colors.amberAccent),
                        label: const Text(
                          'تأسيس منشأة جديدة وإعداد حساب المسؤول العام',
                          style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.w800, fontSize: 13),
                        ),
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

  InputDecoration _buildInputDecoration({required String label, required String hint, required IconData icon, Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(color: Colors.grey.shade300, fontSize: 13),
      hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 12),
      prefixIcon: Icon(icon, color: Colors.amber.shade300),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.black.withOpacity(0.25),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.white.withOpacity(0.15))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.amber, width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    );
  }
}
