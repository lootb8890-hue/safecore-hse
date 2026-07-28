import 'package:flutter/material.dart';

class SafetyWarningsScreen extends StatefulWidget {
  const SafetyWarningsScreen({Key? key}) : super(key: key);

  @override
  State<SafetyWarningsScreen> createState() => _SafetyWarningsScreenState();
}

class _SafetyWarningsScreenState extends State<SafetyWarningsScreen> {
  final List<Map<String, dynamic>> _warnings = [
    {
      'name': 'أحمد علي',
      'avatar': 'https://i.pravatar.cc/150?img=11',
      'title': 'مخالفة عدم ارتداء معدات الوقاية الشخصية (PPE)',
      'date': '2024/05/15',
      'duration': '30 يوم',
      'status': 'نشط',
      'isActive': true,
      'images': [
        'https://images.unsplash.com/photo-1504307651591-00dcc993a6f5?auto=format&fit=crop&w=400&q=80',
        'https://images.unsplash.com/photo-1517646287270-a5a9ca602e5c?auto=format&fit=crop&w=400&q=80',
      ],
    },
    {
      'name': 'محمد خالد',
      'avatar': 'https://i.pravatar.cc/150?img=60',
      'title': 'مخالفة التدخين في المنطقة المحظورة بالقرب من المخازن',
      'date': '2024/04/20',
      'duration': '30 يوم',
      'status': 'منتهي',
      'isActive': false,
      'images': [
        'https://images.unsplash.com/photo-1581092160607-ee22621dd758?auto=format&fit=crop&w=400&q=80',
        'https://images.unsplash.com/photo-1581092335397-9583fe92d232?auto=format&fit=crop&w=400&q=80',
      ],
    },
    {
      'name': 'سامي الجهني',
      'avatar': 'https://i.pravatar.cc/150?img=12',
      'title': 'تجاوز السرعة المقررة بمركبة الرافعة الشوكية داخل الخط الأول',
      'date': '2024/05/10',
      'duration': '15 يوم',
      'status': 'نشط',
      'isActive': true,
      'images': [
        'https://images.unsplash.com/photo-1563986768609-322da13575f3?auto=format&fit=crop&w=400&q=80',
      ],
    },
  ];

  void _showNewWarningModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('إصدار إنذار مخالفة سلامة جديد', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E5E3A))),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 16),
            TextField(decoration: _inputDeco('اسم الموظف المخالف / رقمه الوظيفي')),
            const SizedBox(height: 12),
            TextField(decoration: _inputDeco('نوع المخالفة الميدانية (مثلاً: عدم ارتداء الخوذة)')),
            const SizedBox(height: 12),
            TextField(decoration: _inputDeco('مدة الإنذار المقررة (مثلاً: 30 يوم)')),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E5E3A), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تسجيل وتقييد الإنذار الميداني للموظف!'), backgroundColor: Color(0xFF1E5E3A)));
              },
              child: const Text('اعتماد وتسجيل الإنذار', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('الانذارات', style: TextStyle(color: Color(0xFF1E5E3A), fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF2D3748), size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Color(0xFF2D3748)),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Top Summary Row
            Row(
              children: [
                Expanded(child: _buildStatBox('5', 'إجمالي الإنذارات', const Color(0xFF2D3748))),
                const SizedBox(width: 10),
                Expanded(child: _buildStatBox('2', 'انذارات منتهية', Colors.orange.shade700)),
                const SizedBox(width: 10),
                Expanded(child: _buildStatBox('3', 'انذارات نشطة', Colors.red.shade700)),
              ],
            ),
            const SizedBox(height: 20),

            // Warnings list
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _warnings.length,
              itemBuilder: (context, index) {
                final w = _warnings[index];
                final isActive = w['isActive'] as bool;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Employee info
                      Row(
                        children: [
                          CircleAvatar(radius: 22, backgroundImage: NetworkImage(w['avatar'])),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(w['name'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B2533))),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isActive ? Colors.red.withOpacity(0.12) : Colors.orange.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              w['status'],
                              style: TextStyle(color: isActive ? Colors.red.shade700 : Colors.orange.shade800, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Text(w['title'], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF2D3748))),
                      const SizedBox(height: 10),

                      _buildRow('تاريخ الإنذار:', w['date']),
                      _buildRow('مدة الإنذار:', w['duration']),
                      _buildRowColored('حالة الإنذار:', w['status'], isActive ? Colors.red.shade700 : Colors.grey.shade700),
                      const SizedBox(height: 12),

                      const Text('الصور التوثيقية', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 60,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: (w['images'] as List).length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, idx) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network((w['images'] as List)[idx], width: 70, height: 60, fit: BoxFit.cover),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey.shade200))),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E5E3A),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          icon: const Icon(Icons.add, size: 24),
          label: const Text('انذار جديد', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          onPressed: _showNewWarningModal,
        ),
      ),
    );
  }

  Widget _buildStatBox(String count, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Text(count, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade600), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(width: 95, child: Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13))),
          Text(val, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2D3748), fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildRowColored(String label, String val, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(width: 95, child: Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13))),
          Text(val, style: TextStyle(fontWeight: FontWeight.w800, color: color, fontSize: 13)),
        ],
      ),
    );
  }
}
