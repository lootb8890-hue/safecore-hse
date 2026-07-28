import 'package:flutter/material.dart';

class FireExtinguishersScreen extends StatefulWidget {
  const FireExtinguishersScreen({Key? key}) : super(key: key);

  @override
  State<FireExtinguishersScreen> createState() => _FireExtinguishersScreenState();
}

class _FireExtinguishersScreenState extends State<FireExtinguishersScreen> {
  String _searchQuery = '';
  final List<Map<String, dynamic>> _extinguishers = [
    {
      'title': 'مطفأة بودرة جافة',
      'id': '#FE-001',
      'location': 'مبنى الإنتاج - الدور الأرضي',
      'lastInspection': '2024/05/20',
      'status': 'سليم',
      'isHealthy': true,
      'type': 'POWDER',
    },
    {
      'title': 'مطفأة ثاني أكسيد الكربون',
      'id': '#FE-002',
      'location': 'المستودع - الجهة الشمالية',
      'lastInspection': '2024/05/18',
      'status': 'سليم',
      'isHealthy': true,
      'type': 'CO2',
    },
    {
      'title': 'مطفأة رغوية',
      'id': '#FE-003',
      'location': 'مبنى الإدارة - الدور الأول',
      'lastInspection': '2024/05/15',
      'status': 'يحتاج فحص',
      'isHealthy': false,
      'type': 'FOAM',
    },
    {
      'title': 'مطفأة بودرة جافة سريعة',
      'id': '#FE-004',
      'location': 'غرفة الغلايات والمولدات الرئيسية',
      'lastInspection': '2024/05/10',
      'status': 'سليم',
      'isHealthy': true,
      'type': 'POWDER',
    },
  ];

  void _showAddExtinguisherModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('إضافة فحص مطفأة جديدة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E5E3A))),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'نوع المطفأة (مثلاً: مطفأة بودرة جافة)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'رقم التعريف (مثلاً: #FE-005)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'الموقع داخل المنشأة',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E5E3A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم إدراج تقرير فحص المطفأة بنجاح!'), backgroundColor: Color(0xFF1E5E3A)),
                );
              },
              child: const Text('حفظ واعتماد الفحص', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _extinguishers.where((e) {
      final text = '${e['title']} ${e['id']} ${e['location']}'.toLowerCase();
      return text.contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('المطافئ', style: TextStyle(color: Color(0xFF1E5E3A), fontWeight: FontWeight.bold)),
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
        child: Column(
          children: [
            // Top Simulated Map Section showing GPS extinguisher markers
            Container(
              height: 160,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
                image: const DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1524661135-423995f22d0b?auto=format&fit=crop&w=800&q=80'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.white70, BlendMode.lighten),
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 30, left: 50,
                    child: _buildPin(Icons.location_on, Colors.red, 'FE-001'),
                  ),
                  Positioned(
                    top: 70, left: 140,
                    child: _buildPin(Icons.location_on, Colors.red, 'FE-002'),
                  ),
                  Positioned(
                    bottom: 30, right: 70,
                    child: _buildPin(Icons.location_on, Colors.red, 'FE-003'),
                  ),
                  Positioned(
                    top: 40, right: 30,
                    child: _buildPin(Icons.location_on, Colors.red, 'FE-004'),
                  ),
                ],
              ),
            ),

            // Search input field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'بحث عن مطفأة...',
                  hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // List of extinguishers cards
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final ext = filteredList[index];
                return _buildExtinguisherCard(ext);
              },
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1E5E3A),
        foregroundColor: Colors.white,
        elevation: 4,
        onPressed: _showAddExtinguisherModal,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildPin(IconData icon, Color color, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 32),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(4)),
          child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
        )
      ],
    );
  }

  Widget _buildExtinguisherCard(Map<String, dynamic> ext) {
    final isHealthy = ext['isHealthy'] as bool;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left icon/image placeholder for red extinguisher
          Container(
            width: 54,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(Icons.fire_extinguisher, color: Colors.red.shade700, size: 38),
            ),
          ),
          const SizedBox(width: 14),

          // Details column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(ext['title'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2D3748))),
                    Text('رقم ${ext['id']}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 4),
                Text('الموقع: ${ext['location']}', style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                const SizedBox(height: 2),
                Text('تاريخ الفحص: ${ext['lastInspection']}', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isHealthy ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isHealthy ? Icons.check_circle : Icons.warning_amber_rounded,
                            size: 15,
                            color: isHealthy ? const Color(0xFF2E7D32) : Colors.orange.shade800,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            ext['status'],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isHealthy ? const Color(0xFF2E7D32) : Colors.orange.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade400),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
