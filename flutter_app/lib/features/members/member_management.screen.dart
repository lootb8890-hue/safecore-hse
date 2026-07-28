import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/auth/auth_provider.dart';

class MemberManagementScreen extends StatefulWidget {
  const MemberManagementScreen({Key? key}) : super(key: key);

  @override
  State<MemberManagementScreen> createState() => _MemberManagementScreenState();
}

class _MemberManagementScreenState extends State<MemberManagementScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _departmentController = TextEditingController(text: 'فحص التفتيش والسلامة الميدانية');
  final _branchController = TextEditingController(text: 'مصفاة جدة - المنطقة التشغيلية');
  final _passwordController = TextEditingController(text: 'SafeCore@2026!');

  void _showAddMemberModal(BuildContext context) {
    _nameController.clear();
    _emailController.clear();
    _departmentController.text = 'فحص التفتيش والسلامة الميدانية';
    _branchController.text = 'مصفاة جدة - المنطقة التشغيلية';
    _passwordController.text = 'SafeCore@2026!';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFF1E5E3A), width: 1.5)),
        title: const Row(
          children: [
            Icon(Icons.person_add, color: Color(0xFF1E5E3A), size: 28),
            SizedBox(width: 12),
            Expanded(child: Text('تسجيل وإدراج عضو / مراقب جديد', style: TextStyle(color: Color(0xFF1E5E3A), fontWeight: FontWeight.w900, fontSize: 17))),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'سيتم تسجيل العضو في القائمة المعتمدة. لن يتمكن العضو من إتمام التسجيل وتفعيل حسابه والدخول إلا بالبريد المعتمد الذي تحدده بالأسفل.',
                style: TextStyle(color: Colors.black54, fontSize: 12, height: 1.5),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: _dialogInput('اسم العضو الميداني الثنائي/الثلاثي', Icons.person_outline),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _dialogInput('البريد الإلكتروني للعمل (Email)', Icons.email_outlined),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _departmentController,
                decoration: _dialogInput('القسم / الاختصاص الميداني', Icons.group_work_outlined),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _branchController,
                decoration: _dialogInput('المقر / المحطة الميدانية', Icons.place_outlined),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                decoration: _dialogInput('كلمة المرور المبدئية الموصى بها', Icons.lock_outline),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E5E3A).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF1E5E3A)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lock_person_outlined, color: Color(0xFF1E5E3A), size: 18),
                    SizedBox(width: 8),
                    Expanded(child: Text('الرتبة الافتراضية المقررة: عضو مراقب (MEMBER)', style: TextStyle(color: Color(0xFF1E5E3A), fontWeight: FontWeight.bold, fontSize: 12))),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              final name = _nameController.text.trim();
              final email = _emailController.text.trim();
              final dept = _departmentController.text.trim();
              final branch = _branchController.text.trim();
              final pass = _passwordController.text.trim();

              if (name.isEmpty || email.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى ملء الاسم والبريد الإلكتروني للتحقق.')));
                return;
              }

              final auth = Provider.of<AuthProvider>(context, listen: false);
              final success = await auth.addMemberByAdmin(
                fullName: name,
                email: email,
                department: dept,
                branch: branch,
                password: pass,
              );

              if (success && mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم إدراج العضو [$name] بنجاح في المنظومة. يمكنه الآن تسجيل الحساب بالبريد الإلكتروني وتفعيله.'),
                    backgroundColor: const Color(0xFF1E5E3A),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('عذراً، هذا البريد مسجل مسبقاً أو غير صالح.')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E5E3A), foregroundColor: Colors.white),
            icon: const Icon(Icons.check, size: 18),
            label: const Text('اعتماد وإضافة', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  InputDecoration _dialogInput(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 12),
      prefixIcon: Icon(icon, color: const Color(0xFF1E5E3A), size: 20),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF1E5E3A), width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final members = authProvider.membersList;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: const Text('إدارة أعضاء الفريق', style: TextStyle(color: Color(0xFF1E5E3A), fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF2D3748), size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Banner explaining Member onboarding workflow
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E5E3A).withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF1E5E3A).withOpacity(0.15)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFF1E5E3A), size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'بروتوكول اعتماد وحماية الأعضاء في الفريق:',
                            style: TextStyle(color: Color(0xFF1E5E3A), fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'يقوم الأدمن بإضافة حسابات الموظفين المعتمدين بالأسفل. بعد الإضافة، يستطيع الموظف التوجه لشاشة "تسجيل كعضو" في الدخول وإكمال بيانات تفعيل حسابه بنجاح بالبريد الإلكتروني المعتمد.',
                            style: TextStyle(color: Colors.grey.shade700, fontSize: 11, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'قائمة أعضاء الفريق المعتمدين (${members.length}):',
                    style: const TextStyle(color: Color(0xFF1B2533), fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddMemberModal(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E5E3A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.person_add_alt_1, size: 18),
                    label: const Text('إضافة عضو جديد', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Roster List
              Expanded(
                child: members.isEmpty
                    ? const Center(child: Text('لا يوجد أعضاء مضافين بعد. اضغط على "إضافة عضو جديد" للمباشرة.'))
                    : ListView.builder(
                        itemCount: members.length,
                        itemBuilder: (context, index) {
                          final member = members[index];
                          final email = member['email'] ?? '';
                          final name = member['fullName'] ?? 'بلا اسم';
                          final dept = member['department'] ?? 'فريق المراقبة الميدانية';
                          final branch = member['branch'] ?? 'مصفاة جدة';
                          final isRegistered = member['isRegistered'] == true;
                          final isActive = member['isActive'] == true;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2))],
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: isRegistered ? const Color(0xFF1E5E3A).withOpacity(0.1) : Colors.grey.shade200,
                                  child: Icon(Icons.engineering, color: isRegistered ? const Color(0xFF1E5E3A) : Colors.grey, size: 24),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            name,
                                            style: const TextStyle(color: Color(0xFF1B2533), fontWeight: FontWeight.bold, fontSize: 14),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: isRegistered ? Colors.green.withOpacity(0.1) : Colors.amber.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              isRegistered ? 'مسجل ونشط' : 'قيد تفعيل العضو',
                                              style: TextStyle(color: isRegistered ? Colors.green.shade800 : Colors.amber.shade900, fontSize: 10, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        email,
                                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w500),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '$dept • $branch',
                                        style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Switch(
                                      value: isActive,
                                      activeColor: const Color(0xFF1E5E3A),
                                      onChanged: (val) {
                                        authProvider.toggleMemberStatus(email, val);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(val ? 'تم تنشيط حساب [$name]' : 'تم إيقاف صلاحية دخول [$name] مؤقتاً'),
                                            backgroundColor: val ? const Color(0xFF1E5E3A) : Colors.red.shade700,
                                          ),
                                        );
                                      },
                                    ),
                                    Text(
                                      isActive ? 'مسموح' : 'موقوف',
                                      style: TextStyle(color: isActive ? const Color(0xFF1E5E3A) : Colors.red, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                  onPressed: () {
                                    authProvider.removeMember(email);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('تم حذف العضو [$name] نهائياً من قائمة الاعتماد.'), backgroundColor: Colors.red.shade700),
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
