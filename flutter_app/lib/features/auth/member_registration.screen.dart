import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/auth/auth_provider.dart';

class MemberRegistrationScreen extends StatefulWidget {
  const MemberRegistrationScreen({Key? key}) : super(key: key);

  @override
  State<MemberRegistrationScreen> createState() => _MemberRegistrationScreenState();
}

class _MemberRegistrationScreenState extends State<MemberRegistrationScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _departmentController = TextEditingController();
  final _branchController = TextEditingController();
  
  bool _isEligible = false;
  bool _checked = false;
  bool _obscurePassword = true;
  String? _errorMsg;

  void _checkEmail() {
    setState(() {
      _errorMsg = null;
      _checked = false;
    });

    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _errorMsg = 'يرجى إدخال البريد الإلكتروني للتحقق.');
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final memberData = auth.checkMemberEmailEligibility(email);

    if (memberData != null) {
      if (memberData['isRegistered'] == true) {
        setState(() {
          _errorMsg = 'هذا الحساب تم تسجيله وتفعيله مسبقاً. يرجى تسجيل الدخول.';
          _isEligible = false;
          _checked = true;
        });
      } else {
        setState(() {
          _fullNameController.text = memberData['fullName'] ?? '';
          _departmentController.text = memberData['department'] ?? '';
          _branchController.text = memberData['branch'] ?? '';
          _isEligible = true;
          _checked = true;
        });
      }
    } else {
      setState(() {
        _errorMsg = 'عذراً، البريد الإلكتروني غير مسجل مسبقاً. يجب على مسؤول السلامة (Admin) إضافتك أولاً من لوحة التحكم الجانبية لتتمكن من تفعيل العضوية.';
        _isEligible = false;
        _checked = true;
      });
    }
  }

  void _register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final fullName = _fullNameController.text.trim();
    final dept = _departmentController.text.trim();
    final branch = _branchController.text.trim();

    if (password.isEmpty || fullName.isEmpty) {
      setState(() => _errorMsg = 'يرجى تعيين كلمة المرور وكتابة الاسم الكامل.');
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.registerMember(
      email: email,
      password: password,
      fullName: fullName,
      department: dept,
      branch: branch,
    );

    if (success && mounted) {
      Navigator.pop(context); // Go back to login/main
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('أهلاً بك يا $fullName! تم تفعيل حسابك كعضو ميداني بنجاح.'),
          backgroundColor: const Color(0xFF1E5E3A),
        ),
      );
    } else {
      setState(() {
        _errorMsg = auth.errorMessage ?? 'فشل التسجيل، يرجى المحاولة لاحقاً.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: const Text('تسجيل كعضو في الفريق', style: TextStyle(color: Color(0xFF1E5E3A), fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF2D3748), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person_add_rounded, size: 48, color: Color(0xFF1E5E3A)),
                  const SizedBox(height: 12),
                  const Text(
                    'تفعيل وتسجيل حساب الموظف',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF2D3748)),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'يتطلب تفعيل الحساب أن يكون بريدك مضافاً مسبقاً من لوحة تحكم الأدمن المسؤول.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500, height: 1.4),
                  ),
                  const SizedBox(height: 24),

                  if (_errorMsg != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.red.shade200)),
                      child: Text(
                        _errorMsg!,
                        style: TextStyle(color: Colors.red.shade800, fontSize: 13, fontWeight: FontWeight.w600, height: 1.5),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Email input field
                  TextField(
                    controller: _emailController,
                    enabled: !_isEligible,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _inputDeco('البريد الإلكتروني المعتمد للعمل', Icons.email_outlined),
                  ),
                  const SizedBox(height: 14),

                  if (!_isEligible)
                    ElevatedButton(
                      onPressed: _checkEmail,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E5E3A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('التحقق من صلاحية التسجيل', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ),

                  // If email check passed, show the remaining fields
                  if (_isEligible) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.green.shade200)),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'بريدك معتمد! يرجى استكمال تعيين الحساب بالأسفل لتفعيله.',
                              style: TextStyle(color: Color(0xFF1E5E3A), fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _fullNameController,
                      decoration: _inputDeco('الاسم الكامل', Icons.person_outline),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _departmentController,
                      decoration: _inputDeco('القسم / المسمى الميداني', Icons.group_work_outlined),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _branchController,
                      decoration: _inputDeco('الموقع / المقر الميداني', Icons.location_on_outlined),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: _inputDeco(
                        'تعيين كلمة المرور للدخول', 
                        Icons.lock_outline,
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        )
                      ),
                    ),
                    const SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E5E3A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('تفعيل العضوية والدخول للميدان', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String hint, IconData icon, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF1E5E3A)),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF1E5E3A), width: 1.5)),
    );
  }
}
