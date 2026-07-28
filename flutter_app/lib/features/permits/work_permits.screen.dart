import 'package:flutter/material.dart';

class WorkPermitsScreen extends StatefulWidget {
  const WorkPermitsScreen({Key? key}) : super(key: key);

  @override
  State<WorkPermitsScreen> createState() => _WorkPermitsScreenState();
}

class _WorkPermitsScreenState extends State<WorkPermitsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _openPermits = [
    {
      'id': '#PTW-2024-015',
      'title': 'عمل لحام في خزان الوقود',
      'location': 'منطقة الخزانات',
      'startDate': '2024/05/22 - 08:00 ص',
      'endDate': '2024/05/22 - 04:00 م',
      'status': 'مفتوح',
      'isOpen': true,
      'description': 'سيتم تنفيذ أعمال لحام في خزان الوقود رقم (5)، يرجى اتباع جميع إجراءات السلامة الصارمة وارتداء الأقنعة الواقية.',
      'avatars': ['https://i.pravatar.cc/100?img=11', 'https://i.pravatar.cc/100?img=12'],
    },
    {
      'id': '#PTW-2024-014',
      'title': 'صيانة كهربائية ضغط عالي',
      'location': 'لوحة التوزيع الرئيسية',
      'startDate': '2024/05/22 - 08:00 ص',
      'endDate': '2024/05/22 - 04:00 م',
      'status': 'مفتوح',
      'isOpen': true,
      'description': 'صيانة وفحص المحولات الرئيسية للضغط العالي وفصل التيار حسب لائحة العزل بالقفل والشارة (LOTO).',
      'avatars': ['https://i.pravatar.cc/100?img=15', 'https://i.pravatar.cc/100?img=18'],
    },
  ];

  final List<Map<String, dynamic>> _closedPermits = [
    {
      'id': '#PTW-2024-010',
      'title': 'أعمال حفر وصيانة أنابيب التبريد',
      'location': 'المحيط الخارجي للمؤسسة',
      'startDate': '2024/05/18 - 07:00 ص',
      'endDate': '2024/05/18 - 05:00 م',
      'status': 'مغلق',
      'isOpen': false,
      'description': 'تم إنجاز كافة أعمال الحفر الضحل وصيانة شبكة مياه التبريد بكامل إجراءات الأمان.',
      'avatars': ['https://i.pravatar.cc/100?img=32'],
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  void _openDetails(Map<String, dynamic> permit) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => WorkPermitDetailScreen(permit: permit)));
  }

  void _showNewPermitDialog() {
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
                const Text('إصدار تصريح عمل جديد (PTW)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E5E3A))),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 16),
            TextField(decoration: _inputDeco('نوع العمل (مثلاً: أعمال ساخنة / لحام)')),
            const SizedBox(height: 12),
            TextField(decoration: _inputDeco('الموقع المحدد')),
            const SizedBox(height: 12),
            TextField(maxLines: 3, decoration: _inputDeco('وصف العمل واشتراطات السلامة')),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E5E3A), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم رفع طلب التصريح لبدء دورة الاعتماد والتوقيع!'), backgroundColor: Color(0xFF1E5E3A)));
              },
              child: const Text('إرسال للتوقيع والاعتماد', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
        title: const Text('تصاريح العمل', style: TextStyle(color: Color(0xFF1E5E3A), fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF2D3748), size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF1E5E3A),
          unselectedLabelColor: Colors.grey.shade500,
          indicatorColor: const Color(0xFF1E5E3A),
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: const [
            Tab(text: 'المفتوحة'),
            Tab(text: 'المغلقة'),
            Tab(text: 'جميع التصاريح'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPermitList(_openPermits),
          _buildPermitList(_closedPermits),
          _buildPermitList([..._openPermits, ..._closedPermits]),
        ],
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
          label: const Text('تصريح عمل جديد', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          onPressed: _showNewPermitDialog,
        ),
      ),
    );
  }

  Widget _buildPermitList(List<Map<String, dynamic>> items) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isOpen = item['isOpen'] as bool;

        return InkWell(
          onTap: () => _openDetails(item),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item['id'], style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E5E3A), fontSize: 14)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: isOpen ? Colors.green.withOpacity(0.12) : Colors.grey.shade200, borderRadius: BorderRadius.circular(20)),
                      child: Text(item['status'], style: TextStyle(color: isOpen ? const Color(0xFF2E7D32) : Colors.grey.shade700, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(item['title'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1B2533))),
                const SizedBox(height: 10),
                _buildRow(Icons.location_on_outlined, 'الموقع:', item['location']),
                _buildRow(Icons.access_time, 'تاريخ البداية:', item['startDate']),
                _buildRow(Icons.update, 'تاريخ الانتهاء:', item['endDate']),
                const Divider(height: 24, thickness: 0.8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: (item['avatars'] as List<String>).map((url) => Container(
                        margin: const EdgeInsets.only(left: 6),
                        child: CircleAvatar(radius: 14, backgroundImage: NetworkImage(url)),
                      )).toList(),
                    ),
                    Row(
                      children: [
                        Text('التفاصيل والتواقيع', style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF1E5E3A)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRow(IconData icon, String label, String val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 6),
          Text('$label ', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          Text(val, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF2D3748), fontSize: 13)),
        ],
      ),
    );
  }
}

// Work Permit Details Screen with Handwritten Signatures
class WorkPermitDetailScreen extends StatelessWidget {
  final Map<String, dynamic> permit;
  const WorkPermitDetailScreen({Key? key, required this.permit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('تفاصيل تصريح العمل', style: TextStyle(color: Color(0xFF1E5E3A), fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF2D3748), size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(permit['id'], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E5E3A))),
              ),
              const SizedBox(height: 8),
              _buildDetailRow('العمل:', permit['title']),
              _buildDetailRow('الموقع:', permit['location']),
              _buildDetailRow('تاريخ البداية:', permit['startDate']),
              _buildDetailRow('تاريخ الانتهاء:', permit['endDate']),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),

              const Text('وصف العمل', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E5E3A))),
              const SizedBox(height: 8),
              Text(permit['description'], style: TextStyle(fontSize: 14, color: Colors.grey.shade800, height: 1.6)),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),

              const Text('الموافقات والتواقيع', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E5E3A))),
              const SizedBox(height: 16),

              _buildSignatureCard('الطالب', 'أحمد علي', 'Ahmed Ali Signature', Colors.teal),
              _buildSignatureCard('المشرف المباشر', 'سامي الجهني', 'Sami Al-Juhani', Colors.blue.shade800),
              _buildSignatureCard('مسؤول السلامة', 'فهد السلامة', 'Fahad Safety Mgr', const Color(0xFF1E5E3A)),
              _buildSignatureCard('الاعتماد النهائي', 'مدير المصنع', 'General Manager Approved', Colors.purple.shade800),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('الحالة: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D3748))),
                  Text(
                    permit['status'],
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: permit['isOpen'] ? Colors.orange.shade800 : const Color(0xFF2E7D32)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(width: 95, child: Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.bold))),
          Expanded(child: Text(val, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1B2533), fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildSignatureCard(String role, String name, String scriptText, Color inkColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(role, style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2D3748))),
            ],
          ),
          // Calligraphic / cursive stylized signature simulation
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: inkColor.withOpacity(0.06),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: inkColor.withOpacity(0.3), style: BorderStyle.solid),
            ),
            child: Text(
              scriptText,
              style: TextStyle(
                fontFamily: 'cursive',
                fontSize: 16,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
                color: inkColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
