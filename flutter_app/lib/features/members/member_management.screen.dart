import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/auth/auth_provider.dart';
import '../../core/theme/branding_engine.dart';

class MemberItem {
  final String id;
  final String fullName;
  final String email;
  final String department;
  final String branch;
  final String role;
  bool isActive;

  MemberItem({
    required this.id,
    required this.fullName,
    required this.email,
    required this.department,
    required this.branch,
    this.role = 'MEMBER',
    this.isActive = true,
  });
}

class MemberManagementScreen extends StatefulWidget {
  const MemberManagementScreen({Key? key}) : super(key: key);

  @override
  State<MemberManagementScreen> createState() => _MemberManagementScreenState();
}

class _MemberManagementScreenState extends State<MemberManagementScreen> {
  final List<MemberItem> _members = [
    MemberItem(
      id: 'usr_m01',
      fullName: 'طارق زياد (Tariq Ziad)',
      email: 'inspector@petroapex.com',
      department: 'قسم المراقبة الميدانية ومسح الأمان',
      branch: 'مصفاة جدة - المنطقة التشغيلية (أ)',
      role: 'MEMBER',
    ),
    MemberItem(
      id: 'usr_m02',
      fullName: 'سارة الغامدي (Sarah Al-Ghamdi)',
      email: 's.ghamdi@petroapex.com',
      department: 'إدارة الرصد البيئي ومكافحة الانبعاثات',
      branch: 'المقر التجريبي - ينبع الصناعية',
      role: 'MEMBER',
    ),
    MemberItem(
      id: 'usr_m03',
      fullName: 'ناصر الدوسري (Nasser Al-Dosy)',
      email: 'n.dosri@petroapex.com',
      department: 'فريق الاستجابة السريعة لمكافحة الطوارئ',
      branch: 'مستودعات الوقود المركزية - الخرج',
      role: 'MEMBER',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final branding = Provider.of<BrandingProvider>(context).branding;

    if (!authProvider.isAdmin) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        appBar: AppBar(title: const Text('خطأ في الصلاحيات')),
        body: const Center(
          child: Text(
            'هذه الواجهة مخصصة للمسؤول العام (Admin) فقط ولا يمكن للأعضاء العاديين الوصول إليها.',
            style: TextStyle(color: Colors.redAccent, fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0B1120),
      appBar: AppBar(
        backgroundColor: branding.secondaryColor,
        elevation: 4,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('إدارة شؤون الأعضاء والمراقبين الميدانيين', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
            Text('Admin Governance & Member Roster', style: TextStyle(fontSize: 12, color: Colors.amberAccent, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shield, color: Colors.black, size: 16),
                SizedBox(width: 6),
                Text('حساب مسؤول عام (Admin)', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Banner explaining Member onboarding workflow
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amberAccent.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.amberAccent, size: 32),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'بروتوكول اعتماد وحماية الأعضاء في المنشأة:',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'وفقاً لتعليمات الحكامة الصناعية، يقوم المسؤول العام (Admin) من هذه الواجهة بإنشاء وإضافة حسابات الموظفين والمراقبين برتبة عضو (MEMBER). يستطيع الأعضاء التسجيل والدخول فوراً بالبريد الإلكتروني المخصص لإتمام المراجعات والبلاغات في الميدان دون مساس بالصلاحيات القيادية.',
                            style: TextStyle(color: Colors.grey.shade300, fontSize: 12, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'قائمة الطاقم الميداني والأعضاء (${_members.length}):',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddMemberModal(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.person_add_alt_1, size: 20),
                    label: const Text('إضافة عضو / مراقب جديد', style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Roster List
              Expanded(
                child: ListView.builder(
                  itemCount: _members.length,
                  itemBuilder: (context, index) {
                    final member = _members[index];
                    return Card(
                      color: const Color(0xFF1E293B),
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: member.isActive ? Colors.white12 : Colors.redAccent.withOpacity(0.4)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 26,
                              backgroundColor: member.isActive ? Colors.green.shade700 : Colors.grey.shade700,
                              child: const Icon(Icons.engineering, color: Colors.white, size: 28),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        member.fullName,
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15),
                                      ),
                                      const SizedBox(width: 10),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: Colors.greenAccent, width: 1),
                                        ),
                                        child: const Text('🛡️ رتبة عضو (MEMBER)', style: TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.w800)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.email, color: Colors.amberAccent, size: 14),
                                      const SizedBox(width: 6),
                                      Text(member.email, style: TextStyle(color: Colors.grey.shade300, fontSize: 13, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, color: Colors.white60, size: 14),
                                      const SizedBox(width: 6),
                                      Text('${member.department} | ${member.branch}', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                Switch(
                                  value: member.isActive,
                                  activeColor: Colors.amber,
                                  onChanged: (val) {
                                    setState(() {
                                      member.isActive = val;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(val ? 'تم تنشيط حساب [${member.fullName}]' : 'تم إيقاف صلاحية دخول [${member.fullName}] مؤقتاً')),
                                    );
                                  },
                                ),
                                Text(
                                  member.isActive ? 'نشط ميدانياً' : 'موقوف',
                                  style: TextStyle(color: member.isActive ? Colors.greenAccent : Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
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

  void _showAddMemberModal(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final departmentController = TextEditingController(text: 'فحص التفتيش والسلامة الميدانية');
    final branchController = TextEditingController(text: 'المنطقة التشغيلية');
    final passwordController = TextEditingController(text: 'SafeCore@2026!');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Colors.amberAccent, width: 1.5)),
        title: const Row(
          children: [
            Icon(Icons.person_add, color: Colors.amber, size: 28),
            SizedBox(width: 12),
            Expanded(child: Text('تسجيل وإدراج عضو / مراقب جديد', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17))),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'سيتم منح الموظف رتبة (عضو / مراقب ميداني) حصراً، مما يتيح له استخدام كافة واجهات الفحص والذكاء الاصطناعي والإبلاغ دون صلاحيات قيادية للمنشأة.',
                style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.5),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: _dialogInput('اسم العضو الثلاثي (Member Full Name)', Icons.person),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                style: const TextStyle(color: Colors.white),
                decoration: _dialogInput('البريد العملي (Member Email)', Icons.email),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: departmentController,
                style: const TextStyle(color: Colors.white),
                decoration: _dialogInput('القسم / الاختصاص (Department)', Icons.group_work),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: branchController,
                style: const TextStyle(color: Colors.white),
                decoration: _dialogInput('المقر / المحطة (Facility Branch)', Icons.place),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                style: const TextStyle(color: Colors.white),
                decoration: _dialogInput('كلمة المرور المبدئية (Initial Password)', Icons.lock),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.15), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.greenAccent)),
                child: const Row(
                  children: [
                    Icon(Icons.lock_person, color: Colors.greenAccent, size: 18),
                    SizedBox(width: 8),
                    Expanded(child: Text('الرتبة المعتمدة التلقائية: عضو مراقب (MEMBER)', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 12))),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              if (nameController.text.trim().isEmpty || emailController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى كتابة اسم العضو وبريده الإلكتروني على الأقل')));
                return;
              }

              setState(() {
                _members.insert(0, MemberItem(
                  id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
                  fullName: nameController.text.trim(),
                  email: emailController.text.trim(),
                  department: departmentController.text.trim(),
                  branch: branchController.text.trim(),
                  role: 'MEMBER',
                ));
              });

              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم تسجيل العضو [${nameController.text}] بنجاح وإضافته كمراقب ميداني في قائمة المنشأة!'),
                  backgroundColor: Colors.green.shade800,
                  duration: const Duration(seconds: 4),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
            icon: const Icon(Icons.check, size: 18),
            label: const Text('تضمين وحفظ العضو', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }

  InputDecoration _dialogInput(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
      prefixIcon: Icon(icon, color: Colors.amberAccent, size: 20),
      filled: true,
      fillColor: Colors.black.withOpacity(0.3),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }
}
