import 'package:flutter/material.dart';

class ObservationsScreen extends StatefulWidget {
  const ObservationsScreen({Key? key}) : super(key: key);

  @override
  State<ObservationsScreen> createState() => _ObservationsScreenState();
}

class _ObservationsScreenState extends State<ObservationsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _receivedList = [
    {
      'id': '#SC-2024-0001',
      'title': 'رصد تسرب زيت في ماكينة رقم (3)',
      'createdDate': '2024/05/21 - 10:30 ص',
      'creator': 'أحمد علي',
      'location': 'مبنى الإنتاج - الخط الأول',
      'priority': 'عالية',
      'assignee': 'محمد خالد',
      'status': 'قيد المعالجة',
      'isOpen': true,
      'images': [
        'https://images.unsplash.com/photo-1581092160607-ee22621dd758?auto=format&fit=crop&w=400&q=80',
        'https://images.unsplash.com/photo-1581092335397-9583fe92d232?auto=format&fit=crop&w=400&q=80',
      ],
    },
    {
      'id': '#SC-2024-0002',
      'title': 'إضاءة طوارئ لا تعمل في الممر',
      'createdDate': '2024/05/20 - 09:15 ص',
      'creator': 'سامي الجهني',
      'location': 'مبنى الإدارة - الممر الرئيسي',
      'priority': 'متوسطة',
      'assignee': 'فهد العتيبي',
      'status': 'تم الحل',
      'isOpen': false,
      'images': [
        'https://images.unsplash.com/photo-1563986768609-322da13575f3?auto=format&fit=crop&w=400&q=80',
        'https://images.unsplash.com/photo-1513836279014-a89f7a76ae86?auto=format&fit=crop&w=400&q=80',
      ],
    },
  ];

  final List<Map<String, dynamic>> _createdList = [
    {
      'id': '#SC-2024-0003',
      'title': 'ملاحظة خطر في سلم الطوارئ الخارجي',
      'createdDate': '2024/05/22 - 08:00 ص',
      'creator': 'أنت (المدير)',
      'location': 'مبنى الإنتاج - الدور الأول',
      'priority': 'عالية',
      'assignee': 'فهد السلامة',
      'status': 'مفتوح',
      'isOpen': true,
      'images': [
        'https://images.unsplash.com/photo-1517646287270-a5a9ca602e5c?auto=format&fit=crop&w=400&q=80',
        'https://images.unsplash.com/photo-1504307651591-00dcc993a6f5?auto=format&fit=crop&w=400&q=80',
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _openCreateScreen() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CreateObservationScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('الاسكار', style: TextStyle(color: Color(0xFF1E5E3A), fontWeight: FontWeight.bold)),
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
            Tab(text: 'التي تم استلامها'),
            Tab(text: 'التي قمت بإنشائها'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildObservationsList(_receivedList),
          _buildObservationsList(_createdList),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1E5E3A),
        foregroundColor: Colors.white,
        onPressed: _openCreateScreen,
        tooltip: 'انشاء اسكار جديد',
        child: const Icon(Icons.add_task, size: 26),
      ),
    );
  }

  Widget _buildObservationsList(List<Map<String, dynamic>> items) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isOpen = item['isOpen'] as bool;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3)),
            ],
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Status badge and ID
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: isOpen ? Colors.red.withOpacity(0.12) : Colors.green.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isOpen ? 'مفتوح' : 'مغلق',
                      style: TextStyle(
                        color: isOpen ? Colors.red.shade700 : const Color(0xFF2E7D32),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(item['id'], style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E5E3A), fontSize: 14)),
                ],
              ),
              const SizedBox(height: 12),

              // Title
              Text(item['title'], style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF1B2533))),
              const SizedBox(height: 12),

              // Metadata Table
              _buildMetaRow('تم الإنشاء:', item['createdDate']),
              _buildMetaRow('المنشئ:', item['creator']),
              _buildMetaRow('الموقع:', item['location']),
              _buildMetaRowColored('الأولوية:', item['priority'], item['priority'] == 'عالية' ? Colors.red.shade700 : Colors.orange.shade700),
              _buildMetaRow('المستلم:', item['assignee']),
              _buildMetaRowColored('الحالة:', item['status'], isOpen ? Colors.orange.shade800 : const Color(0xFF2E7D32)),
              const SizedBox(height: 14),

              // Images Row
              if (item['images'] != null)
                SizedBox(
                  height: 64,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: (item['images'] as List).length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, imgIdx) {
                      return ClipReredRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          (item['images'] as List)[imgIdx],
                          width: 80,
                          height: 64,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, _, __) => Container(
                            width: 80, height: 64, color: Colors.grey.shade200,
                            child: const Icon(Icons.image_not_supported, size: 20, color: Colors.grey),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),

              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E5E3A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('تم فتح تفاصيل السجل ${item['id']}'), backgroundColor: const Color(0xFF1E5E3A)),
                    );
                  },
                  child: const Text('عرض التفاصيل', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetaRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13))),
          Expanded(child: Text(val, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2D3748), fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildMetaRowColored(String label, String val, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13))),
          Expanded(child: Text(val, style: TextStyle(fontWeight: FontWeight.w800, color: color, fontSize: 13))),
        ],
      ),
    );
  }
}

