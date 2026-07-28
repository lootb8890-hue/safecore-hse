import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/branding_engine.dart';
import '../../core/theme/glassmorphism.dart';

class TasksAndAiStudioScreen extends StatefulWidget {
  const TasksAndAiStudioScreen({Key? key}) : super(key: key);

  @override
  State<TasksAndAiStudioScreen> createState() => _TasksAndAiStudioScreenState();
}

class _TasksAndAiStudioScreenState extends State<TasksAndAiStudioScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  bool _aiAnalyzing = false;
  Map<String, dynamic>? _aiResults;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  void _runAiDiagnostic() async {
    setState(() => _aiAnalyzing = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    setState(() {
      _aiAnalyzing = false;
      _aiResults = {
        'model': 'SafeCore Gemini Vision Engine v2.4',
        'riskScore': 85,
        'violations': [
          {'hazard': 'Blocked Emergency Fire Exit Corridor', 'severity': 'HIGH', 'standard': 'OSHA 29 CFR 1910.36'},
          {'hazard': 'Missing Hard Hat Protective PPE on operator', 'severity': 'MEDIUM', 'standard': 'ISO 45001 Sec 8.1'},
        ],
        'correctiveAction': 'Immediately relocate equipment crates obstructing Exit pathway within 30 minutes.',
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final branding = Provider.of<BrandingProvider>(context).branding;

    return Column(
      children: [
        Container(
          color: branding.primaryColor.withOpacity(0.05),
          child: TabBar(
            controller: _tabCtrl,
            labelColor: branding.primaryColor,
            unselectedLabelColor: Colors.grey.shade600,
            indicatorColor: branding.secondaryColor,
            indicatorWeight: 3,
            tabs: const [
              Tab(icon: Icon(Icons.today), text: "Today's Tasks & Calendar"),
              Tab(icon: Icon(Icons.psychology), text: 'AI Vision Hazard Analyzer'),
              Tab(icon: Icon(Icons.library_books), text: 'ISO Documents & SOP Center'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabCtrl,
            children: [
              _buildTodaysTasksTab(branding),
              _buildAiVisionTab(branding),
              _buildDocumentsTab(branding),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTodaysTasksTab(TenantBranding branding) {
    final tasks = [
      {'title': 'Inspect Extinguisher Battery at Sector 2', 'priority': 'HIGH', 'time': '09:00 AM', 'done': true},
      {'title': 'Verify Hot-Work Welding Permit #WP-409', 'priority': 'URGENT', 'time': '11:30 AM', 'done': false},
      {'title': 'Conduct Gas Detector Bump Test on Deck', 'priority': 'NORMAL', 'time': '02:00 PM', 'done': false},
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text("CONSOLIDATED MEMBER DAILY ROSTER", style: TextStyle(fontWeight: FontWeight.bold, color: branding.primaryColor, fontSize: 18)),
        const SizedBox(height: 12),
        for (final t in tasks)
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: Checkbox(value: t['done'] as bool, activeColor: Colors.green, onChanged: (_) {}),
              title: Text(t['title'] as String, style: TextStyle(fontWeight: FontWeight.w700, decoration: (t['done'] as bool) ? TextDecoration.lineThrough : null)),
              subtitle: Text('Scheduled for ${t['time']}', style: const TextStyle(fontSize: 12)),
              trailing: Chip(
                label: Text(t['priority'] as String, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                backgroundColor: t['priority'] == 'URGENT' ? Colors.red : (t['priority'] == 'HIGH' ? Colors.orange : Colors.blueGrey),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAiVisionTab(TenantBranding branding) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('AI VISION HAZARD DETECTION & OSHA COMPLIANCE STUDIO', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: branding.secondaryColor)),
          const SizedBox(height: 8),
          const Text('Upload workplace field photos to automatically detect missing safety PPE, blocked fire doors, and corrosion.', style: TextStyle(color: Colors.blueGrey)),
          const SizedBox(height: 20),

          GlassContainer(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 220,
                  decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade400)),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_outlined, size: 48, color: branding.primaryColor),
                        const SizedBox(height: 8),
                        const Text('Drop Workplace Photo / Capture via Inspection Camera', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _aiAnalyzing ? null : _runAiDiagnostic,
                    icon: _aiAnalyzing ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.auto_awesome),
                    label: Text(_aiAnalyzing ? 'ANALYZING OSHA/ISO HAZARDS...' : 'RUN AI SAFETY VISION DIAGNOSTIC', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          if (_aiResults != null) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.red.shade300)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('AI VISION COMPLIANCE VERDICT', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.red.shade900)),
                      Text('Risk Score: ${_aiResults!['riskScore']}/100', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.red.shade900, fontSize: 16)),
                    ],
                  ),
                  const Divider(),
                  for (final v in _aiResults!['violations'] as List<dynamic>)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          Expanded(child: Text('${v['hazard']} (${v['standard']})', style: const TextStyle(fontWeight: FontWeight.w700))),
                        ],
                      ),
                    ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                    child: Text('Suggested Corrective Action: ${_aiResults!['correctiveAction']}', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDocumentsTab(TenantBranding branding) {
    final docs = [
      {'title': 'Corporate Emergency Evacuation Policy v4.2', 'type': 'PDF', 'date': '2026-06-15'},
      {'title': 'Sulfuric Acid Hazardous MSDS Chemical Sheet', 'type': 'PDF', 'date': '2026-05-10'},
      {'title': 'Hot Work Permit Safety Procedure Manual', 'type': 'DOCX', 'date': '2026-04-22'},
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text("ISO & OSHA DOCUMENT CENTER REPOSITORY", style: TextStyle(fontWeight: FontWeight.bold, color: branding.primaryColor, fontSize: 18)),
        const SizedBox(height: 12),
        for (final d in docs)
          Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: Icon(d['type'] == 'PDF' ? Icons.picture_as_pdf : Icons.description, color: d['type'] == 'PDF' ? Colors.red : Colors.blue, size: 32),
              title: Text(d['title'] as String, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text('Format: ${d['type']}  •  Last Updated: ${d['date']}'),
              trailing: IconButton(icon: const Icon(Icons.download), onPressed: () {}),
            ),
          ),
      ],
    );
  }
}
