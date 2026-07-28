import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/network/socket_service.dart';

class EmergencyRedButtonScreen extends StatefulWidget {
  const EmergencyRedButtonScreen({Key? key}) : super(key: key);

  @override
  State<EmergencyRedButtonScreen> createState() => _EmergencyRedButtonScreenState();
}

class _EmergencyRedButtonScreenState extends State<EmergencyRedButtonScreen> {
  String _selectedType = 'FIRE';
  final TextEditingController _locCtrl = TextEditingController(text: 'Plant A - Central Control distillation column Zone 3');
  bool _alarmTriggered = false;

  final List<Map<String, dynamic>> _emergencyTypes = [
    {'type': 'FIRE', 'label': 'Fire Alarm (حريق)', 'icon': Icons.local_fire_department, 'color': Colors.red},
    {'type': 'INJURY', 'label': 'Medical Injury (إصابة)', 'icon': Icons.local_hospital, 'color': Colors.orange},
    {'type': 'GAS_LEAK', 'label': 'Gas Leakage (تسرب غاز)', 'icon': Icons.cloud_outlined, 'color': Colors.amber.shade800},
    {'type': 'ELECTRICAL_SHORT', 'label': 'Electrical (تماس كهربائي)', 'icon': Icons.electrical_services, 'color': Colors.purple},
    {'type': 'HAZMAT', 'label': 'HazMat Spill (مواد خطرة)', 'icon': Icons.science_outlined, 'color': Colors.deepOrange},
    {'type': 'EVACUATION', 'label': 'Facility Evacuation (إخلاء)', 'icon': Icons.directions_run, 'color': Colors.green.shade700},
  ];

  void _triggerInstantAlarm() {
    final socket = Provider.of<SocketService>(context, listen: false);
    setState(() => _alarmTriggered = true);
    
    socket.triggerLocalSimulatedEmergency({
      'type': _selectedType,
      'locationText': _locCtrl.text,
      'reportedByName': 'Eng. Khalid Al-Mansoor',
      'severity': 'CRITICAL',
    });
  }

  @override
  Widget build(BuildContext context) {
    final socket = Provider.of<SocketService>(context);
    final isAlarming = socket.activeSirenAlert || _alarmTriggered;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          if (isAlarming)
            Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.red.shade700,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.5), blurRadius: 20, spreadRadius: 4)],
              ),
              child: Column(
                children: [
                  const Icon(Icons.warning_rounded, size: 64, color: Colors.white)
                      .animate(onPlay: (c) => c.repeat())
                      .shake(duration: 500.ms),
                  const SizedBox(height: 12),
                  const Text(
                    '🚨 CRITICAL SIREN BROUGHT TO ALL ENTERPRISE CHANNELS 🚨',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Emergency Category: $_selectedType at location: ${_locCtrl.text}. All nearby floor marshals have been notified with acoustic siren alarms!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() => _alarmTriggered = false);
                      socket.dismissActiveAlarm();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.red.shade900, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14)),
                    icon: const Icon(Icons.volume_off),
                    label: const Text('SILENCE SIREN & RESOLVE CONTAINMENT', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

          Text('ZERO-LATENCY EMERGENCY BROADCAST CENTER', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.red.shade700, letterSpacing: 1.2)),
          const SizedBox(height: 8),
          const Text('Select critical incident type and press the Red Button for instant sound siren & layout notification across the facility network.', textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Colors.blueGrey)),
          const SizedBox(height: 24),

          // Emergency Category Selector Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 2.2, crossAxisSpacing: 12, mainAxisSpacing: 12),
            itemCount: _emergencyTypes.length,
            itemBuilder: (context, idx) {
              final item = _emergencyTypes[idx];
              final isSel = _selectedType == item['type'];
              return InkWell(
                onTap: () => setState(() => _selectedType = item['type']),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSel ? item['color'].withOpacity(0.15) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSel ? item['color'] : Colors.grey.shade300, width: isSel ? 2.5 : 1),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(item['icon'], color: item['color'], size: 24),
                      const SizedBox(width: 8),
                      Flexible(child: Text(item['label'], style: TextStyle(fontWeight: isSel ? FontWeight.w800 : FontWeight.w600, fontSize: 13, color: isSel ? item['color'] : Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          TextField(
            controller: _locCtrl,
            decoration: InputDecoration(
              labelText: 'Incident Location / Sector Area Description',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              prefixIcon: const Icon(Icons.location_searching, color: Colors.red),
            ),
          ),
          const SizedBox(height: 36),

          // Pulsating Big Red Emergency Button
          GestureDetector(
            onTap: _triggerInstantAlarm,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [Colors.red.shade400, Colors.red.shade800, const Color(0xFF8B0000)]),
                boxShadow: [
                  BoxShadow(color: Colors.red.withOpacity(0.5), blurRadius: 30, spreadRadius: 10),
                  const BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 8)),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.sos_rounded, color: Colors.white, size: 72),
                    const SizedBox(height: 8),
                    const Text('ACTIVATE SIREN', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                    Text('TAP TO DISPATCH', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
                  ],
                ),
              ),
            )
            .animate(onPlay: (controller) => controller.repeat())
            .scale(duration: 1200.ms, begin: const Offset(0.96, 0.96), end: const Offset(1.04, 1.04))
            .then(duration: 1200.ms),
          ),
          const SizedBox(height: 30),
          const Text('⚡ Architecture supports automated municipal dispatch system integration (No force-auto phone dialing).', style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}