class ClipReredRect extends StatelessWidget {
  final BorderRadius borderRadius;
  final Widget child;
  const ClipReredRect({Key? key, required this.borderRadius, required this.child}) : super(key: key);
  @override
  Widget build(BuildContext context) => ClipRRect(borderRadius: borderRadius, child: child);
}

// Sub-screen for Creating New Observation ("انشاء اسكار جديد")
class CreateObservationScreen extends StatelessWidget {
  const CreateObservationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('انشاء اسكار جديد', style: TextStyle(color: Color(0xFF1E5E3A), fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF2D3748), size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 3))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('العنوان', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3748), fontSize: 14)),
              const SizedBox(height: 6),
              TextField(
                controller: TextEditingController(text: 'ملاحظة خطر في السلم'),
                decoration: _inputDeco('عنوان الملاحظة'),
              ),
              const SizedBox(height: 16),

              const Text('الموقع', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3748), fontSize: 14)),
              const SizedBox(height: 6),
              TextField(
                controller: TextEditingController(text: 'مبنى الإنتاج - الدور الأول'),
                decoration: _inputDeco('تحديد المبنى والقطاع'),
              ),
              const SizedBox(height: 16),

              const Text('الوصف', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3748), fontSize: 14)),
              const SizedBox(height: 6),
              TextField(
                maxLines: 4,
                controller: TextEditingController(text: 'يوجد درجة مكسورة في السلم تشكل خطر على الموظفين عند الانتقال بين الطوابق'),
                decoration: _inputDeco('وصف التفاصيل بدقة...'),
              ),
              const SizedBox(height: 16),

              const Text('الأولوية', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3748), fontSize: 14)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red.shade300),
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.red.withOpacity(0.05),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('عالية (High Priority)', style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold)),
                    Icon(Icons.flag, color: Colors.red.shade700, size: 20),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              const Text('الصور التوضيحية', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3748), fontSize: 14)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    width: 70, height: 70,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F4F8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF1E5E3A).withOpacity(0.3), style: BorderStyle.solid, width: 1.5),
                    ),
                    child: const Icon(Icons.add_a_photo, color: Color(0xFF1E5E3A), size: 28),
                  ),
                  const SizedBox(width: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network('https://images.unsplash.com/photo-1517646287270-a5a9ca602e5c?auto=format&fit=crop&w=200&q=80', width: 70, height: 70, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network('https://images.unsplash.com/photo-1504307651591-00dcc993a6f5?auto=format&fit=crop&w=200&q=80', width: 70, height: 70, fit: BoxFit.cover),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E5E3A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم إرسال تقرير الاسكار والملاحظات بنجاح إلى فريق السلامة!'), backgroundColor: Color(0xFF1E5E3A)),
                    );
                  },
                  child: const Text('إرسال', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10)), borderSide: BorderSide(color: Color(0xFF1E5E3A), width: 1.5)),
    );
  }
}
